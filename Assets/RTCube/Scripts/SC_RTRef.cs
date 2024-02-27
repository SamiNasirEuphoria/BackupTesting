using UnityEngine;
//#if UNITY_EDITOR
//using UnityEditor;
//#endif
//using System;
using System.Collections;
using SC;

#if UNITY_EDITOR
[ExecuteInEditMode()]
//[MenuItem ("Tools/Skycube/HDR RT Reflection")]
[AddComponentMenu("Skycube/HDR RT Reflection")]
#endif

public class SC_RTRef : MonoBehaviour
{
    private int cubemapSize = 16;
    //+X(R) -X(L) +Y(U) -Y(D) +Z(F) -Z(B)
    private Vector3[] camVectors = new Vector3[6] {new Vector3(0f, 90f, 0f), new Vector3(0f, 270f, 0f), new Vector3(270f, 0f, 0f), 
                                                new Vector3(90f, 0f, 0f), new Vector3(0f, 0f, 0f), new Vector3(180f, 0f, 180f)};
    private Vector3 vCurCamDirection;

    public int sampleSize = 16;
    public float nearClip = 0.01f;
    public float farClip = 500;
    public RenderingPath path = RenderingPath.UsePlayerSettings;
    public LayerMask layerMask;
    //public LayerMask RenderLayerCube;
    //public int LayerCube;
    public int RefreshRate = 1;
    public bool hasHDR = false; 
    public float fMaxRangeHDR = 8;
    //public Vector3 CameraPosition;

    public bool hasSpecChain = false;
    public float fGlossiness = 1.0f;

    public float fGammaIn = 1.0f;
    public float fGammaOut = 1.0f;
    public bool hasAsyncSample = false;


    private Shader EncodeShader;
    private Camera camHDR;
    private RenderTexture HDRface0;
    private RenderTexture RGBMface0;
    //private Texture2D RGBMface0;
    private int faceMask = 0;
    private Material mat0;
    private bool forceLDR = false;
    
    public bool hasLinearCube = false;
    ///public bool hasInEditor = false;

    private SC_WardSamples ISWard = new SC_WardSamples(8,0.001f,0.001f);
    private Vector2 anisoXY;
    
    private RenderTexture[] rtTable01Array;
    private RenderTexture[] rtTable02Array;
    private bool[] hasSkip;
    private int[] sizeMipArray;

    //public GameObject objCam;
    private GameObject hdrsampler;
    //private GameObject hdrsampler = new GameObject( "CubemapCamera", typeof(Camera) );
    public Cubemap cubeRGBM;
    public bool hasSmoothEdge = false;
    private int smoothEdge = 0;

    private Cubemap cubeRGBMTemp;
    private RenderTexture m_rtDP;
    private int mipmapNum = 1;
    //private int cubeSmooth = 1;
        
    void OnDisable()
    {
        RenderTexture.active = null;
        //DestroyImmediate(camHDR);
        //DestroyImmediate(hdrsampler);
        DestroyImmediate(m_rtDP);
        DestroyImmediate(mat0);
        DestroyImmediate(HDRface0);
        DestroyImmediate(RGBMface0);
        //DestroyImmediate(cubeRGBM);
        rtTable01Array = null;
        rtTable02Array = null;
        //DestroyImmediate(rtTable01Array);
        //DestroyImmediate(rtTable02Array);
        
    }


    void UpdateCubemapLDR(int face)
    {
        camHDR.RenderToCubemap (cubeRGBM, face); //Convert face index from 0-5 to 1 to 6.
    }

    void UpdateCubemapHDR(int face)
    {
        camHDR.transform.rotation = Quaternion.Euler(vCurCamDirection);
        camHDR.targetTexture = HDRface0;
        camHDR.Render();
        camHDR.targetTexture = null;
    }


    void UpdateCubemapLDR2(int face)
    {
        camHDR.RenderToCubemap (cubeRGBMTemp, face); //Convert face index from 0-5 to 1 to 6.
    }


    void UpdateGlossiness()
    {
        //RT_FilterIS(cubeRGBM, cubeRGBM, 16, anisoXY, 0, false, fGlossiness);
        SC_Filter.RT_FilterIS (cubeRGBM, cubeRGBM, m_rtDP, sizeMipArray, sampleSize, rtTable01Array, rtTable02Array, false, hasSkip, smoothEdge);
    }


