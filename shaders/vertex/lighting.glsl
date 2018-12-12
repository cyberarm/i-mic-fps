# version 330

layout(location = 0) in vec3 vert;
uniform vec3 position;

void main() {
  // projection * view * model *
  gl_Position = vec4(vert+position, 1.0);
}