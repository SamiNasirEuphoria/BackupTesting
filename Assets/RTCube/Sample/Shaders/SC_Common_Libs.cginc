//#include "UnityCG.cginc"

//#pragma glsl

#ifndef A_1D_2PI
#define A_1D_2PI		0.1591549431f//0.15915494309189533577
#endif

#ifndef A_2PI_360
#define A_2PI_360		0.01745329252f//0.017453292519943295769222222222222
#endif

#ifndef A_PI
#define A_PI		3.14159265358f//3.1415926535897932384626433832795
#endif

#ifndef A_1D_PI
#define A_1D_PI		0.31830988618f//0.31830988618379067153776752674503
#endif


#ifndef A_SIN45
#define A_SIN45		0.70710678f//0.70710678118654752440084436210485
#endif



#define A_16		0.166666666f
#define A_33		0.333333333f
#define A_66		0.666666666f
#define A_83		0.833333333f


#define A_L2G		0.4545454545f
#define A_G2L		2.2f


//Common Library
half3 GetVec(fixed2 UV, int face){

    half3 VEC;
    UV = UV * 2 - 1; // Range to -1 to 1


    if(face == 0){ //Positivec	 Right facing side (+x).
		VEC = half3(1.0,UV.y,UV.x);
	}

	else if(face == 1){ //Negativec	 Left facing side (-x).
		VEC = half3(-1.0f,UV.y,-UV.x);
	}

	else if(face == 2){ //PositiveY	 Upwards facing side (+y).
		VEC = half3(-UV.x,1.0f,-UV.y);
	}

	else if(face == 3){ //NegativeY	 Downward facing side (-y).
		VEC = half3(-UV.x,-1.0f,UV.y);
	}

	else if(face == 4){ //PositiveZ	 Forward facing side (+z).
		VEC = half3(-UV.x,UV.y,1.0f);
	}

	else if(face == 5){ //NegativeZ	 Backward facing side (-z).
		VEC = half3(UV.x,UV.y,-1.0f);
	}

	else{
		VEC = half3(0.0f,0.0f,1.0f);
	}

    return normalize(VEC);

}



fixed2 GetSphericalMapping_VEC2UV(half3 vec, half4 adj) //Use for create LP map
{
	fixed2 UV;
	vec= normalize(vec);
	UV.y = acos(-vec.y) * A_1D_PI; // y = 1 to -1, v = 0 to PI
	half P = abs(vec.x/vec.z);

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

	UV.x = UV.x * adj.x + adj.y;
	UV.y = UV.y * adj.z + adj.w;



	return UV;
}




//Inverse mapping for light probe map (poles space)
fixed2 GetLightProbeMapping_VEC2UV(half3 vec, half4 adj) // Use for reflection and lit mapping
{
	fixed2 UV;
	fixed3 WN = normalize(vec);

	half th_uv = acos(WN.z) * A_1D_PI;
	half phi_arc = atan(WN.y/WN.x);
	if(WN.x > 0)
	{
		UV.x = th_uv * cos(phi_arc);
		UV.y = th_uv * sin(phi_arc);
	}
	else
	{
		UV.x = th_uv * -cos(phi_arc);
		UV.y = th_uv * sin(-phi_arc);
	}

	
	UV = (UV + 1.0f) * 0.5f;

	UV.x = UV.x * adj.x + adj.y;
	UV.y = UV.y * adj.z + adj.w;

	return UV;
}

half Linear2Gamma( half val)
{
	return pow(val, A_L2G);
}

half3 Linear2Gamma( half3 val)
{
	return pow(val, A_L2G);
}

half Gamma2Linear( half val)
{
	return pow(val, A_G2L);
}

half3 Gamma2Linear( half3 val)
{
	return pow(val, A_G2L);
}


half3 DecodeRGBM(half4 rgbm, half maxRange, half ev)
{
    return Gamma2Linear(rgbm.rgb * (rgbm.a * maxRange) * ev );
}


half3 getScaleVec(half3 vec, half one)
{
	return (1.0f/one) * vec;
}


