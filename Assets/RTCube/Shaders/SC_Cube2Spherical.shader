// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/Skycube/INT/SC_Cube2Spherical" {
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

			float3 GetSphericalMapping_UV2VEC(fixed2 UV, float mode) //Use for create LP map
			{
				float3 VEC;
				half uval;
				if(mode > 0.9f){
					uval = 2 * A_PI * (1.0f - UV.x);
				}
				else{
					uval = 2 * A_PI * (UV.x);
				}
				
				half vval = A_PI * (UV.y);
				
				VEC.x = -sin(uval)*sin(vval);
				VEC.y = -cos(vval);
				VEC.z = -(sin(vval)*cos(uval));

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
				float4 result = texCUBElod (_Cube, float4(GetSphericalMapping_UV2VEC(i.uv, _Mode),0));
				if(_Gamma !=1.0f)
				{
					result.rgb = pow(result.rgb, _Gamma);
				}
				//float4 result = float4(((float3)GetSphericalMapping_UV2VEC(i.uv) + 1)*0.5,1.0);//texCUBE (_Cube, (float3)GetSphericalMapping_UV2VEC(i.uv));

				return result;

			}

	    ENDCG
	  	}

	}

Fallback off
}
