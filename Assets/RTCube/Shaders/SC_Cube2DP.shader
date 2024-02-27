// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Cube to Dual-paraboloid (Two DP maps in one tex)
Shader "Hidden/Skycube/INT/SC_Cube2DP" {
	Properties {
		_RefCube("Cube map", CUBE) = "" {} 
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

			samplerCUBE _RefCube;

			struct v2f {
				float4 pos : POSITION;
				float2 uv  : TEXCOORD0;

			};

			// Move it to Libs
			float3 getVecByDPUV(float2 uv){
				float A;
				float3 vec;
				if(uv.x < 0.5){
					uv.x = uv.x * 2.0;
					uv = uv * 2 - 1; // Range from 0 to 1 to 1 to -1 (since in unity UV is invert by directX UV)
					uv *= 1.2;
					A = uv.x * uv.x + uv.y * uv.y + 1;
					vec = float3(2*uv.x,2*uv.y,(A-2)); // -1+s^2+t^2 = A-2
					return (vec/A);
				}
				else {
					uv.x = uv.x * 2.0 - 1.0;

					uv = uv * 2 - 1; // Range from 0 to 1 to 1 to -1 (since in unity UV is invert by directX UV)
					uv *= 1.2;
					A = uv.x * uv.x + uv.y * uv.y + 1;
					vec = float3(2*uv.x,-2*uv.y,(A-2)); // -1+s^2+t^2 = A-2
					return (-vec/A);
				}
			}
			//

			v2f vert( appdata_img v ) 
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv =  v.texcoord.xy;	
				return o;
			}

			float4 frag(v2f i) : COLOR 
			{
				float4 result = texCUBE(_RefCube, getVecByDPUV(i.uv));
				return result;
			}

	    ENDCG
	  	}

	}

Fallback off
}
