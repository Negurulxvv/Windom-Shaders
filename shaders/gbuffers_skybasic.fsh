#version 120

varying vec3 tintColor;

varying vec3 pos;

uniform vec3 skyColor;
uniform vec3 fogColor;
uniform vec3 upPosition;
uniform vec3 sunPosition;
uniform vec3 moonPosition;

uniform float frameTimeCounter;

uniform int worldTime;

#include "/lib/sky_gradient.glsl"

float timefract = worldTime;

float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
float TimeSunriseEnd  = ((clamp(timefract, 24000.0, 25000.0) - 24000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 5000.0)/5000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeSunsetEnd   = ((clamp(timefract, 8000.0, 12500.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12500.0, 12950.0) - 12500.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);

void main() {
                 
	float mix_fog = SkyGradient(upPosition, sunPosition, moonPosition, pos);

	vec3 noonFogColor = vec3(0.5, 0.76, 0.8)*1.2;
	vec3 sunsetSkyColor = vec3(0.1, 0.7, 1.0)*0.9;
	vec3 sunsetNostalgia = vec3(0.3, 0.1, 0.5)*0.5;
	vec3 sunsetNostalgia2 = vec3(0.3, 0.1, 0.5)*0.3;
	vec3 sunsetNostalgiaFog = vec3(0.9, 0.47, 0.1)*0.9;
	vec3 sunsetNostalgiaFog2 = vec3(1.7, 0.47, 0.1)*0.6;
	vec3 NostalgiaColor = vec3(0.1, 0.5, 1.0)*0.41;
	vec3 NostalgiaFogColor = vec3(0.1, 0.5, 1.0)*0.24;
	vec3 NostalgiaFog = mix(skyColor, fogColor, 0.1)*skyColor;

	vec3 customSkyColor = (skyColor*TimeSunrise + sunsetNostalgia2*TimeSunriseEnd + skyColor*TimeNoon + sunsetNostalgia*TimeSunset + sunsetNostalgia2*TimeSunsetEnd + NostalgiaColor*TimeMidnight);
	vec3 customFogColor = (NostalgiaFog*TimeSunrise + sunsetNostalgiaFog2*TimeSunriseEnd + noonFogColor*TimeNoon + sunsetNostalgiaFog*TimeSunset + sunsetNostalgiaFog2*TimeSunsetEnd + NostalgiaFogColor*TimeMidnight);

	gl_FragData[0] = vec4(tintColor, 1.0);
	gl_FragData[0].rgb = mix(customSkyColor, customFogColor, mix_fog);
	gl_FragData[1] = vec4(0.0, 0.0, 0.0, 1.0);
}