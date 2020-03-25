# version 330 core

layout (location = 0) out vec4 fragPosition;
layout (location = 1) out vec4 fragColor;
layout (location = 2) out vec4 fragNormal;
layout (location = 3) out vec4 fragUV;

in vec3 outPosition;
in vec3 outColor;
in vec3 outNormal;
in vec3 outUV;
in float outTextureID;
in vec3 outFragPos;
in vec3 outCameraPos;
flat in int outHasTexture;
flat in int outDisableLighting;

uniform sampler2D diffuse_texture;

void main() {
  vec3 result;

  if (outHasTexture == 0) {
      result = outColor;
  } else {
    result = texture(diffuse_texture, outUV.xy).xyz;
  }

  fragPosition = vec4(outPosition, 1.0);
  fragColor = vec4(result, 1.0);
  fragNormal = vec4(outNormal, 1.0);
  fragUV = vec4(outUV, 1.0);
}
