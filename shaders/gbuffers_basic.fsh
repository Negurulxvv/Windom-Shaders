#version 120

varying vec2 texcoord;

uniform sampler2D colortex0;

void main() {
    vec3 color = texture2D(colortex0, texcoord.st).rgb;

    gl_FragData[0] = vec4(color, 1.0);
}