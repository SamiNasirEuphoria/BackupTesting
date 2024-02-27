// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/Skycube/INT/SC_Cube2IBL_Diffuse" {
	Properties {
		//_MainTex ("Base (RGBM)", 2D) = "black" {}
		//_MaxRange ("Max HDR Range", float) = 8.0
		//_Exp ("Exposure", float) = 1.0

		_Cube ("Cubemap", Cube) = "_Skybox" { TexGen CubeReflect }
		_AngleRange ("Angle", float) = 1.0 //o-1
		_Face ("Face", float) = 0.0 //0,1,2,3,4,5
		_Step ("Step", float) = 0.1 //0-1

	}
	
	Subshader 
	{
		Pass 
		{
			ZTest Always Cull Off ZWrite Off lighting off
			Fog { Mode off }      

			CGPROGRAM
			#pragma target 3.0
			//#pragma target 4.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma glsl
			
			//#pragma only_renderers d3d9
			#include "UnityCG.cginc"
			//#include "Assets/Shaders/Atom_Common_Libs.cginc"

			

			//sampler2D _MainTex;
			//half _MaxRange;
			//half _Exp;

			samplerCUBE _Cube;
			float _AngleRange;
			float _Face;
			float _Step;


			#define A_PI		3.14159265358//3.1415926535897932384626433832795

			float3 GetCubeVec(fixed2 UV, float face){

				float3 VEC;
				UV = UV * 2 - 1; // Range to -1 to 1

				 //DX10 Version Mode 4.0
/* Mode 4.0				switch( face ) {
					case 0.0 : //PositiveX	 Right facing side (+x).
						VEC = float3(1.0,UV.y,UV.x);
					break;

					case 1.0 : //NegativeX	 Left facing side (-x).
						VEC = float3(-1.0,UV.y,-UV.x);
					break;

					case 2.0 : //PositiveY	 Upwards facing side (+y).
						VEC = float3(-UV.x,1.0,-UV.y);
					break;

					case 3.0 : //NegativeY	 Downward facing side (-y).
						VEC = float3(-UV.x,-1.0,UV.y);
					break;

					case 4.0 : //PositiveZ	 Forward facing side (+z).
						VEC = float3(-UV.x,UV.y,1.0);
					break;

					case 5.0 : //NegativeZ	 Backward facing side (-z).
						VEC = float3(UV.x,UV.y,-1.0);
					break;

					default : 
						VEC = float3(0,0,1.0);
					break;
				}	
*/				
// Mode 3.0
				if(face == 0.0f){ //PositiveX	 Right facing side (+x).
					VEC = float3(1.0,UV.y,UV.x);
				}

				else if(face == 1.0f){ //NegativeX	 Left facing side (-x).
					VEC = float3(-1.0,UV.y,-UV.x);
				}

				else if(face == 2.0f){ //PositiveY	 Upwards facing side (+y).
					VEC = float3(-UV.x,1.0,-UV.y);
				}

				else if(face == 3.0f){ //NegativeY	 Downward facing side (-y).
					VEC = float3(-UV.x,-1.0,UV.y);
				}

				else if(face == 4.0f){ //PositiveZ	 Forward facing side (+z).
					VEC = float3(-UV.x,UV.y,1.0);
				}

				else if(face == 5.0f){ //NegativeZ	 Backward facing side (-z).
					VEC = float3(UV.x,UV.y,-1.0);
				}

				else{
					VEC = float3(0,0,1.0);
				}
//

				return normalize(VEC);

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
				float4 result = float4(0,0,0,1);
				float3 vecLookup = GetCubeVec(i.uv, _Face);
				float3 vecSampler = float3(0,0,0);
				_Step = max(0.001,_Step);
				if(_AngleRange >= 1.0f){
					//result = 1;
					result = texCUBElod (_Cube, float4(vecLookup,0) );
				}
				else{
					for(int n = 0; n < 6; n++){
						for(int y = 0; y < 1.0f; y+=_Step){
							for(int x = 0; x < 1.0f; x+=_Step){
								vecSampler = GetCubeVec(float2(x,y) , n);
								float power = max(0,dot(vecSampler, vecLookup));
								if(power >= _AngleRange){
									//result = 1;
									result += power * texCUBElod (_Cube, float4(vecSampler,0) );
								}
							}
						}
						
					}
				}
				

				//float4 c_rgbm = tex2D(_MainTex, i.uv);
				//float4 result = texCUBE (_Cube, GetSphericalMapping_UV2VEC(i.uv, _Mode));
				//float4 result = float4(((float3)GetSphericalMapping_UV2VEC(i.uv) + 1)*0.5,1.0);//texCUBE (_Cube, (float3)GetSphericalMapping_UV2VEC(i.uv));

				return result;

			}

	    ENDCG
	  	}

	}

Fallback off
}
