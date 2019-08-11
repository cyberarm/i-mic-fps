# version 330

layout(location = 0) in vec3  inPosition;
layout(location = 1) in vec3  inColor;
layout(location = 2) in vec4  inNormal;
layout(location = 3) in vec3  inUV;
layout(location = 4) in float inTextureID;

out vec3 outColor;
out vec4 outNormal;
out vec3 outUV;
out float outTextureID;

uniform vec3 worldPosition;

void main() {
  // projection * view * model *
  outColor = inColor;
  outNormal= inNormal;
  outUV    = inUV;
  outTextureID = inTextureID;

  gl_Position = vec4(worldPosition + inPosition, 1.0);
}