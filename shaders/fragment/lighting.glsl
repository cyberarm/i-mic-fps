#version 330 core
out vec4 FragColor;

@include "light_struct"
const int DIRECTIONAL = 0;
const int POINT = 1;
const int SPOT = 2;

in vec2 outTexCoords;
flat in Light outLight[1];

uniform sampler2D diffuse, position, texcoord, normal, depth;

vec4 directionalLight(Light light) {
  return vec4(0,0,0,1);
}

vec4 pointLight(Light light) {
  return vec4(0.25, 0.25, 0.25, 1);
}

vec4 spotLight(Light light) {
  return vec4(0.5, 0.5, 0.5, 1);
}

vec4 calculateLighting(Light light) {
  vec4 result = vec4(0,0,0,0);

  switch(light.type) {
    case DIRECTIONAL: {
      result = directionalLight(light);
    }
    case POINT: {
      result = pointLight(light);
    }
    case SPOT: {
      result = spotLight(light);
    }
    default: {
      result = vec4(1,1,1,1);
    }
  }

  return result;
}

void main() {
  FragColor = texture(diffuse, outTexCoords) * calculateLighting(outLight[0]);
}