#version 120

uniform sampler2D colortex0;

uniform int worldTime;

uniform float frameTimeCounter;

uniform sampler2D normals;

varying vec4 texcoord;

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

vec3 colorGrading(in vec3 col) {
    vec3 blueCol = vec3(0.0,0.2025,0.4);
    vec3 redCol = vec3(0.6, 0.8, 0.28);

    vec3 regular = vec3(0.8);
    vec3 regular2 = vec3(0.94);

    vec3 purpleColor = mix(regular, blueCol, redCol);


    vec3 mixBlueCol = mix(blueCol, col, regular);
    vec3 mixRedCol = mix(purpleColor, col, regular);

    vec3 mixDailyCol = vec3(mixRedCol*TimeSunrise + mixBlueCol*TimeNoon + mixRedCol*TimeSunset + mixBlueCol*TimeMidnight);

    return mixDailyCol;

}





void main() {
    vec3 color = texture2D(colortex0, texcoord.st).rgb;


    color = colorGrading(color);

    gl_FragData[0] = vec4(color, 1.0);
}