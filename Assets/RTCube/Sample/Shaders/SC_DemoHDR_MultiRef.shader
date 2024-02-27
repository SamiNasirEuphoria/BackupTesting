Shader "Skycube/Demo/SC_DemoHDR_Test_MultiRef" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		//_CubeType ("Cube Type", float) = 0.0
		_Cube ("Reflection Cubemap", Cube) = "" { TexGen CubeReflect }

	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 300
		
		CGPROGRAM
		#include "UnityCG.cginc"
		//#include "Assets/SkyCube/Shaders/SC_Common_Libs.cginc"
		//#define SC_HC
		//#pragma glsl
		#include "SC_Common_Libs.cginc"
		#pragma surface surf BlinnPhong
		#pragma target 3.0
		

		sampler2D _MainTex;
		samplerCUBE _Cube;


		struct Input {
			float2 uv_MainTex;
			float3 color : COLOR;
			float3 worldRefl;
			float3 viewDir;
			float3 worldNormal;
			INTERNAL_DATA
		};



		void surf (Input IN, inout SurfaceOutput o) {
			//o.vSpecColor = 1;
			//o.fGlossiness = _Shininess;

			half4 c1 = 1;
			half4 c2 = 1;
			half4 c3 = 1;

			//c = SC_texCUBERGBM(_Cube, IN.worldRefl,8,1);
			float f = saturate(dot(normalize(IN.viewDir),normalize(IN.worldNormal)));
			float d = saturate(dot(normalize(float3(-0.1,0.1,0.9)),normalize(IN.worldNormal)));
			f = (1-f);
			float f1 = clamp(pow(f,4),0.07,1) * 0.99;
			float f2 = clamp(pow(f,1.5),0.15,1) * 0.3333;
			float f3 = clamp(pow(d,2),0.15,1) * 0.5;
			c1 = SC_texCUBERGBM(_Cube, IN.worldRefl,6,1,0) * f1;
			c2 = SC_texCUBERGBM(_Cube, IN.worldRefl,6,1,2) * f2;
			c3 = SC_texCUBERGBM(_Cube, IN.worldRefl,6,1,3) * f3;


			//half4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = 0;//IN.color * 1; 
			//o.Albedo = (fixed3)(IN.worldRefl.x+1.0f) * 0.5;
			o.Emission = lerp(lerp(c3,c2,f1+f2),c1,f1);
			o.Alpha = 1.0f;//c.a;
		}
		ENDCG
	} 
	FallBack off
}
