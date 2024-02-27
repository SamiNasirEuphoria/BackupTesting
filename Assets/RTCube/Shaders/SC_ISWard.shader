// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//Importance Sampling
//Ward
Shader "Hidden/Skycube/INT/SC_ISWard" 
{
	Properties{
		//_MainTex ("Base (RGBM)", 2D) = "black" {}

		_Samples("Samples",Float) = 32

		SM_SamplesTable("Samples Weight", 2D) = "" {}
		SM_ScalesTable("Scales Weight", 2D) = "" {}

		//_RefDPFront("Dual-paraboloid Front", 2D) = "" {} 
		//_RefDPBack("Dual-paraboloid Back", 2D) = "" {}

		_RefDP("Dual-paraboloid", 2D) = "" {}  
		_Face ("Face", float) = 0.0

	}
	SubShader
	{
		ZTest Always Cull Off ZWrite Off
		Fog { Mode off }
		Tags { "RenderType"="Opaque" }
    	Pass 
    	{
		
			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma target 3.0
			#pragma glsl
			#pragma vertex vert
			#pragma fragment frag
			
			float _Samples;
			float _Face;

			sampler2D SM_SamplesTable;
			sampler2D SM_ScalesTable;
			sampler2D _RefDP;

			static const float scaleParabolidMap = 1.0/2.4;

			//uniform float3 v3Translate;		// The objects world pos
		
			struct v2f
			{
    			float4  pos : SV_POSITION;
    			float2  uv : TEXCOORD0;
    			float3  c0 : COLOR0;
			};

			// Move it to Libs
			float3 GetVec(fixed2 UV, float face){

		        float3 VEC;
		        UV = -(UV * 2 - 1); // Range from 0 to 1 to 1 to -1 (since in unity UV is invert by directX UV)


		        if(face == 0.0f){ //PositiveX	 Right facing side (+x).
					VEC = float3(1.0,UV.y,UV.x);
				}

				else if(face == 1.0f){ //NegativeX	 Left facing side (-x).
					VEC = float3(-1.0f,UV.y,-UV.x);
				}

				else if(face == 2.0f){ //PositiveY	 Upwards facing side (+y).
					VEC = float3(-UV.x,1.0f,-UV.y);
				}

				else if(face == 3.0f){ //NegativeY	 Downward facing side (-y).
					VEC = float3(-UV.x,-1.0f,UV.y);
				}

				else if(face == 4.0f){ //PositiveZ	 Forward facing side (+z).
					VEC = float3(-UV.x,UV.y,1.0f);
				}

				else if(face == 5.0f){ //NegativeZ	 Backward facing side (-z).
					VEC = float3(UV.x,UV.y,-1.0f);
				}

				else{
					VEC = float3(0.0f,0.0f,1.0f);
				}

		        return normalize(VEC);

		    }
	
			float2 getDPUVByVec(float3 vec){
				float2 uv;
				if(vec.z < 0){// Front
					uv = vec.xy/(1 - vec.z);
					uv = uv * scaleParabolidMap + 0.5; // Range from -1 to 1 to 0 to 1
					uv.x *= 0.5; // Move to left in texture
				}
				else{ // Back
					vec.y = -vec.y;
					uv = - vec.xy/(1 + vec.z);
					uv = uv * scaleParabolidMap + 0.5; // Range from -1 to 1 to 0 to 1
					//uv.y = -uv.y;
					uv.x = (uv.x * 0.5) + 0.5; // Move to right in texture
				}

				return uv;
			}

			

			//

			v2f vert(appdata_base v)
			{
				//Debug
				v2f OUT;
				OUT.pos = UnityObjectToClipPos(v.vertex);
    			OUT.uv = v.texcoord.xy;
				OUT.c0 = 0;
							
    			return OUT;
			}

			
			half4 frag(v2f IN) : COLOR
			{

				float2 UV = IN.uv;
				float3 v = GetVec(UV, _Face);
				//float3 v3CameraDir = _WorldSpaceCameraPos - v3Translate;	// The camera's current position

				//v = mul((float3x3)_World2Object, v);
				/*
				if(v.z < 0.0){
					if(v.z < -0.01)
						v.z = -0.01;
				}
				else{
					if(v.z < 0.01)
						v.z = 0.01;
				}
				
				
				v = normalize(v);*/


				float4 c = 0;
				float count = 0;
				int samples = (int)_Samples;
				float4 smpls = (float4)0;
				float fs = 0;

				for (int i=0; i < samples; i++) {
					float2 uv = float2((float)i/(float)samples, 0.5);
					smpls = tex2Dlod(SM_SamplesTable, half4(uv,0,0));
					fs = tex2Dlod(SM_ScalesTable, half4(uv,0,0)).r;
					//if(smpls < 0.00001){
						//optimize it when angle small
					//}
					// see genWardSamples in sequencegen.cpp for how samples are pre-calculated
					float dot_hv = dot(smpls.xyz, v);
					float3 u = (2.0 * dot_hv) * smpls.xyz - v;
					u = float3(-u.x,-u.y,u.z);
					float3 u_w = u;//mul(_Object2World, u);

					//float f = dot_hv * fs * sqrt(u.z/v.z);
					//float f = fs * abs(dot_hv) * sqrt(u.z/v.z);
					float f = dot(u,v);
					// Level-of-detail approximation:
					// If we assume the dual-paraboloid has no distortion, we can futher simplify
					// the LOD computation as being the resolution of the map (I), divided by the spherical 
					// area of the dual paraboloid map (2Pi), divided by the number of samples (N)
					//
					// Log[2, I*I/N/(2Pi)]*0.5 + 1 = Log[2, 512*512/40/(2*Pi)]*0.5 + 1 = 5.01329 + 1
					//float lod = 6.01329f - log2(smpls.w/dot_hv)*0.5;
					//float lod = 6.01329f - log2(smpls.w/abs(dot_hv))*0.5;
					float lod = 6.01329f - log2(smpls.w)*0.5;


					// conditional if to ensure that the sample is contributing a value to the integral;
					// this can be commented out for faster code at the cost of inaccuracy around
					// viewing directions tangent to the surface
					//if (u.z > 0) {
						//c.rgb += texCUBElod(_RefCube, float4(u_w, lod))*f;
						c.rgba += tex2Dlod(_RefDP, float4(getDPUVByVec(u_w), 0, lod)).rgba;
						count+=1; // don't use old alpha to count loop times.
					//}
				}

				c = c/count;
				//c.rgb = tex2Dlod(_RefDP, float4(getDPUVByVec(v), 0, 7));//c.rgb/c.a;

				return c;

			}
			
			ENDCG

    	}
	}
}
