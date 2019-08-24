#version 120

uniform sampler2D texture;
uniform sampler2D tex;

varying vec4 color;

varying vec4 texcoord;

void main() {
    if (texture2D(texture, texcoord.st).a < 0.35) {
        discard;
    }

    vec3 fragColor = color.rgb * texture2D(tex, texcoord.st).rgb;

    gl_FragData[0] = vec4(fragColor, 1.0);
}