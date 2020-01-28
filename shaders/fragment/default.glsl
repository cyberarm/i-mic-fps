# version 330 core

@include "light_struct"

in vec3 outPosition;
in vec3 outColor;
in vec4 outNormal;
in vec3 outUV;
in float outTextureID;
in Light outLights[MAX_LIGHTS];
in float outTotalLights;
in vec3 outFragPos;
in vec3 outCameraPos;
in vec3 outInverseNormal;

// optimizing compilers are annoying at this stage of my understanding of GLSL
vec4 lokiVar;

// https://learnopengl.com/Lighting/Multiple-lights
vec3 calculatePointLight(Light light) {
  vec3 viewDir = normalize(outCameraPos - outFragPos);
  vec3 lightDir = normalize(light.position - outFragPos);
  float diff = max(dot(vec3(outNormal), lightDir), 0.0);
  vec3 reflectDir = reflect(-lightDir, vec3(outNormal));
  float spec = pow(max(dot(viewDir, reflectDir), 0.0), 16.0);

  float distance    = length(light.position - outFragPos);
  float attenuation = 1.0 / (1.0 + 0.09 * distance +
                      0.032 * (distance * distance));

  vec3 ambient  = light.ambient  * outColor;
  vec3 diffuse  = light.diffuse  * outColor;
  vec3 specular = light.specular * spec * vec3(1.0, 1.0, 1.0);

  ambient  *= attenuation;
  diffuse  *= attenuation;
  specular *= attenuation;

  return (ambient + diffuse + specular);
}

// https://learnopengl.com/Lighting/Basic-Lighting
vec3 calculateBasicLight(Light light) {
  vec3 lightDir = normalize(light.position - outFragPos);

  float ambientStrength = 0.25;
  vec3 ambient = ambientStrength * light.ambient;

  float diff = max(dot(normalize(vec3(outNormal)), lightDir), 0.0);
  vec3 diffuse = diff * light.diffuse;

  float specularStrength = 0.5;
  vec3 viewDir = normalize(outCameraPos - outFragPos);
  vec3 reflectDir = reflect(-lightDir, outInverseNormal);
  float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);
  vec3 specular = specularStrength * spec * light.specular;

  return vec3(ambient + diffuse + specular);
}

vec3 calculateLighting() {
  vec3 result = vec3(0.0, 0.0, 0.0);

  for (int i = 0; i < min(int(outTotalLights), MAX_LIGHTS); i++) {
    if (int(outLights[i].type) == 0) {
      result += calculateBasicLight(outLights[i]);
    } else if (int(outLights[i].type) == 1) {
      result += calculateBasicLight(outLights[i]);
    }
  }

  return result;
}

void main() {
  lokiVar = vec4(outColor, 1.0) + outNormal + vec4(outUV, 1.0) + vec4(outTextureID, 1.0, 1.0, 1.0);
  lokiVar = normalize(lokiVar);

  vec3 result = calculateLighting() * outColor;

  gl_FragColor = vec4(result, 1.0);
}
