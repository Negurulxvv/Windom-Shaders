#version 120

varying vec4 texcoord;

uniform float viewWidth;
uniform float viewHeight;

varying vec4 color;

uniform int frameCounter;

#define TAA

vec2 jitter[8] = vec2[8](vec2( 0.125,-0.375),
							   vec2(-0.125, 0.375),
							   vec2( 0.625, 0.125),
							   vec2( 0.375,-0.625),
							   vec2(-0.625, 0.625),
							   vec2(-0.875,-0.125),
							   vec2( 0.375,-0.875),
							   vec2( 0.875, 0.875));
							   
vec2 taaJitter(vec2 coord, float w){
	return jitter[int(mod(frameCounter,8.0))]*(w/vec2(viewWidth,viewHeight)) + coord;
}

void main() {
    color = gl_Color;
    
    gl_Position = ftransform();


    #ifdef TAA
    gl_Position.xy = taaJitter(gl_Position.xy,gl_Position.w);
    #endif

    texcoord = gl_MultiTexCoord0;
}