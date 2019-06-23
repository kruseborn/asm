#include "linmath.h"
#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>
#include <glad/glad.h>
#include <stdio.h>
#include <stdlib.h>
#include <cmath>


extern "C" float printWorld(float *x, float *y, int dir);

static struct {
  float x, y;
  float r, g, b;
} vertices[3] = {
    {0, 0, 1.f, 0.f, 0.f}, {100, 0, 0.f, 1.f, 0.f}, {50, 100, 0.f, 0.f, 1.f}};
static const char *vertex_shader_text =
    "#version 110\n"
    "uniform mat4 MVP;\n"
    "attribute vec3 vCol;\n"
    "attribute vec2 vPos;\n"
    "varying vec3 color;\n"
    "void main()\n"
    "{\n"
    "    gl_Position = MVP * vec4(vPos, 0.0, 1.0);\n"
    "    color = vCol;\n"
    "}\n";
static const char *fragment_shader_text =
    "#version 110\n"
    "varying vec3 color;\n"
    "void main()\n"
    "{\n"
    "    gl_FragColor = vec4(color, 1.0);\n"
    "}\n";
static void error_callback(int error, const char *description) {
  fprintf(stderr, "Error: %s\n", description);
  printf("hello world");
  sinf(3.0f);
  cosf(3.0f);
}
static void key_callback(GLFWwindow *window, int key, int scancode, int action,
                         int mods) {
  if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS)
    glfwSetWindowShouldClose(window, GLFW_TRUE);
}
int main(void) {
  GLFWwindow *window;
  GLuint vertex_buffer, vertex_shader, fragment_shader, program;
  GLint mvp_location, vpos_location, vcol_location;
  glfwSetErrorCallback(error_callback);
  if (!glfwInit())
    exit(EXIT_FAILURE);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
  window = glfwCreateWindow(1024, 1024, "Simple example", NULL, NULL);
  if (!window) {
    glfwTerminate();
    exit(EXIT_FAILURE);
  }
  glfwSetKeyCallback(window, key_callback);
  glfwMakeContextCurrent(window);
  gladLoadGL();
  glfwSwapInterval(1);
  // NOTE: OpenGL error checks have been omitted for brevity
  glGenBuffers(1, &vertex_buffer);
  glBindBuffer(GL_ARRAY_BUFFER, vertex_buffer);
  glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_DYNAMIC_DRAW);
  vertex_shader = glCreateShader(GL_VERTEX_SHADER);
  glShaderSource(vertex_shader, 1, &vertex_shader_text, NULL);
  glCompileShader(vertex_shader);
  fragment_shader = glCreateShader(GL_FRAGMENT_SHADER);
  glShaderSource(fragment_shader, 1, &fragment_shader_text, NULL);
  glCompileShader(fragment_shader);
  program = glCreateProgram();
  glAttachShader(program, vertex_shader);
  glAttachShader(program, fragment_shader);
  glLinkProgram(program);
  mvp_location = glGetUniformLocation(program, "MVP");
  vpos_location = glGetAttribLocation(program, "vPos");
  vcol_location = glGetAttribLocation(program, "vCol");
  glEnableVertexAttribArray(vpos_location);
  glVertexAttribPointer(vpos_location, 2, GL_FLOAT, GL_FALSE,
                        sizeof(vertices[0]), (void *)0);
  glEnableVertexAttribArray(vcol_location);
  glVertexAttribPointer(vcol_location, 3, GL_FLOAT, GL_FALSE,
                        sizeof(vertices[0]), (void *)(sizeof(float) * 2));

  float x = 250.0f;
  float y = 200.0f;

  //Bullets bullets = {};
  //bullets.count = 20;

  while (!glfwWindowShouldClose(window)) {
    float ratio;
    int width, height;
    mat4x4 m, p, mvp;
    glfwGetFramebufferSize(window, &width, &height);
    ratio = width / (float)height;
    glViewport(0, 0, width, height);
    glClear(GL_COLOR_BUFFER_BIT);

    int dir = -1;

    dir = glfwGetKey(window, GLFW_KEY_UP) == GLFW_PRESS ? 0 : dir;
    dir = glfwGetKey(window, GLFW_KEY_DOWN) == GLFW_PRESS ? 1 : dir;
    dir = glfwGetKey(window, GLFW_KEY_LEFT) == GLFW_PRESS ? 2 : dir;
    dir = glfwGetKey(window, GLFW_KEY_RIGHT) == GLFW_PRESS ? 3 : dir;
    float angle = printWorld(&x, &y, dir);
    printf("angle: %f\n", angle);

    vertices[0].x = x - 25;
    vertices[1].x = x + 25;
    vertices[2].x = x;


    vertices[0].y = y -25;
    vertices[1].y = y -25;
    vertices[2].y = y + 25;
    
    printf("%f\n", vertices[0].x);
    glBindBuffer(GL_ARRAY_BUFFER, vertex_buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_DYNAMIC_DRAW);

    //printWorld();

    mat4x4_identity(m);
    float xx = x;
    float yy = y;
    mat4x4_translate_in_place(m, xx, yy, 0);
    mat4x4_rotate_Z(m, m, -angle);
    mat4x4_translate_in_place(m, -xx, -yy, 0);
    mat4x4_ortho(p, 0, width, 0, height, 1.f, -1.f);
    mat4x4_mul(mvp, p, m);
    glUseProgram(program);
    glUniformMatrix4fv(mvp_location, 1, GL_FALSE, (const GLfloat *)mvp);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    glfwSwapBuffers(window);
    glfwPollEvents();
  }
  glfwDestroyWindow(window);
  glfwTerminate();
  exit(EXIT_SUCCESS);
}
