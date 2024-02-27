// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/Skycube/INT/SC_Tex2RT" {
	Properties {
		_Tex01 ("Base 01 (RGBM)", 2D) = "black" {}
		_Tex02 ("Base 02 (RGBM)", 2D) = "black" {}
		_Tex03 ("Base 03 (RGBM)", 2D) = "black" {}
		_Tex04 ("Base 04 (RGBM)", 2D) = "black" {}

		_Max01 ("Max Range 01", float) = 1.0
		_Max02 ("Max Range 02", float) = 1.0
		_Max03 ("Max Range 03", float) = 1.0
		_Max04 ("Max Range 04", float) = 1.0
		_Normalize ("Normalize to 1/-1", float) = 0.0
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

			sampler2D _Tex01;
			sampler2D _Tex02;
			sampler2D _Tex03;
			sampler2D _Tex04;
			float _Max01,_Max02,_Max03,_Max04;
			float _Normalize;

			struct v2f {
				float4 pos : POSITION;
				float2 uv  : TEXCOORD0;
			};
///////////////////////////
			#ifndef D_BIT
			#define D_BIT		0.0039215686274509803921568627451
			#endif

			#ifndef D_BIT2
			#define D_BIT2		1.5378700499807766243752402921953e-5
			#endif

			#ifndef D_BIT3
			#define D_BIT3		6.0308629411010848014715305576287e-8
			#endif

			#ifndef DELTA
			#define DELTA		1e-6f
			#endif

			float DecodeRGBA2Float(half4 fColor, float fMax)
			{
				//const float fromFixed = 256.0f/255.0f;
				float4 vBitShift = float4(D_BIT3, D_BIT2, D_BIT, 1.0f);
				float4 vCol = fColor;// * fromFixed;
				float fVal = dot(vCol, vBitShift);
				fVal = (fVal >= 0.999999f) ? 1.0f : fVal ;
				fVal *= fMax; // Scale float back to correct range

				return fVal;
			}
//////////////////////////
			v2f vert( appdata_img v ) 
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv =  v.texcoord.xy;	
				return o;
			} 

			float4 frag(v2f i) : COLOR 
			{
				float4 result;
				result.x = DecodeRGBA2Float(tex2D( _Tex01, i.uv ), _Max01);
				result.y = DecodeRGBA2Float(tex2D( _Tex02, i.uv ), _Max02);
				result.z = DecodeRGBA2Float(tex2D( _Tex03, i.uv ), _Max03);
				result.w = DecodeRGBA2Float(tex2D( _Tex04, i.uv ), _Max04);

				if(_Normalize > 0.1){
					result.xyz = result.xyz * 2.0 - 1.0;
				}

				return result;
			}

	    ENDCG
	  	}

	}

Fallback off
}
