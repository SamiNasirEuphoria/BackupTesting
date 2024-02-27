// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Copy Rendertexture to another one
Shader "Hidden/Skycube/INT/SC_RT2RT" {
	Properties {
		_MainTex ("Base (RGBM)", 2D) = "black" {}
	}
	
	Subshader 
	{
		Pass 
		{
			//Tags { "RenderType"="Opaque" }
			ZTest Always Cull Off ZWrite Off lighting off
			Fog { Mode off }      
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma glsl
			#include "UnityCG.cginc"
			//#include "Assets/Shaders/Atom_Common_Libs.cginc"

			sampler2D _MainTex;

			struct v2f {
				float4 pos : POSITION;
				float2 uv  : TEXCOORD0;

			};

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
				float4 result = tex2Dlod(_MainTex, float4(i.uv,0,0));
				return result;
			}

	    ENDCG
	  	}

	}

Fallback off
}
