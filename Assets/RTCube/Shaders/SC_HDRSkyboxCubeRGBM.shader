// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Skycube/Sky/RGBM SkyboxCube" {
Properties {
	_Tint ("Tint Color", Color) = (.5, .5, .5, .5)
	_SkyTex ("RGBM Cubemap", Cube) = "white" {}
	_Range ("HDR Range", float) = 8.0 
	_EV ("HDR Power", float) = 1.0
}

SubShader {
	Tags { "Queue"="Background" "RenderType"="Background" }
	Cull Off ZWrite Off Fog { Mode Off }

	Pass {
		
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma fragmentoption ARB_precision_hint_fastest

		#include "UnityCG.cginc"
		#include "SC_Common_Libs.cginc"
		#pragma glsl

		samplerCUBE _SkyTex;
		fixed4 _Tint;
		float _EV;
		float _Range;
		
		struct appdata_t {
			float4 vertex : POSITION;
			float3 texcoord : TEXCOORD0;
		};

		struct v2f {
			float4 vertex : POSITION;
			float3 texcoord : TEXCOORD0;
		};

		v2f vert (appdata_t v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.texcoord = v.texcoord;
			return o;
		}

		fixed4 frag (v2f i) : COLOR
		{
			fixed4 tex = SC_texCUBERGBM (_SkyTex, i.texcoord, _Range, _EV);
			fixed4 col;
			col.rgb = tex.rgb + _Tint.rgb - unity_ColorSpaceGrey;
			col.a = tex.a * _Tint.a;
			return col;
		}
		ENDCG 
	}
} 	


SubShader {
	Tags { "Queue"="Background" "RenderType"="Background" }
	Cull Off ZWrite Off Fog { Mode Off }
	Color [_Tint]
	Pass {
		SetTexture [_SkyTex] { combine texture +- primary, texture * primary }
	}
}

Fallback Off

}
