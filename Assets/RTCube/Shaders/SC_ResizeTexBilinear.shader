// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/Skycube/INT/SC_ResizeTexBilinear" {
	Properties {
		_MainTex ("Base (RGBM)", 2D) = "black" {}
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
				float4 result = tex2D( _MainTex, i.uv );

				return result;
			}

	    ENDCG
	  	}

	}

Fallback off
}
