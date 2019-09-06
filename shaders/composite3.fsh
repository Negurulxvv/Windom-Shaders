#version 120

uniform sampler2D gaux1;
uniform sampler2D colortex0;
uniform sampler2D depthtex0;

uniform vec3 fogColor;
uniform vec3 skyColor;

uniform float far;
uniform float near;

varying vec4 texcoord;

uniform float frameTimeCounter;

uniform int worldTime;

#define CustomFog

uniform int isEyeInWater;

float timefract = worldTime;

float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
float TimeSunriseEnd  = ((clamp(timefract, 24000.0, 25000.0) - 24000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 5000.0)/5000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeSunsetEnd   = ((clamp(timefract, 8000.0, 12500.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12500.0, 12950.0) - 12500.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);


float     GetDepthLinear(in vec2 coord) {          
   return 2.0f * near * far / (far + near - (2.0f * texture2D(depthtex0, coord).x - 1.0f) * (far - near));
}

void main() {
    vec3 aux = texture2D(gaux1, texcoord.st).rgb;

    float iswater = float(aux.g > 0.04 && aux.g < 0.07);

    vec3 color = texture2D(colortex0, texcoord.st).rgb;

    float depth = texture2D(depthtex0, texcoord.st).r;

	vec3 noonFogColor = vec3(0.5, 0.76, 0.8)*1.2;
	vec3 sunsetNostalgiaFog = vec3(0.9, 0.47, 0.1)*0.9;
	vec3 sunsetNostalgiaFog2 = vec3(1.7, 0.47, 0.1)*0.6;
	vec3 NostalgiaFogColor = vec3(0.1, 0.5, 1.0)*0.24;
	vec3 NostalgiaFog = mix(skyColor, fogColor, 0.1)*skyColor;

    vec3 customFogColor = (NostalgiaFog*TimeSunrise + sunsetNostalgiaFog2*TimeSunriseEnd + noonFogColor*TimeNoon + sunsetNostalgiaFog*TimeSunset + sunsetNostalgiaFog2*TimeSunsetEnd + NostalgiaFogColor*TimeMidnight);
    vec3 waterfogColor = pow(vec3(0, 255, 355) / 255.0, vec3(2.2));

    vec3 lavafogColor = pow(vec3(195, 87, 0) / 255.0, vec3(2.2));

    bool isTerrain = depth < 1.0;

    if (isEyeInWater == 1) {
        color = mix(color, waterfogColor, min(GetDepthLinear(texcoord.st) * 2.3 / far, 1.0));
    }

    if (isEyeInWater == 2) {
        color = mix(color, lavafogColor, min(GetDepthLinear(texcoord.st) * 2.3 / far, 1.0));
    }

    #ifdef CustomFog
    if (isTerrain) color = mix(color, customFogColor, min(GetDepthLinear(texcoord.st) * 1.6 / far, 1.0));
    #endif


    gl_FragData[0] = vec4(color, 1.0);


}