half3 GetFaceUV(half3 vec) {

	half2 uv = -1;
	half face = -1;
	half3 uvVec = 0;
	vec = normalize(vec);
	half range = 1.0f;
	half scale = 1.0f;
	//left 
	if(vec.x <= -0.5f) {
		uvVec = getScaleVec(vec, abs(vec.x));
		if(abs(uvVec.y) <= range && abs(uvVec.z) <= range){
			uv.x = uvVec.z;
			uv.y = uvVec.y;
			uv = (uv + scale) * 0.5f;
			face = 1;
		}
		
	}

	//right 
	if(vec.x >= 0.5f) {
		uvVec = getScaleVec(vec, abs(vec.x));
		if(abs(uvVec.y) <= range && abs(uvVec.z) <= range){
			uv.x = -uvVec.z;
			uv.y = uvVec.y;
			uv = (uv + scale) * 0.5f;
			face = 0;
		}
	}

	//top 
	if(vec.y >= 0.5f) {
		uvVec = getScaleVec(vec, abs(vec.y));
		if(abs(uvVec.x) <= range && abs(uvVec.z) <= range){
			uv.x = uvVec.x;
			uv.y = -uvVec.z;
			uv = (uv + scale) * 0.5f;
			face = 2;
		}
	}

	//bottom 
	if(vec.y <= -0.5f) {
		uvVec = getScaleVec(vec, abs(vec.y));
		if(abs(uvVec.x) <= range && abs(uvVec.z) <= range){
			uv.x = uvVec.x;
			uv.y = uvVec.z;
			uv = (uv + scale) * 0.5f;
			face = 3;
		}
	}

	//front 
	if(vec.z >= 0.5f) {
		uvVec = getScaleVec(vec, abs(vec.z));
		if(abs(uvVec.x) <= range && abs(uvVec.y) <= range){
			uv.x = uvVec.x;
			uv.y = uvVec.y;
			uv = (uv + scale) * 0.5f;
			face = 4;
		}
	}
	//back 
	if(vec.z <= -0.5f) {
		uvVec = getScaleVec(vec, abs(vec.z));
		if(abs(uvVec.x) <= range && abs(uvVec.y) <= range){
			uv.x = -uvVec.x;
			uv.y = uvVec.y;
			uv = (uv + scale) * 0.5f;
			face = 5;
		}
	}

	return half3(uv,face);

}

fixed getScaleRange(fixed val, fixed scale, fixed offset)
{
	return val * scale + offset;
}


fixed2 GetHorizontalCrossMapping_VEC2UV(half3 vec, half4 adj) {
	//h:w = 4:3 Horizontal Cross -|--
	half3 uvInfo = 0;
	uvInfo = GetFaceUV(vec);
	if(uvInfo.z == -1){
		uvInfo.x = uvInfo.y = -1;
	}

	//left 1
	if(uvInfo.z == 1){
		uvInfo.x = getScaleRange(uvInfo.x, 0.25*adj.x, 0.0f+adj.y);
		uvInfo.y = getScaleRange(uvInfo.y, A_33*adj.z, A_33+adj.w); 
	}

	//right 0
	else if(uvInfo.z == 0){
		uvInfo.x = getScaleRange(uvInfo.x, 0.25*adj.x, 0.5f+adj.y);
		uvInfo.y = getScaleRange(uvInfo.y, A_33*adj.z, A_33+adj.w); 
	}

	//top 2
	else if(uvInfo.z == 2){
		uvInfo.x = getScaleRange(uvInfo.x, 0.25*adj.x, 0.25f+adj.y); 
		uvInfo.y = getScaleRange(uvInfo.y, A_33*adj.z, A_66+adj.w);

	}

	//bottom 3
	else if(uvInfo.z == 3){
		uvInfo.x = getScaleRange(uvInfo.x, 0.25*adj.x, 0.25f+adj.y); 
		uvInfo.y = getScaleRange(uvInfo.y, A_33*adj.z, 0.0f+adj.w);
	}

	//front 4
	else if(uvInfo.z == 4){
		uvInfo.x = getScaleRange(uvInfo.x, 0.25*adj.x, 0.25f+adj.y);
		uvInfo.y = getScaleRange(uvInfo.y, A_33*adj.z, A_33+adj.w);
	}
	//back 5
	else if(uvInfo.z == 5){
		uvInfo.x = getScaleRange(uvInfo.x, 0.25*adj.x, 0.75f+adj.y);
		uvInfo.y = getScaleRange(uvInfo.y, A_33*adj.z, A_33+adj.w); 
	}

	return fixed2(uvInfo.x, uvInfo.y);

}

