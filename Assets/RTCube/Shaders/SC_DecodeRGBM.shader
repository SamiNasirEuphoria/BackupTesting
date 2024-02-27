// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/Skycube/INT/SC_DecodeRGBM" {
	Properties {
		_MainTex ("Base (RGBM)", 2D) = "black" {}
		_MaxRange ("Max HDR Range", float) = 8.0
		_Exp ("Exposure", float) = 1.0
		_GammaIn ("Gamma In", float) = 1.0
		_GammaOut ("Gamma Out", float) = 1.0
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

			sampler2D _MainTex;
			half _MaxRange;
			half _Exp;
			half _GammaIn;
			half _GammaOut;

			half3 DecodeRGBM(float4 rgbm, half maxRange, half ev)
			{
			    return rgbm.rgb * (rgbm.a * maxRange) * ev ;
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
				float4 c_rgbm = tex2D(_MainTex, i.uv);
				if(_GammaIn !=1.0f){
					c_rgbm.rgba = pow(c_rgbm.rgba, _GammaIn);
				}
				
				float4 result = float4(DecodeRGBM(c_rgbm, _MaxRange, _Exp),1);
				if(_GammaOut !=1.0f){
					result.rgb = pow(result.rgb, _GammaOut);
				}
				//float4 result = c;
				//result.rgb *= 0.1;
				//result.a = 1;
				//result.rgb = float3(1,1,1);
				return result;

			}

	    ENDCG
	  	}

	}

Fallback off
}
