module learnopengl.getting_started.hello_triangle.main;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
import std.string : toStringz;
import std.stdio;

const uint SCR_WIDTH = 800;
const uint SCR_HEIGHT = 600;

string vertexShaderSource = 
    "#version 330 core\n" ~
    "layout (location = 0) in vec3 aPos;\n" ~
    "void main()\n" ~
    "{\n" ~
    "   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\n" ~
    "}";
string fragmentShaderSource =
    "#version 330 core\n" ~
    "out vec4 FragColor;\n" ~
    "void main()\n" ~
    "{\n" ~
    "   FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);\n" ~
    "}";

void main()
{
    writefln("setup OpenGL context with glfw");
    DerelictGL3.load();
    DerelictGLFW3.load();
    scope(exit) {
        glfwTerminate();
    }
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    version(OSX) {
        glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
    }

    GLFWwindow* window = glfwCreateWindow(SCR_WIDTH, SCR_HEIGHT, "LearnOpenGL", null, null);
    if (window == null) {
        writefln("Failed to create GLFW window");
        return;
    }
    glfwMakeContextCurrent(window);
    glfwSetFramebufferSizeCallback(window, &framebuffer_size_callback);
    writefln("setup OpenGL context with glfw done");

    DerelictGL3.reload();
    writefln("OpenGL Version %s loaded", DerelictGL3.loadedVersion);

    writefln("init done, using OpenGL now");

    // build and compile our shader program
    // ------------------------------------
    // vertex shader
    int vertexShader = glCreateShader(GL_VERTEX_SHADER);
    GLchar* vertexShaderSourcePtr = cast(GLchar*)(toStringz(vertexShaderSource));
    glShaderSource(vertexShader, 1, &vertexShaderSourcePtr, null);
    glCompileShader(vertexShader);
    // check for shader compile errors
    int success;
    char[512] infoLog;
    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);
    if (!success)
    {
        glGetShaderInfoLog(vertexShader, 512, null, infoLog.ptr);
        writeln("ERROR::SHADER::VERTEX::COMPILATION_FAILED", infoLog);
    }
    // fragment shader
    int fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    GLchar* fragmentShaderSourcePtr = cast(GLchar*)(toStringz(fragmentShaderSource));
    glShaderSource(fragmentShader, 1, &fragmentShaderSourcePtr, null);
    glCompileShader(fragmentShader);
    // check for shader compile errors
    glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success);
    if (!success)
    {
        glGetShaderInfoLog(fragmentShader, 512, null, infoLog.ptr);
        writeln("ERROR::SHADER::FRAGMENT::COMPILATION_FAILED", infoLog);
    }
    // link shaders
    int shaderProgram = glCreateProgram();
    glAttachShader(shaderProgram, vertexShader);
    glAttachShader(shaderProgram, fragmentShader);
    glLinkProgram(shaderProgram);
    // check for linking errors
    glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
    if (!success) {
        glGetProgramInfoLog(shaderProgram, 512, null, infoLog.ptr);
        writeln("ERROR::SHADER::PROGRAM::LINKING_FAILED", infoLog);
    }
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);

    // set up vertex data (and buffer(s)) and configure vertex attributes
    // ------------------------------------------------------------------
    float[] firstTriangleVertices = [
        -0.9f, -0.5f, 0.0f,  // left
        -0.0f, -0.5f, 0.0f,  // right
        -0.45f, 0.5f, 0.0f,  // top
    ]; 

    float[] secondTriangleVertices = [
         0.0f, -0.5f, 0.0f,  // left
         0.9f, -0.5f, 0.0f,  // right
         0.45f, 0.5f, 0.0f   // top
    ]; 

    uint[2] VBOs, VAOs;
    glGenVertexArrays(2, VAOs.ptr);
    glGenBuffers(2, VBOs.ptr);

    // first triangle setup
    glBindVertexArray(VAOs[0]);
    glBindBuffer(GL_ARRAY_BUFFER, VBOs[0]);
    glBufferData(GL_ARRAY_BUFFER, firstTriangleVertices.length * float.sizeof, firstTriangleVertices.ptr, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * float.sizeof, cast(void*)0);
    glEnableVertexAttribArray(0);
    // glBindVertexArray(0);

    // second triangle setup
    glBindVertexArray(VAOs[1]);
    glBindBuffer(GL_ARRAY_BUFFER, VBOs[1]);
    glBufferData(GL_ARRAY_BUFFER, secondTriangleVertices.length * float.sizeof, secondTriangleVertices.ptr, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * float.sizeof, cast(void*)0);
    glEnableVertexAttribArray(0);
    // glBindVertexArray(0); 


    // uncomment this call to draw in wireframe polygons.
    //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

    // render loop
    // -----------
    while (!glfwWindowShouldClose(window))
    {
        // input
        // -----
        processInput(window);

        // render
        // ------
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        // draw our first triangle
        glUseProgram(shaderProgram);

        glBindVertexArray(VAOs[0]); // seeing as we only have a single VAO there's no need to bind it every time, but we'll do so to keep things a bit more organized
        glDrawArrays(GL_TRIANGLES, 0, 6);

        glBindVertexArray(VAOs[1]); // seeing as we only have a single VAO there's no need to bind it every time, but we'll do so to keep things a bit more organized
        glDrawArrays(GL_TRIANGLES, 0, 6);

        // glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
        // -------------------------------------------------------------------------------
        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    // optional: de-allocate all resources once they've outlived their purpose:
    // ------------------------------------------------------------------------
    glDeleteVertexArrays(2, VAOs.ptr);
    glDeleteBuffers(2, VBOs.ptr);
}

// process all input: query GLFW whether relevant keys are pressed/released this frame and react accordingly
// ---------------------------------------------------------------------------------------------------------
void processInput(GLFWwindow *window)
{
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS) {
        glfwSetWindowShouldClose(window, true);
    }
}

// glfw: whenever the window size changed (by OS or user resize) this callback function executes
// ---------------------------------------------------------------------------------------------
extern(C) void framebuffer_size_callback(GLFWwindow* window, int width, int height) nothrow
{
    // make sure the viewport matches the new window dimensions; note that width and 
    // height will be significantly larger than specified on retina displays.
    glViewport(0, 0, width, height);
}