fixed2 GetVerticalCrossMapping_VEC2UV(half3 vec, half4 adj) {
	//h:w = 3:4 Vertical Cross
	half3 uvInfo = 0;
	uvInfo = GetFaceUV(vec);
	if(uvInfo.z == -1){
		uvInfo.x = uvInfo.y = -1;
	}
	//left 1
	if(uvInfo.z == 1){
		uvInfo.x = getScaleRange(uvInfo.x, A_33*adj.x, 0.0f+adj.y);
		uvInfo.y = getScaleRange(uvInfo.y, 0.25f*adj.z, 0.5f+adj.w); 
	}

	//right 0
	else if(uvInfo.z == 0){
		uvInfo.x = getScaleRange(uvInfo.x, A_33*adj.x, A_66+adj.y);
		uvInfo.y = getScaleRange(uvInfo.y, 0.25f*adj.z, 0.5f+adj.w); 
	}

	//top 2
	else if(uvInfo.z == 2){
		uvInfo.x = getScaleRange(uvInfo.x, A_33*adj.x, A_33+adj.y); 
		uvInfo.y = getScaleRange(uvInfo.y, 0.25f*adj.z, 0.75f+adj.w);

	}

	//bottom 3
	else if(uvInfo.z == 3){
		uvInfo.x = getScaleRange(uvInfo.x, A_33*adj.x, A_33+adj.y);
		uvInfo.y = getScaleRange(uvInfo.y, 0.25f*adj.z, 0.25f+adj.w);

	}

	//front 4
	else if(uvInfo.z == 4){
		uvInfo.x = getScaleRange(uvInfo.x, A_33*adj.x, A_33+adj.y);
		uvInfo.y = getScaleRange(uvInfo.y, 0.25f*adj.z, 0.5f+adj.w);

	}
	//back 5
	else if(uvInfo.z == 5){
		uvInfo.x = getScaleRange((1.0f-uvInfo.x), A_33*adj.x, A_33+adj.y);
		uvInfo.y = getScaleRange((1.0f-uvInfo.y), 0.25f*adj.z, 0.0f+adj.w);
	}


	return fixed2(uvInfo.x, uvInfo.y);
}

fixed2 GetNvidiaCubeMapping_VEC2UV(half3 vec, half4 adj) {

	//h:w = 6:1 (NVidia) right|left|top|bottom|front|back
	half3 uvInfo = 0;
	uvInfo = GetFaceUV(vec);
	if(uvInfo.z == -1){
		uvInfo.x = uvInfo.y = -1;
	}
	//left 1
	if(uvInfo.z == 1){
		uvInfo.x = getScaleRange(uvInfo.x, A_16*adj.x, A_16+adj.y);
	}

	//right 0
	else if(uvInfo.z == 0){
		uvInfo.x = getScaleRange(uvInfo.x, A_16*adj.x, 0.0f+adj.y);
	}

	//top 2
	else if(uvInfo.z == 2){
		uvInfo.x = getScaleRange(uvInfo.x, A_16*adj.x, A_33+adj.y);
	}

	//bottom 3
	else if(uvInfo.z == 3){
		uvInfo.x = getScaleRange(uvInfo.x, A_16*adj.x, 0.5f+adj.y);
	}

	//front 4
	else if(uvInfo.z == 4){
		uvInfo.x = getScaleRange(uvInfo.x, A_16*adj.x, A_66+adj.y);
	}
	//back 5
	else if(uvInfo.z == 5){
		uvInfo.x = getScaleRange(uvInfo.x, A_16*adj.x, A_83+adj.y);
	}

	uvInfo.y = uvInfo.y * adj.z + adj.w;

	return fixed2(uvInfo.x, uvInfo.y);
}

