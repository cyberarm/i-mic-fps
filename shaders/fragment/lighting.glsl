# version 330 core

layout (location = 4) out vec4 sceneColor;

flat in int outLightType;
in vec3 outLightPosition;
in vec3 outLightAmbient;
in vec3 outLightDiffuse;
in vec3 outLightSpecular;

in vec2 outTexCoords;

@include "light_struct"

void main() {
  sceneColor = vec4(1.0, 0.5, 0.25, 1.0);
}