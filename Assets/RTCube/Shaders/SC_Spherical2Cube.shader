// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/Skycube/INT/SC_Spherical2Cube" {
	Properties {
		//_MainTex ("Base (RGBM)", 2D) = "black" {}
		//_MaxRange ("Max HDR Range", float) = 8.0
		_Gamma ("Gamma", float) = 1.0

		_MainTex ("Base (RGBM)", 2D) = "black" {}
		//_Cube ("Cubemap", Cube) = "_Skybox" { TexGen CubeReflect }
		_Face ("Face", float) = 0.0
		_Mode ("Mode", float) = 0.0
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
			//half _MaxRange;
			half _Gamma;

			//samplerCUBE _Cube;
			float _Face;
			float _Mode;

			#define A_PI		3.14159265358//3.1415926535897932384626433832795
			#define A_1D_PI		0.31830988618//0.31830988618379067153776752674503


		    float3 GetVec(fixed2 UV, float face){

		        float3 VEC;
		        UV = UV * 2 - 1; // Range to -1 to 1


		        if(face == 0.0f){ //PositiveX	 Right facing side (+x).
					VEC = float3(1.0,UV.y,UV.x);
				}

				else if(face == 1.0f){ //NegativeX	 Left facing side (-x).
					VEC = float3(-1.0f,UV.y,-UV.x);
				}

				else if(face == 2.0f){ //PositiveY	 Upwards facing side (+y).
					VEC = float3(-UV.x,1.0f,-UV.y);
				}

				else if(face == 3.0f){ //NegativeY	 Downward facing side (-y).
					VEC = float3(-UV.x,-1.0f,UV.y);
				}

				else if(face == 4.0f){ //PositiveZ	 Forward facing side (+z).
					VEC = float3(-UV.x,UV.y,1.0f);
				}

				else if(face == 5.0f){ //NegativeZ	 Backward facing side (-z).
					VEC = float3(UV.x,UV.y,-1.0f);
				}

				else{
					VEC = float3(0.0f,0.0f,1.0f);
				}

		        return normalize(VEC);

		    }


			fixed2 GetSphericalMapping_VEC2UV(float3 vec, float mode) //Use for create LP map
			{
				fixed2 UV;

				UV.y = acos(-vec.y) * A_1D_PI; // y = 1 to -1, v = 0 to PI

				float P = abs(vec.x/vec.z);
				//float O = 0.0f;

				if(vec.x >= 0) {
					if(vec.z == 0.0f) {
						UV.x = 0.5f;
					}
					else if(vec.z < 0) {
						UV.x = (A_PI - atan(P)) * A_1D_PI;
					}
					else {
						UV.x = atan(P) * A_1D_PI;
					}

				}
				else { // X < 0  //phase
					if(vec.z == 0.0f) {
						UV.x = -0.5f;
					}
					else if(vec.z < 0) {
						UV.x = -(A_PI - atan(P)) * A_1D_PI;
					}
					else {
						UV.x = -atan(P) * A_1D_PI;
					}
				}

				UV.x = (UV.x + 1.0f) * 0.5f;

				
				if(mode > 0.9f){ //sky to cube
					UV.x = (1.0f - UV.x);
				}

				
				//{r}=\sqrt{x^2 + y^2 + z^2} 、
				//{\theta}=\arctan \left( \frac{\sqrt{x^2 + y^2}}{z} \right)=\arccos \left( {\frac{z}{\sqrt{x^2 + y^2 + z^2}}} \right) 、
				//{\phi}=\arctan \left( {\frac{y}{x}} \right) 

				return UV;
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
				//float2 UV = float2( 1 - i.uv.x , i.uv.y);
				float2 UV = i.uv;
				float4 result = tex2D( _MainTex,  GetSphericalMapping_VEC2UV( GetVec(UV, _Face), _Mode) );
				//float4 result = tex2D( _MainTex,  i.uv);
				//float4 result = texCUBE (_Cube, GetSphericalMapping_UV2VEC(i.uv, _Mode));
				//float4 result = float4(((float3)GetSphericalMapping_UV2VEC(i.uv) + 1)*0.5,1.0);//texCUBE (_Cube, (float3)GetSphericalMapping_UV2VEC(i.uv));
				if(_Gamma !=1.0f)
				{
					result.rgb = pow(result.rgb, _Gamma);
				}

				return result;

			}

	    ENDCG
	  	}

	}

Fallback off
}