fixed2 GetXSICubeMapping_VEC2UV(half3 vec, half4 adj) {

	//h:w = 6:1 (XSI strip) right->|left<-|back|front<>|bottom|top%
	half3 uvInfo = 0;
	uvInfo = GetFaceUV(vec);
	if(uvInfo.z == -1){
		uvInfo.x = uvInfo.y = -1;
	}
	//left 1
	if(uvInfo.z == 1){
		uvInfo.x = getScaleRange(uvInfo.x, A_16*adj.x, A_16+adj.y); //0.16666666
	}

	//right 0
	else if(uvInfo.z == 0){
		uvInfo.x = getScaleRange(uvInfo.x, A_16*adj.x, 0.0f+adj.y);
	}

	//top 2
	else if(uvInfo.z == 2){
		uvInfo.x = getScaleRange(uvInfo.x, A_16*adj.x, A_83+adj.y);
	}

	//bottom 3
	else if(uvInfo.z == 3){
		uvInfo.x = getScaleRange(uvInfo.x, A_16*adj.x, A_66+adj.y);
	}

	//front 4
	else if(uvInfo.z == 4){
		uvInfo.x = getScaleRange(uvInfo.x, A_16*adj.x, 0.5f+adj.y);
	}
	//back 5
	else if(uvInfo.z == 5){
		uvInfo.x = getScaleRange(uvInfo.x, A_16*adj.x, A_33+adj.y);
	}

	uvInfo.y = uvInfo.y * adj.z + adj.w;

	return fixed2(uvInfo.x, uvInfo.y);
}




//LDR Cube
/*
half4 SC_texCUBEMap(sampler2D tex, half3 dir, int type = 0, half4 adj = half4(1,0,1,0)) {
	half4 c = half4((half3)0,1);
	half2 uv = 0;

	if(type == 0) { //1: Horizontal Cross Panorama
		uv = GetHorizontalCrossMapping_VEC2UV(dir, adj);
	}

	else if(type == 1) { //2: Vertical Cross Panorama
		uv = GetVerticalCrossMapping_VEC2UV(dir, adj);
	}

	else if(type == 2) { //3: NVidia DDS Cubemap
		uv = GetNvidiaCubeMapping_VEC2UV(dir, adj);
	}

	else if(type == 3) { //4: XSI Cubemap
		uv = GetXSICubeMapping_VEC2UV(dir, adj);
	}

	else if(type == 4) { //5: Spherical Map Panorama
		uv = GetSphericalMapping_VEC2UV(dir, adj);
	}

	else if(type == 5) { //6: Light Probe Panorama
		uv = GetLightProbeMapping_VEC2UV(dir, adj);
	}

	else {
		c = 0;
		return c;
	}

	c = tex2Dlod(tex, float4(uv,0,0) ).rgba;

	if(uv.x < 0 || uv.y < 0){
		c = 0;
	}
	return c;
	
} */



half4 SC_texCUBEMap(sampler2D tex, half3 dir, half4 adj = half4(1,0,1,0)) {
	half4 c = half4((half3)0,1);
	half2 uv = 0;

#if defined(SC_HC)  //1: Horizontal Cross Panorama
		uv = GetHorizontalCrossMapping_VEC2UV(dir, adj);
#elif defined(SC_VC)  //2: Vertical Cross Panorama
		uv = GetVerticalCrossMapping_VEC2UV(dir, adj);
#elif defined(SC_NV)  //3: NVidia DDS Cubemap
		uv = GetNvidiaCubeMapping_VEC2UV(dir, adj);
#elif defined(SC_XSI)  //4: XSI Cubemap
		uv = GetXSICubeMapping_VEC2UV(dir, adj);
#elif defined(SC_SP)  //5: Spherical Map Panorama
		uv = GetSphericalMapping_VEC2UV(dir, adj);
#elif defined(SC_LP) //6: Light Probe Panorama
		uv = GetLightProbeMapping_VEC2UV(dir, adj);
#else
		c = 0;
		return c;
#endif

	c = tex2Dlod(tex, float4(uv,0,0) ).rgba;

	if(uv.x < 0 || uv.y < 0){
		c = 0;
	}
	return c;
	
}


half4 SC_texCUBEMap_HC(sampler2D tex, half3 dir, half4 adj = half4(1,0,1,0)) {
	half4 c = half4((half3)0,1);
	half2 uv = 0;
	uv = GetHorizontalCrossMapping_VEC2UV(dir, adj);
	c = tex2Dlod(tex, float4(uv,0,0) ).rgba;
	if(uv.x < 0 || uv.y < 0)
		c = 0;
	return c;
}


half4 SC_texCUBEMap_VC(sampler2D tex, half3 dir, half4 adj = half4(1,0,1,0)) {
	half4 c = half4((half3)0,1);
	half2 uv = 0;
	uv = GetVerticalCrossMapping_VEC2UV(dir, adj);
	c = tex2Dlod(tex, float4(uv,0,0) ).rgba;
	if(uv.x < 0 || uv.y < 0)
		c = 0;
	return c;
}

