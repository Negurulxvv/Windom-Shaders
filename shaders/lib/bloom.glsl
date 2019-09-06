#define BloomAmount 1.00 //[0.25 0.50 0.75 1.00 1.25 1.50 1.75 2.00]

vec3 expandBloom(vec3 x){
	return x * x * x * x * 128.0;
}

vec3 bloom(vec3 color, vec2 coord){
	vec3 blur1 = expandBloom(texture2D(colortex1,coord/pow(2.0,2.0) + vec2(0.0,0.0)).rgb);
	vec3 blur2 = expandBloom(texture2D(colortex1,coord/pow(2.0,3.0) + vec2(0.0,0.26)).rgb);
	vec3 blur3 = expandBloom(texture2D(colortex1,coord/pow(2.0,4.0) + vec2(0.135,0.26)).rgb);
	vec3 blur4 = expandBloom(texture2D(colortex1,coord/pow(2.0,5.0) + vec2(0.2075,0.26)).rgb);
	vec3 blur5 = expandBloom(texture2D(colortex1,coord/pow(2.0,6.0) + vec2(0.135,0.3325)).rgb);
	vec3 blur6 = expandBloom(texture2D(colortex1,coord/pow(2.0,7.0) + vec2(0.160625,0.3325)).rgb);
	vec3 blur7 = expandBloom(texture2D(colortex1,coord/pow(2.0,8.0) + vec2(0.1784375,0.3325)).rgb);

	vec3 blur = (blur1 + blur2 + blur3 + blur4 + blur5 + blur6 + blur7) * 0.06;
	
	return mix(color,blur,0.16 * BloomAmount);
}