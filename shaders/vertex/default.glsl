# version 330 core

@include "light_struct"

layout(location = 0) in vec3  inPosition;
layout(location = 1) in vec3  inColor;
layout(location = 2) in vec3  inNormal;
layout(location = 3) in vec3  inUV;
layout(location = 4) in float inTextureID;

out vec3 outPosition;
out vec3 outColor;
out vec3 outNormal;
out vec3 outUV;
out float outTextureID;
out Light outLights[MAX_LIGHTS];
flat out int outTotalLights;
out vec3 outFragPos;
out vec3 outViewPos;
out vec3 outCameraPos;
flat out int outHasTexture;
flat out int outDisableLighting;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;
uniform int hasTexture;
uniform int totalLights;
uniform Light lights[MAX_LIGHTS];
uniform vec3 cameraPos;
uniform int disableLighting;


void main() {
  // projection * view * model * position
  outPosition = inPosition;
  outColor = inColor;
  outNormal= normalize(transpose(inverse(mat3(model))) * inNormal);
  outUV    = inUV;
  outTextureID = inTextureID;
  outHasTexture = hasTexture;
  outLights = lights;
  outTotalLights = totalLights;
  outCameraPos = cameraPos;
  outDisableLighting = disableLighting;

  outFragPos = vec3(model * vec4(inPosition, 1.0));

  gl_Position = projection * view * model * vec4(inPosition, 1.0);
}