half4 SC_texCUBEMap_NV(sampler2D tex, half3 dir, half4 adj = half4(1,0,1,0)) {
	half4 c = half4((half3)0,1);
	half2 uv = 0;
	uv = GetNvidiaCubeMapping_VEC2UV(dir, adj);
	c = tex2Dlod(tex, float4(uv,0,0) ).rgba;
	if(uv.x < 0 || uv.y < 0)
		c = 0;
	return c;
}

half4 SC_texCUBEMap_XSI(sampler2D tex, half3 dir, half4 adj = half4(1,0,1,0)) {
	half4 c = half4((half3)0,1);
	half2 uv = 0;
	uv = GetXSICubeMapping_VEC2UV(dir, adj);
	c = tex2Dlod(tex, float4(uv,0,0) ).rgba;
	if(uv.x < 0 || uv.y < 0)
		c = 0;
	return c;
}

half4 SC_texCUBEMap_SP(sampler2D tex, half3 dir, half4 adj = half4(1,0,1,0)) {
	half4 c = half4((half3)0,1);
	half2 uv = 0;
	uv = GetSphericalMapping_VEC2UV(dir, adj);
	c = tex2Dlod(tex, float4(uv,0,0) ).rgba;
	if(uv.x < 0 || uv.y < 0)
		c = 0;
	return c;
}

half4 SC_texCUBEMap_LP(sampler2D tex, half3 dir, half4 adj = half4(1,0,1,0)) {
	half4 c = half4((half3)0,1);
	half2 uv = 0;
	uv = GetLightProbeMapping_VEC2UV(dir, adj);
	c = tex2Dlod(tex, float4(uv,0,0) ).rgba;
	if(uv.x < 0 || uv.y < 0)
		c = 0;
	return c;
}



//HDR Tex

half4 SC_tex2DRGBM(sampler2D tex, half2 uv, half range, half ev = 1) {
	half4 col = 1;
	col.rgb = DecodeRGBM( tex2D (tex, uv).rgba, range, ev );

	return col;
}


//HDR Cube

//RGBM Encode//
half4 SC_texCUBERGBM(samplerCUBE cube, half3 dir, half range, half ev = 1) {
	half4 col = 1;
	col.rgb = DecodeRGBM( texCUBE (cube, dir).rgba, range, ev );

	return col;
}


//RGBM Encode w glossiness//
half4 SC_texCUBERGBM(samplerCUBE cube, half3 dir, half range, half ev , int miplevel) {
	half4 col = 1;
	col.rgb = DecodeRGBM( texCUBElod (cube, float4(dir, miplevel)).rgba, range, ev );

	return col;
}



/*
half4 SC_texCUBEMapRGBM(sampler2D tex, half3 dir, half range, half ev = 1,int type = 0, half4 adj = half4(1,0,1,0)) {
	half4 c = 1;
	c.rgb = DecodeRGBM( SC_texCUBEMap(tex,dir,type,adj).rgba, range, ev );
	
	return c;
}
*/
half4 SC_texCUBEMapRGBM(sampler2D tex, half3 dir, half range, half ev = 1, half4 adj = half4(1,0,1,0)) {
	half4 col = 1;
	col.rgb = DecodeRGBM( SC_texCUBEMap(tex,dir,adj).rgba, range, ev );
	
	return col;
}

//////////

half4 SC_texCUBEMapRGBM_HC(sampler2D tex, half3 dir, half range, half ev = 1, half4 adj = half4(1,0,1,0)) {
	half4 col = 1;
	col.rgb = DecodeRGBM( SC_texCUBEMap_HC(tex,dir,adj).rgba, range, ev );
	
	return col;
}

half4 SC_texCUBEMapRGBM_VC(sampler2D tex, half3 dir, half range, half ev = 1, half4 adj = half4(1,0,1,0)) {
	half4 col = 1;
	col.rgb = DecodeRGBM( SC_texCUBEMap_VC(tex,dir,adj).rgba, range, ev );
	
	return col;
}

half4 SC_texCUBEMapRGBM_NV(sampler2D tex, half3 dir, half range, half ev = 1, half4 adj = half4(1,0,1,0)) {
	half4 col = 1;
	col.rgb = DecodeRGBM( SC_texCUBEMap_NV(tex,dir,adj).rgba, range, ev );
	
	return col;
}

