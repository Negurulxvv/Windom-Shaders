#version 120

#define Shadows

const int RGBA16                 = 1;             
const int gcolorFormat           =  RGBA16;  
const int colortex5Format        =  RGBA16;
#define shadowMapResolution 1024 //[1024 2048 4096]
const bool colortex5Clear = false;

uniform sampler2D gcolor;
uniform sampler2D gnormal;
uniform sampler2D gdepth;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;


uniform mat4 gbufferModelView;
uniform mat4 gbufferProjection;

uniform mat4 shadowModelView;

#include "/lib/poisson.glsl"

const int noiseTexResolution = 32;
const int noiseTextureResolution = 256; 

const bool 		shadowHardwareFiltering0 = true;

const bool 		shadowcolor0Mipmap = true;
const bool 		shadowcolor0Nearest = false;

#define ShadowColor


const float shadowDistance = 128.0; //[32.0 64.0 128.0 256.0 512.0 1024.0]
const float shadowMapBias = 0.85;

uniform sampler2D depthtex1;
uniform sampler2D depthtex0;
uniform sampler2D colortex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;
uniform sampler2D normals;


uniform int frameCounter;
uniform int isEyeInWater;
uniform int worldTime;

uniform float aspectRatio;
uniform float far;
uniform float frameTimeCounter;
uniform float near;
uniform float rainStrength;
uniform float timeAngle;
uniform float viewWidth;
uniform float viewHeight;

uniform vec3 skyColor;
uniform vec3 cameraPosition;

uniform mat4 shadowProjection;

varying vec3 lightVector;
varying vec4 texcoord;




/* DRAWBUFFERS:012 */

//Worldtime
float timefract = worldTime;

//Get the time of the day
float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);
vec2 wind[4] = vec2[4](vec2(abs(frameTimeCounter/1000.-0.5),abs(frameTimeCounter/1000.-0.5))+vec2(0.5),
					vec2(-abs(frameTimeCounter/1000.-0.5),abs(frameTimeCounter/1000.-0.5)),
					vec2(-abs(frameTimeCounter/1000.-0.5),-abs(frameTimeCounter/1000.-0.5)),
					vec2(abs(frameTimeCounter/1000.-0.5),-abs(frameTimeCounter/1000.-0.5)));

//Depth
float getDepth = 1.1;

//Get position of the camera in live
vec4 getCameraSpacePosition(in vec2 coord) {
    float depth = getDepth;
    vec4 positionNdcSpace = vec4(coord.s * 2.0 - 1.0, coord.t * 2.0 - 1.0, 2.0 * depth - 1.0, 1.0);
    vec4 positionCameraSpace = gbufferProjectionInverse * positionNdcSpace;

    return positionCameraSpace / positionCameraSpace.w;
}

//Get position of the world in live
vec4 getWorldSpacePosition(in vec2 coord) {
    vec4 positionCameraSpace = getCameraSpacePosition(coord);
    vec4 positionWorldSpace = gbufferModelViewInverse * positionCameraSpace;
    positionWorldSpace.xyz += cameraPosition;

    return positionWorldSpace;
}

#define SHADOW_MAP_BIAS 0.85
vec4 BiasShadowProjection(in vec4 projectedShadowSpacePosition) {

	vec2 pos = abs(projectedShadowSpacePosition.xy * 1.165);
	vec2 posSQ = pos*pos;
	
	float dist = pow(posSQ.x*posSQ.x*posSQ.x + posSQ.y*posSQ.y*posSQ.y, 1.0 / 6.0);

	float distortFactor = (1.0 - SHADOW_MAP_BIAS) + dist * SHADOW_MAP_BIAS;

	projectedShadowSpacePosition.xy /= distortFactor*0.92;



	return projectedShadowSpacePosition;
}

//What gets the shadow position
vec3 getShadowSpacePosition(in vec2 coord) {
    vec4 positionWorldSpace = getWorldSpacePosition(coord);

    positionWorldSpace.xyz -= cameraPosition;
    vec4 positionShadowSpace = shadowModelView * positionWorldSpace;
    positionShadowSpace = shadowProjection * positionShadowSpace;
    positionShadowSpace = BiasShadowProjection(positionShadowSpace);

    return positionShadowSpace.xyz * 0.5 + 0.5;
}