    void UpdateGlossiness2()
    {
        //RT_FilterIS(cubeRGBMTemp, cubeRGBM, 16, anisoXY, 0, false, fGlossiness);
        SC_Filter.RT_FilterIS (cubeRGBMTemp, cubeRGBM, m_rtDP, sizeMipArray, sampleSize, rtTable01Array, rtTable02Array, false, hasSkip, smoothEdge);
    }

    bool GenerateTables(){
        
        if(hasSpecChain){
            mipmapNum = SC_Utility._MipmapNumber(cubeRGBM.width);
            sizeMipArray = SC_Utility._MipmapSizeArray(cubeRGBM.width);
        }
        else{
            mipmapNum = 1;
            sizeMipArray = new int[1] {cubeRGBM.width};
        }



        
        float glossinessRate = 0;
        rtTable01Array = new RenderTexture[mipmapNum];
        rtTable02Array = new RenderTexture[mipmapNum];
        hasSkip = new bool[mipmapNum];


        for(int i = 0;i<mipmapNum;i++){

            glossinessRate = (float)(mipmapNum-i)/(float)mipmapNum;
            anisoXY = SC_Filter.getAnisotropicXY(fGlossiness,glossinessRate,cubeRGBM.width);

            if(anisoXY.x > 0.001f || anisoXY.y > 0.001f){ // Skip blur sample
                rtTable01Array[i] = new RenderTexture(sampleSize, 1, 16, RenderTextureFormat.ARGBHalf);
                rtTable02Array[i] = new RenderTexture(sampleSize, 1, 16, RenderTextureFormat.ARGBHalf);
                //anisoXY = getAnisotropicXY(fGlossiness,1.0f);
                ISWard.ImportanceSample(sampleSize,anisoXY.x,anisoXY.y); // Comput IS and Transfer array to RenderTexture

                SC_CUBE.RT2RT(ISWard.rtISSmplsTable, rtTable01Array[i]);
                SC_CUBE.RT2RT(ISWard.rtISScalesTable, rtTable02Array[i]);
                hasSkip[i] = false;
            }
            else{
                hasSkip[i] = true;
            }
            
        } 

        return true;
        
    }

    void Init(){
        //Get and initiating
        if(!cubeRGBM){
            return;
        }
        cubemapSize = cubeRGBM.width;
        cubeRGBM.filterMode = FilterMode.Trilinear;
        cubeRGBM.wrapMode = TextureWrapMode.Clamp;
        //cubeRGBM.SmoothEdges(cubeSmooth);
        layerMask.value = -1;

        //Check info
        if(!Mathf.IsPowerOfTwo(cubemapSize)){
            Debug.LogError("Error! The size of cubemap is not power of two.");
            //return false;
        }

        if(hasSmoothEdge){
            smoothEdge = 2;
        }
        

        //Check Video card
        if(SystemInfo.SupportsRenderTextureFormat(RenderTextureFormat.ARGBHalf))
        {
            //Debug.Log("Your graphics card does not support 32 bit floating point textures. Simulation of 16 bit may contain artifacts.");
            forceLDR = false;
        }

        else
        {
            Debug.LogError("Your graphics card does not support floating point textures. It will be rendered in LDR.");
            //EditorGUILayout.HelpBox("Error! Your graphics card does not support floating point textures to rendering in HDR and will be forced work in LDR.",MessageType.Error);
            forceLDR = true;
        }

        if(hasAsyncSample){
            cubeRGBMTemp = (Cubemap)Instantiate (cubeRGBM);
            cubeRGBMTemp.filterMode = FilterMode.Trilinear;
            cubeRGBMTemp.wrapMode = TextureWrapMode.Clamp;
            //cubeRGBMTemp.SmoothEdges(cubeSmooth);
            
        }


        GenerateTables();

        m_rtDP = new RenderTexture(cubeRGBM.width * 4, cubeRGBM.height * 2, 16, RenderTextureFormat.ARGB32);
        m_rtDP.isPowerOfTwo = true;
        m_rtDP.useMipMap = true;


        EncodeShader = Shader.Find("Hidden/Skycube/INT/SC_EncodeRGBM");//Currect Version
        //EncodeShader = Shader.Find("Skycube/INT/SC_EncodeRGBM");//UBI PC

        mat0 = new Material(EncodeShader);

        // create temporary camera for rendering
        hdrsampler = new GameObject( "CubemapCamera", typeof(Camera) );
        // place it on the object
        hdrsampler.hideFlags = HideFlags.HideAndDontSave;
        hdrsampler.transform.position = transform.position;
        hdrsampler.transform.rotation = Quaternion.identity;
        
        camHDR = hdrsampler.GetComponent<Camera>();
        
        
        camHDR.GetComponent<Camera>().renderingPath = path;
        camHDR.cullingMask = layerMask;
        camHDR.backgroundColor=Color.black;
        camHDR.nearClipPlane = nearClip;
        camHDR.farClipPlane = farClip;
        camHDR.enabled = false;


        //Camera rendering face
        HDRface0 = new RenderTexture(cubemapSize, cubemapSize ,16);
        HDRface0.useMipMap = false;
        HDRface0.isPowerOfTwo = true;
        HDRface0.hideFlags = HideFlags.HideAndDontSave;
        HDRface0.wrapMode = TextureWrapMode.Clamp;

        //RGBMface0 Render texture
        RGBMface0 = new RenderTexture(cubemapSize, cubemapSize, 16, RenderTextureFormat.ARGB32);
        RGBMface0.useMipMap = false;
        RGBMface0.isPowerOfTwo = true;
        RGBMface0.wrapMode = TextureWrapMode.Clamp;


        RGBMface0.hideFlags = HideFlags.HideAndDontSave;

        mat0.SetTexture("_MainTex", HDRface0);

        if(hasHDR && !forceLDR)
        {
            camHDR.fieldOfView = 90f;
            camHDR.GetComponent<Camera>().allowHDR = true;
            HDRface0.format = RenderTextureFormat.ARGBHalf;
            mat0.SetFloat( "_MaxRange", fMaxRangeHDR );
            //Debug.Log("Rendering in HDR.");
        }
        else
        {
            camHDR.GetComponent<Camera>().allowHDR = false;
            //HDRface0.format = RenderTextureFormat.ARGB32;
            //Debug.Log("Rendering in LDR.");
        }

        mat0.SetFloat( "_GammaIn", fGammaIn );
        mat0.SetFloat( "_GammaOut", fGammaOut );
    }
    
#if UNITY_EDITOR
    void OnEnable()
    {
        Init();

    }

#else
    void Start(){
        Init();
    }

#endif

