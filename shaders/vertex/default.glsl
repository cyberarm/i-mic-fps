# version 330 core

layout(location = 0) in vec3  inPosition;
layout(location = 1) in vec3  inColor;
layout(location = 2) in vec4  inNormal;
layout(location = 3) in vec3  inUV;
layout(location = 4) in float inTextureID;

out vec3 outColor;
out vec4 outNormal;
out vec3 outUV;
out float outTextureID;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

void main() {
  // projection * view * model * position
  outColor = inColor;
  outNormal= inNormal;
  outUV    = inUV;
  outTextureID = inTextureID;

  gl_Position = projection * view * model * vec4(inPosition, 1.0);
}