half4 SC_texCUBEMapRGBM_XSI(sampler2D tex, half3 dir, half range, half ev = 1, half4 adj = half4(1,0,1,0)) {
	half4 col = 1;
	col.rgb = DecodeRGBM( SC_texCUBEMap_XSI(tex,dir,adj).rgba, range, ev );
	
	return col;
}

half4 SC_texCUBEMapRGBM_SP(sampler2D tex, half3 dir, half range, half ev = 1, half4 adj = half4(1,0,1,0)) {
	half4 col = 1;
	col.rgb = DecodeRGBM( SC_texCUBEMap_SP(tex,dir,adj).rgba, range, ev );
	
	return col;
}

//HDR (RGBM Encode) Light Probe Panorama Cubemap
half4 SC_texCUBEMapRGBM_LP(sampler2D tex, half3 dir, half range, half ev = 1, half4 adj = half4(1,0,1,0)) {
	half4 col = 1;
	col.rgb = DecodeRGBM( SC_texCUBEMap_LP(tex,dir,adj).rgba, range, ev );
	
	return col;
}






//Skybox/////////////////////////////////////////////////////////////////////////////////

fixed2 GetHorizontalCrossMapping_UV2UV(int face, half2 uv, half4 adj) {
	//h:w = 4:3 Horizontal Cross -|--
	half2 uvOut = uv;
	if(face == -1){
		uvOut.x = uvOut.y = -1;
	}

	//left 1
	if(face == 1){
		uvOut.x = getScaleRange(uvOut.x, 0.25*adj.x, 0.0f+adj.y);
		uvOut.y = getScaleRange(uvOut.y, A_33*adj.z, A_33+adj.w); 
	}

	//right 0
	else if(face == 0){
		uvOut.x = getScaleRange(uvOut.x, 0.25*adj.x, 0.5f+adj.y);
		uvOut.y = getScaleRange(uvOut.y, A_33*adj.z, A_33+adj.w); 
	}

	//top 2
	else if(face == 2){
		uvOut.x = getScaleRange(uvOut.x, 0.25*adj.x, 0.25f+adj.y); 
		uvOut.y = getScaleRange(uvOut.y, A_33*adj.z, A_66+adj.w);

	}

	//bottom 3
	else if(face == 3){
		uvOut.x = getScaleRange(uvOut.x, 0.25*adj.x, 0.25f+adj.y); 
		uvOut.y = getScaleRange(uvOut.y, A_33*adj.z, 0.0f+adj.w);
	}

	//front 4
	else if(face == 4){
		uvOut.x = getScaleRange(uvOut.x, 0.25*adj.x, 0.25f+adj.y);
		uvOut.y = getScaleRange(uvOut.y, A_33*adj.z, A_33+adj.w);
	}
	//back 5
	else if(face == 5){
		uvOut.x = getScaleRange(uvOut.x, 0.25*adj.x, 0.75f+adj.y);
		uvOut.y = getScaleRange(uvOut.y, A_33*adj.z, A_33+adj.w); 
	}

	return fixed2(uvOut.x, uvOut.y);

}


fixed2 GetVerticalCrossMapping_UV2UV(int face, half2 uv, half4 adj) {
	//h:w = 3:4 Vertical Cross
	half2 uvOut = uv;
	if(face == -1){
		uvOut.x = uvOut.y = -1;
	}
	//left 1
	if(face == 1){
		uvOut.x = getScaleRange(uvOut.x, A_33*adj.x, 0.0f+adj.y);
		uvOut.y = getScaleRange(uvOut.y, 0.25f*adj.z, 0.5f+adj.w); 
	}

	//right 0
	else if(face == 0){
		uvOut.x = getScaleRange(uvOut.x, A_33*adj.x, A_66+adj.y);
		uvOut.y = getScaleRange(uvOut.y, 0.25f*adj.z, 0.5f+adj.w); 
	}

	//top 2
	else if(face == 2){
		uvOut.x = getScaleRange(uvOut.x, A_33*adj.x, A_33+adj.y); 
		uvOut.y = getScaleRange(uvOut.y, 0.25f*adj.z, 0.75f+adj.w);

	}

	//bottom 3
	else if(face == 3){
		uvOut.x = getScaleRange(uvOut.x, A_33*adj.x, A_33+adj.y);
		uvOut.y = getScaleRange(uvOut.y, 0.25f*adj.z, 0.25f+adj.w);

	}

	//front 4
	else if(face == 4){
		uvOut.x = getScaleRange(uvOut.x, A_33*adj.x, A_33+adj.y);
		uvOut.y = getScaleRange(uvOut.y, 0.25f*adj.z, 0.5f+adj.w);

	}
	//back 5
	else if(face == 5){
		uvOut.x = getScaleRange((1.0f-uvOut.x), A_33*adj.x, A_33+adj.y);
		uvOut.y = getScaleRange((1.0f-uvOut.y), 0.25f*adj.z, 0.0f+adj.w);
	}


	return fixed2(uvOut.x, uvOut.y);
}

