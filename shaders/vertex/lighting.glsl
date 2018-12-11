# version 150
# extension GL_ARB_explicit_attrib_location : enable

in vec3 vert;
uniform vec3 SunLight;

void main() {
  gl_Position = vec4(vert, 1.0);
}