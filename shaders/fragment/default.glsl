# version 330

in vec3 outColor;
in vec4 outNormal;
in vec3 outUV;
in float outTextureID;

void main() {
  gl_FragColor = vec4(outColor, 1.0);
}