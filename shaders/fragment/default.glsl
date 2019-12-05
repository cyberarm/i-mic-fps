# version 330 core

in vec3 outColor;
in vec4 outNormal;
in vec3 outUV;
in float outTextureID;

// optimizing compilers are annoying at this stage of my understanding of GLSL
vec4 lokiVar;

void main() {
  lokiVar = vec4(outColor, 1.0) + outNormal + vec4(outUV, 1.0) + vec4(outTextureID, 1.0, 1.0, 1.0);
  lokiVar = normalize(lokiVar);
  gl_FragColor = vec4(lokiVar);
}