fixed2 GetNvidiaCubeMapping_UV2UV(int face, half2 uv, half4 adj) {

	//h:w = 6:1 (NVidia) right|left|top|bottom|front|back
	half2 uvOut = uv;
	if(face == -1){
		uvOut.x = uvOut.y = -1;
	}
	//left 1
	if(face == 1){
		uvOut.x = getScaleRange(uvOut.x, A_16*adj.x, A_16+adj.y);
	}

	//right 0
	else if(face == 0){
		uvOut.x = getScaleRange(uvOut.x, A_16*adj.x, 0.0f+adj.y);
	}

	//top 2
	else if(face == 2){
		uvOut.x = getScaleRange(uvOut.x, A_16*adj.x, A_33+adj.y);
	}

	//bottom 3
	else if(face == 3){
		uvOut.x = getScaleRange(uvOut.x, A_16*adj.x, 0.5f+adj.y);
	}

	//front 4
	else if(face == 4){
		uvOut.x = getScaleRange(uvOut.x, A_16*adj.x, A_66+adj.y);
	}
	//back 5
	else if(face == 5){
		uvOut.x = getScaleRange(uvOut.x, A_16*adj.x, A_83+adj.y);
	}

	uvOut.y = uvOut.y * adj.z + adj.w;

	return fixed2(uvOut.x, uvOut.y);
}

fixed2 GetXSICubeMapping_UV2UV(int face, half2 uv, half4 adj) {

	//h:w = 6:1 (XSI strip) right->|left<-|back|front<>|bottom|top%
	half2 uvOut = uv;
	if(face == -1){
		uvOut.x = uvOut.y = -1;
	}
	//left 1
	if(face == 1){
		uvOut.x = getScaleRange(uvOut.x, A_16*adj.x, A_16+adj.y); //0.16666666
	}

	//right 0
	else if(face == 0){
		uvOut.x = getScaleRange(uvOut.x, A_16*adj.x, 0.0f+adj.y);
	}

	//top 2
	else if(face == 2){
		uvOut.x = getScaleRange(uvOut.x, A_16*adj.x, A_83+adj.y);
	}

	//bottom 3
	else if(face == 3){
		uvOut.x = getScaleRange(uvOut.x, A_16*adj.x, A_66+adj.y);
	}

	//front 4
	else if(face == 4){
		uvOut.x = getScaleRange(uvOut.x, A_16*adj.x, 0.5f+adj.y);
	}
	//back 5
	else if(face == 5){
		uvOut.x = getScaleRange(uvOut.x, A_16*adj.x, A_33+adj.y);
	}

	uvOut.y = uvOut.y * adj.z + adj.w;

	return fixed2(uvOut.x, uvOut.y);
}


//LDR

fixed2 SC_GetSkyBoxUV(int face, half2 uv, half4 adj = half4(1,0,1,0)) {

#if defined(SC_HC)  //1: Horizontal Cross Panorama
		return GetHorizontalCrossMapping_UV2UV(face, uv, adj);
#elif defined(SC_VC)  //2: Vertical Cross Panorama
		return GetVerticalCrossMapping_UV2UV(face, uv, adj);
#elif defined(SC_NV)  //3: NVidia DDS Cubemap
		return GetNvidiaCubeMapping_UV2UV(face, uv, adj);
#elif defined(SC_XSI)  //4: XSI Cubemap
		return GetXSICubeMapping_UV2UV(face, uv, adj);
#else
		return uv;
#endif
	
}


//HDR


//Postprocess




