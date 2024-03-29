#define MotionBlurAmount 0.75 //[0.25 0.50 0.75 1.00 1.25 1.50 1.75 2.00]

//Dithering from Jodie
float bayer2(vec2 a){
    a = floor(a);
    return fract( dot(a, vec2(.5, a.y * .75)) );
}

#define bayer4(a)   (bayer2( .5*(a))*.25+bayer2(a))
#define bayer8(a)   (bayer4( .5*(a))*.25+bayer2(a))
#define bayer16(a)  (bayer8( .5*(a))*.25+bayer2(a))
#define bayer32(a)  (bayer16(.5*(a))*.25+bayer2(a))
#define bayer64(a)  (bayer32(.5*(a))*.25+bayer2(a))
#define bayer128(a) (bayer64(.5*(a))*.25+bayer2(a))
#define bayer256(a) (bayer128(.5*(a))*.25+bayer2(a))

//CREDIT TO BSL MADE BY CAPT TATSU FOR MOST OF THE CODE!

vec3 motionBlur (vec3 color, float hand){
	if (hand < 0.5){
		float motionblur  = texture2D(depthtex1, texcoord.st).x;
		vec3 mblur = vec3(0.0);
		float mbwg = 0.0;
		float mbm = 0.0;
		vec2 pixel = 2.0/vec2(viewWidth,viewHeight);
		
		vec4 currentPosition = vec4(texcoord.x * 2.0 - 1.0, texcoord.y * 2.0 - 1.0, 2.0 * motionblur - 1.0, 1.0);
		
		vec4 fragposition = gbufferProjectionInverse * currentPosition;
		fragposition = gbufferModelViewInverse * fragposition;
		fragposition /= fragposition.w;
		fragposition.xyz += cameraPosition;
		
		vec4 previousPosition = fragposition;
		previousPosition.xyz -= previousCameraPosition;
		previousPosition = gbufferPreviousModelView * previousPosition;
		previousPosition = gbufferPreviousProjection * previousPosition;
		previousPosition /= previousPosition.w;

		vec2 velocity = (currentPosition - previousPosition).xy;
		velocity = velocity/(1.0+length(velocity))*MotionBlurAmount*0.02;
		
		vec2 coord = texcoord.st-velocity*(3.5+bayer64(gl_FragCoord.xy));
		for (int i = 0; i < 6; ++i, coord += velocity){
			vec2 coordb = clamp(coord,pixel,1.0-pixel);
			vec3 temp = texture2DLod(colortex0, coordb,0).rgb;
			mblur += temp;
			mbwg += 1.0;
		}
		mblur /= mbwg;

		return mblur;
	}
	else return color;
}