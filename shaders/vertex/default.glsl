# version 330 core

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
out vec3 outLightPos;
out vec3 outFragPos;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;
uniform int hasTexture;
uniform vec3 lightPos;


void main() {
  // projection * view * model * position
  outPosition = inPosition;
  outColor = inColor;
  outNormal= inNormal;
  outUV    = inUV;
  outTextureID = inTextureID;
  outHasTexture = hasTexture;
  outLightPos = lightPos;

  outFragPos = vec3(model * vec4(inPosition, 1.0));

  gl_Position = projection * view * model * vec4(inPosition, 1.0);
}