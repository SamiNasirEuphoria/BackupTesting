// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/Skycube/INT/SC_ToneMappingHDR" {
	Properties {
		_MainTex ("Base (HDR)", 2D) = "black" {}
		_EV ("EV", float) = 0.0
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
			half _EV;

			half3 DecodeRGBM(float4 rgbm, half maxRange)
			{
			    return rgbm.rgb * (rgbm.a * maxRange);
			}

			half4 ToneMappingHDR(float4 hdr, half ev)
			{
			    return float4(hdr.rgb * ev, 1);
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
				
				//float4 result = float4(DecodeRGBM(c_rgbm, _EV),1);
				float4 result = ToneMappingHDR(tex2D(_MainTex, i.uv), _EV);

				return result;

			}

	    ENDCG
	  	}

	}

Fallback off
}
