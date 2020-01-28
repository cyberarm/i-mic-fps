# version 330 core

@include "light_struct"

layout(location = 0) in vec3  inPosition;
layout(location = 1) in vec3  inColor;
layout(location = 2) in vec4  inNormal;
layout(location = 3) in vec3  inUV;
layout(location = 4) in float inTextureID;

out vec3 outPosition;
out vec3 outColor;
out vec4 outNormal;
out vec3 outUV;
out float outTextureID;
out float outHasTexture;
out Light outLights[MAX_LIGHTS];
out float outTotalLights;
out vec3 outFragPos;
out vec3 outViewPos;
out vec3 outCameraPos;
out vec3 outInverseNormal;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;
uniform int hasTexture;
uniform float totalLights;
uniform Light lights[MAX_LIGHTS];
uniform vec3 cameraPos;


void main() {
  // projection * view * model * position
  outPosition = inPosition;
  outColor = inColor;
  outNormal= inNormal;
  outUV    = inUV;
  outTextureID = inTextureID;
  outHasTexture = hasTexture;
  outLights = lights;
  outTotalLights = totalLights;
  outCameraPos = cameraPos;
  outInverseNormal = mat3(transpose(inverse(model))) * vec3(inNormal);

  outFragPos = vec3(model * vec4(inPosition, 1.0));

  gl_Position = projection * view * model * vec4(inPosition, 1.0);
}