    void Update()
    {
        if(!cubeRGBM){
            return;
        }
        if(cubemapSize != cubeRGBM.width)
        {

            Debug.LogWarning ("Cubemap size changed! Please play game once to update it or open editor mode.");
            return;
        }
        //if(!hdrsampler){
        //    return;
        //}

        hdrsampler.transform.position = transform.position;
        if(hasAsyncSample){
            if(cubeRGBMTemp==null){
                return;
            }

            for (int i = 0; i < RefreshRate; i++)
            {
                if(hasHDR && !forceLDR)
                {
                    vCurCamDirection = camVectors[faceMask];
                    UpdateCubemapHDR(faceMask);
                    Graphics.Blit(HDRface0, RGBMface0, mat0);
                    if(SC_CUBE.RT2CUBE (RGBMface0, cubeRGBMTemp, (CubemapFace)faceMask, true, true,false,false )==false){
                        Debug.LogError("RenderTexture to Cube Error!");
                    }
                    
                }
                else{
                    UpdateCubemapLDR2(1 << faceMask);

                }
                
                faceMask++;
                if (faceMask > 5)
                {
                    faceMask = 0;

                    UpdateGlossiness2();
                    //cubeRGBM.SmoothEdges(cubeSmooth);
                   
                }
                
            }
        }
        else{
            if(cubeRGBM==null){
                return;
            }

            for (int i = 0; i < RefreshRate; i++)
            {
                if(hasHDR && !forceLDR)
                {
                    vCurCamDirection = camVectors[faceMask];
                    UpdateCubemapHDR(faceMask);
                    Graphics.Blit(HDRface0, RGBMface0, mat0);
                    if(SC_CUBE.RT2CUBE (RGBMface0, cubeRGBM, (CubemapFace)faceMask, true, true,false,false )==false){
                        Debug.LogError("RenderTexture to Cube Error!");
                    }
                    
                }
                else{

                    UpdateCubemapLDR(1 << faceMask);

                }
                
                faceMask++;
                if (faceMask > 5)
                {
                    faceMask = 0;
                    UpdateGlossiness();
                    //cubeRGBM.SmoothEdges(cubeSmooth);
                }
                
            }
        }

    }

}


