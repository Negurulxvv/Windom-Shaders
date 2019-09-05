#version 120

uniform sampler2D gaux1;
uniform sampler2D colortex0;
uniform sampler2D depthtex0;

uniform vec3 fogColor;

uniform float far;
uniform float near;

varying vec4 texcoord;

uniform float frameTimeCounter;

uniform int worldTime;

#define CustomFog

uniform int isEyeInWater;

float timefract = worldTime;

float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);
vec2 wind[4] = vec2[4](vec2(abs(frameTimeCounter/1000.-0.5),abs(frameTimeCounter/1000.-0.5))+vec2(0.5),
					vec2(-abs(frameTimeCounter/1000.-0.5),abs(frameTimeCounter/1000.-0.5)),
					vec2(-abs(frameTimeCounter/1000.-0.5),-abs(frameTimeCounter/1000.-0.5)),
					vec2(abs(frameTimeCounter/1000.-0.5),-abs(frameTimeCounter/1000.-0.5)));


float     GetDepthLinear(in vec2 coord) {          
   return 2.0f * near * far / (far + near - (2.0f * texture2D(depthtex0, coord).x - 1.0f) * (far - near));
}

void main() {
    vec3 aux = texture2D(gaux1, texcoord.st).rgb;

    float iswater = float(aux.g > 0.04 && aux.g < 0.07);

    vec3 color = texture2D(colortex0, texcoord.st).rgb;

    float depth = texture2D(depthtex0, texcoord.st).r;

    vec3 fogCol = vec3(0.5, 0.76, 0.8)*1.2;
    vec3 sunsetFogCol = vec3(0.8, 0.56, 0.5)*1.2;
    vec3 nightFogCol = vec3(0.1, 0.5, 1.0)*0.14;
    vec3 customFogColor = (sunsetFogCol*TimeSunrise + fogCol*TimeNoon + sunsetFogCol*TimeSunset + nightFogCol*TimeMidnight);

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