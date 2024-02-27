// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/Skycube/INT/SC_EncodeRGBM" {
	Properties {
		_MainTex ("Base (HDR RT)", 2D) = "black" {}
		_MaxRange ("Max HDR Range", float) = 8.0
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
			half _GammaIn;
			half _GammaOut;

			half4 EncodeRGBM(float3 rgb, half maxRange)
			{
			    half maxRGB = max(rgb.x,max(rgb.g,rgb.b));
			    half M = maxRGB / maxRange;
			    M = ceil(M * 255.0) / 255.0;
			    return half4(rgb / (M * maxRange), M);
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
				float4 c = tex2D(_MainTex, i.uv);
				
				if(_GammaIn !=1.0f){
					c.rgb = pow(c.rgb, _GammaIn);
				}
				
				float4 result = EncodeRGBM(c.rgb, _MaxRange);
				//float4 result = c;
				//result.rgb *= 0.1;
				//result.a = 1;
				//result.rgb = float3(1,1,1);
				if(_GammaOut !=1.0f){
					result.rgb = pow(result.rgb, _GammaOut);
				}

				
				return result;
				//return float4(0.5,0.5,0.5,0.5); //Output gamma correction only work for RGB without Alpha
			}

	    ENDCG
	  	}

	}

Fallback off
}
