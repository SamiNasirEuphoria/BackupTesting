//Skycube Tool
//Realtime HDR/LDR Cubemap rendering
//Copyright 2015 (c) Li Liu & Atom's Dev
//Created by Li Liu 2015

using UnityEditor;
using UnityEngine;
using System.IO;
using System.Collections.Generic;

[CustomEditor (typeof(SC_RTRef))]
public class SC_RTRef_UI : Editor {	
    SerializedObject serObj;

    public enum eSampleNum {
        Low = 8,
        Medium = 16,
        High = 32,
        VeryHigh = 64
    };

    private SC_RTRef RTCube;
    //private float camEV;

    private Cubemap cubeRGBM;
    ///private bool hasInEditor;
    private bool hasSpecChain;
    private eSampleNum sampleNum = eSampleNum.Medium;
    private float nearClip;
    private float farClip;
    private RenderingPath path;
    private LayerMask layerMask;
    private int RefreshRate;
    private bool hasHDR = true;
    private bool hasHDRPrevious;
    private float fMaxRangeHDR;

    private float fGlossiness;
    private float fGammaIn;
    private float fGammaOut;
    private bool hasAsyncSample;
    private bool hasSmoothEdge;

 
    void OnEnable()
    {
        serObj = new SerializedObject (target);
        RTCube = (SC_RTRef)target;

        cubeRGBM = RTCube.cubeRGBM;
        ///hasInEditor = RTCube.hasInEditor;
        hasSpecChain = RTCube.hasSpecChain;
        sampleNum = (eSampleNum)RTCube.sampleSize;
        nearClip = RTCube.nearClip;
        farClip = RTCube.farClip;
        path = RTCube.path;
        layerMask = RTCube.layerMask;
        RefreshRate = RTCube.RefreshRate;
        hasHDR = RTCube.hasHDR;
        fMaxRangeHDR = RTCube.fMaxRangeHDR;
        fGlossiness = RTCube.fGlossiness;
        fGammaIn = RTCube.fGammaIn;
        fGammaOut = RTCube.fGammaOut;
        hasAsyncSample = RTCube.hasAsyncSample;
        hasSmoothEdge = RTCube.hasSmoothEdge;

        if(PlayerSettings.colorSpace == ColorSpace.Linear){

            RTCube.hasLinearCube = true;
        }
        else{
            RTCube.hasLinearCube = false;
        }
    }

	public override void OnInspectorGUI () {
        serObj.Update ();
        //
        EditorGUILayout.LabelField("Select RT Reflection Cubemap:",EditorStyles.boldLabel);

        cubeRGBM = (Cubemap) EditorGUILayout.ObjectField ("", cubeRGBM, typeof (Cubemap), true );
        ///hasInEditor = EditorGUILayout.Toggle ("Editor Mode:", hasInEditor);
        hasSpecChain = EditorGUILayout.Toggle ("Spec Chain:", hasSpecChain);
        hasSmoothEdge = EditorGUILayout.Toggle ("Blending CubeEdge:", hasSmoothEdge);
        sampleNum = (eSampleNum) EditorGUILayout.EnumPopup("Samples:", sampleNum);
        nearClip = EditorGUILayout.FloatField("NearClip: ", nearClip);
        farClip = EditorGUILayout.FloatField("FarClip: ", farClip);
        path = (RenderingPath)EditorGUILayout.EnumPopup("Rendering Path:", path);
        layerMask.value = EditorGUILayout.MaskField ( "Layer Mask:", -1, GetMaskField());
        hasAsyncSample = EditorGUILayout.Toggle ("Async Refresh:", hasAsyncSample);
        RefreshRate = EditorGUILayout.IntSlider("Cube Refresh Rate: ", RefreshRate, 1, 6);
        hasHDRPrevious = hasHDR;
        hasHDR = EditorGUILayout.Toggle ("HDR:", hasHDR);
    EditorGUI.BeginDisabledGroup (!hasHDR);
        fMaxRangeHDR = EditorGUILayout.Slider("HDR Range: ", fMaxRangeHDR, 1.0f, 8.0f);
    EditorGUI.EndDisabledGroup ();
        fGlossiness = EditorGUILayout.Slider("Glossiness: ", fGlossiness, 0.0f, 1.0f);

        //PlayerSettings.colorSpace == ColorSpace.Linear
        if(hasHDRPrevious != hasHDR){
            if(hasHDR){
                fGammaIn = 1.0f/2.2f;
                fGammaOut = 1.0f;
            }
            else{
                //if(PlayerSettings.colorSpace != ColorSpace.Linear){
                //    fGammaIn = 1.0f;
                //    fGammaOut = 2.2f;
                //}
                //else{
                    fGammaIn = 1.0f;
                    fGammaOut = 1.0f;
                //}
                
            }
            hasHDRPrevious = hasHDR;
        }
        
        fGammaIn = EditorGUILayout.Slider("Gamma In: ", fGammaIn, 0.2f, 4.0f);
        fGammaOut = EditorGUILayout.Slider("Gamma Out: ", fGammaOut, 0.2f, 4.0f);

        RTCube.cubeRGBM = cubeRGBM;

        RTCube.hasSpecChain = hasSpecChain;
        ///RTCube.hasInEditor = hasInEditor;
        RTCube.sampleSize = (int)sampleNum;
        RTCube.nearClip = nearClip;
        RTCube.farClip = farClip;
        RTCube.path = path;
        RTCube.layerMask = layerMask;
        RTCube.RefreshRate = RefreshRate;
        RTCube.hasHDR = hasHDR;
        RTCube.fMaxRangeHDR = fMaxRangeHDR;
        RTCube.fGlossiness = fGlossiness;
        RTCube.fGammaIn = fGammaIn;
        RTCube.fGammaOut = fGammaOut;
        RTCube.hasAsyncSample = hasAsyncSample;
        RTCube.hasSmoothEdge = hasSmoothEdge;


        if(GUI.changed)	{
            EditorUtility.SetDirty (target); // Update script
        }
    	serObj.ApplyModifiedProperties();

    }

    //Move it to SC DLL
    string[] GetMaskField () {

        List<string> layers = new List <string>();
        //List <int> layerNumbers;
        int emptyLayers = 0;
        string[] layerNames = new string [4];

        for (int i=0;i<32;i++) {
            string layerName = LayerMask.LayerToName (i);
 
            if (layerName != "") {
                layers.Add (layerName);
            } 
            else {
                emptyLayers++;
            }
        }
 
        if (layerNames.Length != layers.Count) {
            layerNames = new string[layers.Count];
        }
        for (int i=0;i<layerNames.Length;i++) layerNames[i] = layers[i];

        return layerNames;

    }
}