mat2 getRotationMatrix(in vec2 coord) {
    float rotationAmount = texture2D(
        noisetex,
        coord * vec2(
            viewWidth / noiseTextureResolution,
            viewHeight / noiseTextureResolution
        )
    ).r;
    return mat2(
        cos(rotationAmount), -sin(rotationAmount),
        sin(rotationAmount), cos(rotationAmount)
    );
}

#define PCSS_SAMPLE_COUNT 2

float getPenumbraWidth(in vec3 shadowCoord, in sampler2D shadowTexture, in mat2 rot) {
    float dFragment = shadowCoord.z; //distance from pixel to light
    float dBlocker = 0.0; //distance from blocker to light
    float penumbra = 0.0;
    
    float shadowMapSample; //duh
    float numBlockers = 0.0;

    float lightSize  = 225.0;
    float searchSize = lightSize / 260.0;

    for (int x = -PCSS_SAMPLE_COUNT; x < PCSS_SAMPLE_COUNT; x++) {
        for (int y = -PCSS_SAMPLE_COUNT; y < PCSS_SAMPLE_COUNT; y++) {
            vec2 sampleCoord = shadowCoord.st + rot * (vec2(x, y) * searchSize / (shadowMapResolution));
            shadowMapSample = texture2D(shadowTexture, sampleCoord, 2.0).r;

            dBlocker += shadowMapSample;
            numBlockers += 1.0;
        }
    }

    if(numBlockers > 0.0) {
		dBlocker /= numBlockers;
		penumbra = (dFragment - dBlocker) * lightSize;
	}

    return clamp(max(penumbra, 0.5), 0.0, lightSize);
}


//Lighting and shadow code
vec3 getShadowColor(in vec2 coord) {
    vec3 shadowCoord = getShadowSpacePosition(coord);
    vec3 shadowColor = vec3(0.0);
    mat2 rotationMatrix = getRotationMatrix(coord);
    float shadowDist = getPenumbraWidth(shadowCoord, shadowtex0, rotationMatrix);
    for(int i = 0; i < samplePoints.length(); i++) {
            vec2 offset = samplePoints[i] / shadowMapResolution;
            offset = rotationMatrix * offset;
            offset *= shadowDist;
            float shadowMapSample = texture2D(shadowtex0, shadowCoord.st + offset).r;
            float visibility = step(shadowCoord.z - shadowMapSample, 0.001);
            vec3 sunsetColor = vec3(1.0, 0.5, 0.4);
            vec3 dayColor = vec3(1.0);
            vec3 nightColor = vec3(0.0);
            vec3 colorSample = texture2D(shadowcolor0, shadowCoord.st + offset).rgb;
            vec3 mixShadowCol = mix(colorSample, vec3(sunsetColor*TimeSunrise + dayColor*TimeNoon + sunsetColor*TimeSunset + nightColor*TimeMidnight), visibility);
            shadowColor += mixShadowCol;
    }
    
    return vec3(shadowColor) / samplePoints.length();
    
}


vec3 calculateLitSurface(in vec3 color) {
    vec3 sunlightAmount = getShadowColor(texcoord.st);
    float ambientLighting = (0.55*TimeSunrise + 0.35*TimeNoon + 0.55*TimeSunset + 0.55*TimeMidnight); 


    return color * (sunlightAmount + ambientLighting);
}


void main() {

    getDepth = texture2D(depthtex1, texcoord.st).r;
    vec3 finalComposite = texture2D(colortex0, texcoord.st).rgb;
    vec3 finalCompositeNormal = texture2D(normals, texcoord.st).rgb;
    vec3 finalCompositeDepth = texture2D(depthtex1, texcoord.st).rgb;
    
    bool isTerrain = getDepth<1.0;

    #ifdef Shadows
    if (isTerrain) {
        finalComposite = calculateLitSurface(finalComposite);
    }
    #endif

    gl_FragData[0] = vec4(finalComposite, 1.0);
    gl_FragData[1] = vec4(finalCompositeNormal, 1.0);
    gl_FragData[2] = vec4(finalCompositeDepth, 1.0);

}