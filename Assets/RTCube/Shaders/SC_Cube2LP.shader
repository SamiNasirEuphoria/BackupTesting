// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/Skycube/INT/SC_Cube2LP" {
	Properties {
		//_MainTex ("Base (RGBM)", 2D) = "black" {}
		//_MaxRange ("Max HDR Range", float) = 8.0
		_Gamma ("Gamma", float) = 1.0

		_Cube ("Cubemap", Cube) = "_Skybox" { TexGen CubeReflect }
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
			#pragma glsl
			#include "UnityCG.cginc"
			//#include "Assets/Shaders/Atom_Common_Libs.cginc"

			

			//sampler2D _MainTex;
			//half _MaxRange;
			half _Gamma;

			samplerCUBE _Cube;
			float _Mode;

			#define A_PI		3.14159265358//3.1415926535897932384626433832795
			//#define A_1D_2PI	0.1591549431//0.15915494309189533577
			
			half3 GetLPMapping_UV2VEC(fixed2 UV, float mode) //Use for create LP map
			{
				half3 VEC;
				if(mode > 0.9f){
					UV.x = 1.0f - UV.x;
				}
				UV = UV * 2 - 1; // Range to -1 to 1
		
				float lr = sqrt(UV.x * UV.x + UV.y * UV.y);
				if(lr == 0.0f){
					VEC.x = 0.0f;
					VEC.y = 0.0f;
					VEC.z = 1.0f;
				}
				else if(lr<=1.0f){
					float la = A_PI * lr; // 0-1 to range 0-Pi
					float th = sin(la);
					VEC.x = (UV.x/lr)*th;
					VEC.y = (UV.y/lr)*th;
					VEC.z = cos(la);
				}
				else{//Back
					VEC.x = 0.0f;
					VEC.y = 0.0f;
					VEC.z = -1.0f;
				}

				return VEC;
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
				float4 result = texCUBElod (_Cube, float4(GetLPMapping_UV2VEC(i.uv, _Mode),0));
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
