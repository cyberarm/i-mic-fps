const int MAX_LIGHTS = 4;

struct Light {
  float end;
  float type;
  vec3 position;

  vec3 diffuse;
  vec3 ambient;
  vec3 specular;

  vec3 direction;

  float intensity;
};
