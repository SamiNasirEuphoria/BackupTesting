// Li Liu
// support@atomsdev.com
//
// Copyright (c) 2015.

using UnityEngine;
//using System.Collections;


[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
[AddComponentMenu("Skycube/Image Effects/HDRRendering EV")]
public class SC_HDRLEV : MonoBehaviour {
	/// Provides a shader property that is set in the inspector
	/// and a material instantiated from the shader
	public Shader   shader;
	public Material m_Material;
	//public Texture  textureRamp;
	public float ExposureValue = 0.0f;

	public float SetEV(float fEV){
		return Mathf.Pow(0.5f,fEV );
	}

	protected void Start ()
	{
		shader = Shader.Find("Hidden/Skycube/INT/SC_ToneMappingHDR");
		m_Material = null;
		//ExposureValue = 1.0f;
		// Disable if we don't support image effects
		if (!SystemInfo.supportsImageEffects) {
			enabled = false;
			return;
		}
		
		// Disable the image effect if the shader can't
		// run on the users graphics card
		if (!shader || !shader.isSupported)
			enabled = false;
	}

	protected Material material {
		get {
			if (m_Material == null) {
				m_Material = new Material (shader);
				m_Material.hideFlags = HideFlags.HideAndDontSave;
			}
			return m_Material;
		} 
	}
	
	protected void OnDisable() {
		if( m_Material ) {
			DestroyImmediate( m_Material ); 
			//DestroyImmediate( shader );
		} 
	}

	// Called by camera to apply image effect
	void OnRenderImage (RenderTexture source, RenderTexture destination) {
		//material.SetTexture("_MainTex", textureRamp);

		material.SetFloat("_EV", SetEV(ExposureValue));
		Graphics.Blit (source, destination, material);
	}


}

