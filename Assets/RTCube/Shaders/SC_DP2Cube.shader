// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Dual-paraboloid to Cube (Two DP maps in one tex)
Shader "Hidden/Skycube/INT/SC_DP2Cube" {
	Properties {
		_RefDP("Dual-paraboloid map", 2D) = "" {} 
		_Face ("Face", float) = 0.0
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

			sampler2D _RefDP;
			float _Face;

			struct v2f {
				float4 pos : POSITION;
				float2 uv  : TEXCOORD0;

			};

			// Move it to Libs
			float3 GetVec(fixed2 UV, float face){

		        float3 VEC;
		        UV = -(UV * 2 - 1); // Range from 0 to 1 to 1 to -1 (since in unity UV is invert by directX UV)


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

		    /*
			float2 getDPUVByVec(float3 vec){
				float2 uv;
				if(vec.z > 0){// Front
					uv = vec.xy/(1 - vec.z);
					uv.x *= 0.5; // Move to left in texture
				}
				else{ // Back
					uv = - vec.xy/(1 + vec.z);
					uv.x = (uv.x * 0.5) + 0.5; // Move to right in texture
				}

				return uv;
			}*/

			float2 getDPUVByVec(float3 vec){
				float2 uv;
				if(vec.z < 0){// Front
					uv = vec.xy/(1 - vec.z);
					uv = (uv + 1) * 0.5; // Range from -1 to 1 to 0 to 1
					uv.x *= 0.5; // Move to left in texture
				}
				else{ // Back
					vec.y = -vec.y;
					uv = - vec.xy/(1 + vec.z);
					uv = (uv + 1) * 0.5; // Range from -1 to 1 to 0 to 1
					//uv.y = -uv.y;
					uv.x = (uv.x * 0.5) + 0.5; // Move to right in texture
				}

				return uv;
			}
			//

			v2f vert( appdata_img v ) 
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv =  v.texcoord.xy;	
				return o;
			}

			float4 frag(v2f i) : COLOR 
			{
				float4 result = tex2D(_RefDP, getDPUVByVec(GetVec(i.uv,_Face)));
				return result;
			}

	    ENDCG
	  	}

	}

Fallback off
}
