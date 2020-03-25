#version 330 core
layout (location = 0) in vec3 inPosition;
layout (location = 1) in vec2 inTexCoords;

in int  inLightType;
in vec3 inLightPosition;
in vec3 inLightAmbient;
in vec3 inLightDiffuse;
in vec3 inLightSpecular;

flat out int outLightType;
out vec3 outLightPosition;
out vec3 outLightAmbient;
out vec3 outLightDiffuse;
out vec3 outLightSpecular;

out vec2 outTexCoords;

void main() {
  gl_Position = vec4(inPosition.x, inPosition.y, inPosition.z, 1.0);

  outLightType = inLightType;
  outLightPosition = inLightPosition;
  outLightAmbient = inLightAmbient;
  outLightDiffuse = inLightDiffuse;
  outLightSpecular = inLightSpecular;
  outTexCoords = inTexCoords;
}