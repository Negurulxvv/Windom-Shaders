#version 120

uniform sampler2D texture;
uniform sampler2D lightmap;

varying vec4 color;
varying vec4 texcoord;
varying vec4 lmcoord;

const int GL_LINEAR = 8765;
const int GL_EXP = 1236;

uniform int fogMode;

void main() {
/*DRAWBUFFERS:014*/
	gl_FragData[0] = texture2D(texture, texcoord.st) * texture2D(lightmap, lmcoord.st) * color;
	gl_FragData[1] = vec4(vec3(gl_FragCoord.z), 1.0);

	if (fogMode == GL_EXP) {
		gl_FragData[0].rgb = mix(gl_FragData[0].rgb, gl_Fog.color.rgb, 1.2 - clamp(exp(-gl_Fog.density * gl_FogFragCoord), 0.0, 1.2));
	} else if (fogMode == GL_LINEAR) {
		gl_FragData[0].rgb = mix(gl_FragData[0].rgb, gl_Fog.color.rgb, clamp((gl_FogFragCoord - gl_Fog.start) * gl_Fog.scale, 0.0, 1.2));
	}
                   gl_FragData[2] = vec4(lmcoord.st, 1.5, 1.0);
}