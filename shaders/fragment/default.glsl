# version 330 core

in vec3 outPosition;
in vec3 outColor;
in vec4 outNormal;
in vec3 outUV;
in float outTextureID;
in vec3 outLightPos;
in vec3 outFragPos;

// optimizing compilers are annoying at this stage of my understanding of GLSL
vec4 lokiVar;

void main() {
  lokiVar = vec4(outColor, 1.0) + outNormal + vec4(outUV, 1.0) + vec4(outTextureID, 1.0, 1.0, 1.0);
  lokiVar = normalize(lokiVar);

  vec3 lightDir = normalize(outLightPos - outFragPos);
  vec3 ambient = vec3(0.5, 0.5, 0.35);
  float diffuse = max(dot(vec3(outNormal), lightDir), -0.2);
  vec3 specular = vec3(0, 0, 0);

  vec3 result =(ambient + diffuse + specular) * outColor;

  gl_FragColor = vec4(result, 1.0);
}