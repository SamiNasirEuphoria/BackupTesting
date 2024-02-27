// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/Skycube/INT/SC_LP2Cube" {
	Properties {
		//_MainTex ("Base (RGBM)", 2D) = "black" {}
		//_MaxRange ("Max HDR Range", float) = 8.0
		_Gamma ("Gamma", float) = 1.0

		_MainTex ("Base (RGBM)", 2D) = "black" {}
		//_Cube ("Cubemap", Cube) = "_Skybox" { TexGen CubeReflect }
		_Face ("Face", float) = 0.0
		_Mode ("Mode", float) = 0.0
	}
	
	Subshader 
	{
		Pass 
		{
			ZTest Always Cull Off ZWrite Off lighting off
			Fog { Mode off }      
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			//#include "Assets/Shaders/Atom_Common_Libs.cginc"

			

			sampler2D _MainTex;
			//half _MaxRange;
			half _Gamma;

			//samplerCUBE _Cube;
			float _Face;
			float _Mode;

			#define A_PI		3.14159265358//3.1415926535897932384626433832795
			#define A_1D_PI		0.31830988618//0.31830988618379067153776752674503
			#define A_HalfPI	1.57079632679//1.5707963267948966192313216916398
			#define A_SIN45		0.70710678119//0.7071067811865475244008443621048490392848359376884740


			float3 GetVec(fixed2 UV, float face){

		        float3 VEC;
		        UV = UV * 2 - 1; // Range to -1 to 1


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
			
			half2 GetLPMapping_VEC2UV(float3 vec, float mode) //Use for create LP map
			{
				fixed2 UV;
				float  th, la, lr, L, P;

				//UV = UV * 2 - 1; // Range to -1 to 1

				if(vec.z == 1.0f){
					UV.x = UV.y = 0.0f;
				}

				else {
					th = sqrt(vec.x * vec.x + vec.y * vec.y);
					if(vec.z < 0.0f) {
						la = asin(th);
						lr = (A_PI - la) * A_1D_PI;
						UV.y = lr * (vec.y / th);
						UV.x = lr * (vec.x / th);
					}

					else{
						la = asin(th);
						lr = la * A_1D_PI;
						UV.y = lr * (vec.y / th);
						UV.x = lr* (vec.x / th);
					}
					
					//lr = pow(L * L + P * P, 0.5f); 
				}

				//From -1 to 1 move to 0 to 1 range
				UV = (UV + 1.0f) * 0.5f;

				if(mode > 0.9f){ //sky to cube
					UV.x = (1.0f - UV.x);
				}

				return UV;
			}
			

			struct v2f {
				float4 pos : POSITION;
				float2 uv  : TEXCOORD0;
			};

			

			v2f vert( appdata_img v ) 
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv =  v.texcoord.xy;	
				return o;
			} 

			float4 frag(v2f i) : COLOR 
			{
				//float4 c_rgbm = tex2D(_MainTex, i.uv);
				float2 UV = i.uv;
				float4 result = tex2D(_MainTex, GetLPMapping_VEC2UV(GetVec(UV, _Face), _Mode));
				if(_Gamma !=1.0f)
				{
					result.rgb = pow(result.rgb, _Gamma);
				}

				return result;

			}

	    ENDCG
	  	}

	}

Fallback off
}
