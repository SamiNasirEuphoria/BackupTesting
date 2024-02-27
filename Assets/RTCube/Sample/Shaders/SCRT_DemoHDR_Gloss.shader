Shader "RTCube_Demo/SCRT_DemoHDR_Gloss" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_GlossTex ("Gloss (RGB)", 2D) = "white" {}
		//_CubeType ("Cube Type", float) = 0.0
		_Cube ("Reflection Cubemap", Cube) = "" { TexGen CubeReflect }
		_MipMax ("Mipmap Max", float) = 1.0
		_Max ("HDR range", float) = 8.0

	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 300
		
		CGPROGRAM
		#include "UnityCG.cginc"
		//#include "Assets/SkyCube/Shaders/SC_Common_Libs.cginc"
		//#define SC_HC
		#pragma glsl
		#include "SC_Common_Libs.cginc"
		#pragma surface surf BlinnPhong
		#pragma target 3.0
		

		

		sampler2D _MainTex;
		sampler2D _GlossTex;
		samplerCUBE _Cube;


		//half _CubeType;

		half _MipMax;
		float _Max;


		struct Input {
			float2 uv_MainTex;
			float2 uv_GlossTex;
			float3 color : COLOR;
			float3 worldRefl;
			INTERNAL_DATA
		};



		void surf (Input IN, inout SurfaceOutput o) {
			//o.vSpecColor = 1;
			//o.fGlossiness = _Shininess;

			float gloss = tex2D(_GlossTex, IN.uv_GlossTex).g;
			float4 d = tex2Dlod(_MainTex, float4(IN.uv_MainTex,0,0));

			float4 c = lerp(1.0,d,gloss);

			c *= SC_texCUBERGBM(_Cube, IN.worldRefl,_Max,1,_MipMax*gloss);
			
			//c = texCUBElod(_Cube, float4(IN.worldRefl.xyz,_Offset));


			//half4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = 0;//IN.color * 1; 
			//o.Albedo = (fixed3)(IN.worldRefl.x+1.0f) * 0.5;
			o.Emission = c.rgb;
			o.Alpha = 1.0f;//c.a;
		}
		ENDCG
	} 
	FallBack off
}
