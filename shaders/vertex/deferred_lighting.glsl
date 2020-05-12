#version 330 core
@include "light_struct"

layout (location = 0) in vec3 inPosition;
layout (location = 1) in vec2 inTexCoords;

uniform sampler2D diffuse, position, texcoord, normal, depth;
uniform Light light;

out vec2 outTexCoords;
flat out Light outLight;

void main() {
  gl_Position = vec4(inPosition.x, inPosition.y, inPosition.z, 1.0);
  outTexCoords = inTexCoords;
  outLight = light;
}