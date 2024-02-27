Shader "RTCube_Demo/SCRT_DemoHDR_MultiRef" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		//_DiffTex ("Detail (RGB)", 2D) = "white" {}
		//_CubeType ("Cube Type", float) = 0.0
		_Cube ("Reflection Cubemap", Cube) = "" { TexGen CubeReflect }
		_Max ("HDR range", float) = 8.0
		_Color1 ("Main Color 1", Color) = (1,1,1,1)
		_Color2 ("Main Color 2", Color) = (1,1,1,1)
		_Color3 ("Main Color 3", Color) = (1,1,1,1)
		_Color4 ("Main Color 4", Color) = (1,1,1,1)

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
		//sampler2D _DiffTex;
		samplerCUBE _Cube;

		float _Max;

		fixed4 _Color1;
		fixed4 _Color2;
		fixed4 _Color3;
		fixed4 _Color4;


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

			float4 c1 = _Color1;
			float4 c2 = _Color2;
			float4 c3 = _Color3;
			float4 c4 = _Color4;

			//c = SC_texCUBERGBM(_Cube, IN.worldRefl,8,1);
			float f = saturate(dot(normalize(IN.viewDir),normalize(IN.worldNormal)));
			float d = clamp(pow(f,1.5),0,1);
			float d2 = clamp(pow(f,3),0,1);
			f = (1-f);
			float f1 = clamp(pow(f,2.5),0.15,1);
			float f2 = clamp(pow(f,2),0.05,1);
			//float f3 = clamp(pow(d,1.5),0.2,1) * 0.2;
			c1 *= SC_texCUBERGBM(_Cube, IN.worldRefl,_Max,1,0) * f1;
			c2 *= SC_texCUBERGBM(_Cube, IN.worldRefl,_Max,1,2) * d2;
			c3 *= SC_texCUBERGBM(_Cube, IN.worldRefl,_Max,1,3) * d2;
			c4 *= SC_texCUBERGBM(_Cube, IN.worldRefl,_Max,1,4) * d;


			float4 c = tex2Dlod(_MainTex, float4(IN.uv_MainTex,0,0));
			c = c4+c*(c3+c2);
			o.Albedo = 0;//IN.color * 1; 
			//o.Albedo = (fixed3)(IN.worldRefl.x+1.0f) * 0.5;
			o.Emission = lerp(c,c1,f1);//lerp(lerp(c3,c2,f1+f2),c1,f1);
			o.Alpha = 1.0f;//c.a;
		}
		ENDCG
	} 
	FallBack off
}
