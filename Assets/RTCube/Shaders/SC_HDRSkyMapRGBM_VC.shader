// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Skycube/Sky/RGBM SkyboxMap VC" {
	Properties {
		_Tint ("Tint Color", Color) = (.5, .5, .5, .5)

		_Range ("HDR Range", float) = 8.0 
		_EV ("HDR Power", float) = 1.0
		//_SkyMapType ("SkyMap Type", float) = 0.0

		_SkyTex ("RGBM SkyMap(Vertical Cross)", 2D) = "white" {}

		_XScale ("U Scale", float) = 1.0
		_XOffset ("U Offset", float) = 0.0
		_YScale ("V Scale", float) = 1.0
		_YOffset ("V Offset", float) = 0.0
	}

	SubShader {
		Tags { "Queue"="Background" "RenderType"="Background" }
		Cull Off ZWrite Off Fog { Mode Off }
		
		CGINCLUDE
		//CGPROGRAM
		#include "UnityCG.cginc"
		#include "SC_Common_Libs.cginc"
		//#pragma target 3.0
		#pragma glsl

		fixed4 _Tint;
		half _Range;
		half _EV;
		//half _SkyMapType;

		half _XScale;
		half _XOffset;
		half _YScale;
		half _YOffset;

		sampler2D _SkyTex;

		
		struct appdata_t {
			float4 vertex : POSITION;
			float2 texcoord : TEXCOORD0;
		};
		struct v2f {
			float4 vertex : POSITION;
			float2 texcoord : TEXCOORD0;
		};
		


		fixed4 skybox_frag (v2f i)
		{
			fixed4 tex = float4(DecodeRGBM( tex2D (_SkyTex, i.texcoord).rgba, _Range, _EV ),1.0);
			//fixed4 tex = tex2D (_SkyTex, i.texcoord);
			fixed4 col;
			col.rgb = tex.rgb + _Tint.rgb - unity_ColorSpaceGrey;
			col.a = tex.a * _Tint.a;
			return col;
		}

		fixed4 frag (v2f i) : COLOR 
		{ 
			return skybox_frag(i); 
		}

		ENDCG





		
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = GetVerticalCrossMapping_UV2UV(4,v.texcoord,half4(_XScale,_XOffset,_YScale,_YOffset));
				return o;
			}
			//fixed4 frag (v2f i) : COLOR { return skybox_frag(i,_FrontTex); }
			ENDCG 
		}
		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = GetVerticalCrossMapping_UV2UV(5,v.texcoord,half4(_XScale,_XOffset,_YScale,_YOffset));
				return o;
			}
			//fixed4 frag (v2f i) : COLOR { return skybox_frag(i,_BackTex); }
			ENDCG 
		}
		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = GetVerticalCrossMapping_UV2UV(0,v.texcoord,half4(_XScale,_XOffset,_YScale,_YOffset));
				return o;
			}
			//fixed4 frag (v2f i) : COLOR { return skybox_frag(i,_LeftTex); }
			ENDCG
		}
		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = GetVerticalCrossMapping_UV2UV(1,v.texcoord,half4(_XScale,_XOffset,_YScale,_YOffset));
				return o;
			}
			//fixed4 frag (v2f i) : COLOR { return skybox_frag(i,_RightTex); }
			ENDCG
		}	
		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = GetVerticalCrossMapping_UV2UV(2,v.texcoord,half4(_XScale,_XOffset,_YScale,_YOffset));
				return o;
			}
			//fixed4 frag (v2f i) : COLOR { return skybox_frag(i,_UpTex); }
			ENDCG
		}	
		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = GetVerticalCrossMapping_UV2UV(3,v.texcoord,half4(_XScale,_XOffset,_YScale,_YOffset));
				return o;
			}
			//fixed4 frag (v2f i) : COLOR { return skybox_frag(i,_DownTex); }
			ENDCG
		}
	}	
/*
	SubShader {
		Tags { "Queue"="Background" "RenderType"="Background" }
		Cull Off ZWrite Off Fog { Mode Off }
		Color [_Tint]
		//float [_Range]
		//float [_EV]
		Pass {
			SetTexture [_SkyTex] { combine texture +- primary, texture * primary }
		}
		Pass {
			SetTexture [_SkyTex]  { combine texture +- primary, texture * primary }
		}
		Pass {
			SetTexture [_SkyTex]  { combine texture +- primary, texture * primary }
		}
		Pass {
			SetTexture [_SkyTex] { combine texture +- primary, texture * primary }
		}
		Pass {
			SetTexture [_SkyTex]    { combine texture +- primary, texture * primary }
		}
		Pass {
			SetTexture [_SkyTex]  { combine texture +- primary, texture * primary }
		}
	}
	*/
}