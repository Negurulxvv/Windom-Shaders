#version 120
#extension GL_ARB_shader_texture_lod : enable

//TAA code was used from BSL and Chocapic.

#define TAA

const int RGBA16                 = 1;   
const int colortex5Format        =  RGBA16;
const bool colortex5Clear = false;

uniform float viewHeight;
uniform float viewWidth;
uniform sampler2D colortex0;
uniform sampler2D depthtex0;

varying vec4 texcoord;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

#include "/lib/taa.glsl"

float getDepth = 0.0;

void main() {

    getDepth = texture2D(depthtex0, texcoord.st).r;

    vec3 color = texture2D(colortex0,texcoord.st).rgb;

	#ifdef TAA
	vec2 prvcoord = reprojection(vec3(texcoord.st,texture2D(depthtex1,texcoord.st).r));
	vec2 view = vec2(viewWidth,viewHeight);
	vec3 tempcolor = neighbourhoodClamping(color,texture2D(colortex5,texcoord.xy).rgb,1.0/view);
	
	vec2 velocity = (texcoord.st-prvcoord.xy)*view;
	float blendfactor = float(prvcoord.x > 0.0 && prvcoord.x < 1.0 && prvcoord.y > 0.0 && prvcoord.y < 1.0);
	blendfactor *= clamp(1.0-sqrt(length(velocity))/2.0,0.0,1.0)*0.31+0.61;
	
	tempcolor = mix(color,tempcolor,blendfactor);
	#endif

    bool isTerrain = getDepth < 1.0;
/*DRAWBUFFERS:05*/
    #ifdef TAA
        gl_FragData[0] = vec4(tempcolor, 1.0);
        gl_FragData[1] = vec4(tempcolor, 1.0);
    #else
/*DRAWBUFFERS:0*/
    gl_FragData[0] = vec4(color, 1.0);
    #endif
}