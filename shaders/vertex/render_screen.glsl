#version 330 core
layout (location = 0) in vec2 inPosition;
layout (location = 1) in vec2 inTexCoords;

out vec2 outTexCoords;

void main() {
  gl_Position = vec4(inPosition.x, inPosition.y, inPosition.z, 1.0); 
  outTexCoords = inTexCoords;
}  