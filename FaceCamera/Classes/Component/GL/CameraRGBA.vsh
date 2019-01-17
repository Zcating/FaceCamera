
#version 300 es

layout(location = 0) in vec4 position;
layout(location = 1) in vec2 textureCoordinate;

out vec2 outTextureCoordinate;


void main()
{
    gl_Position = position;
    outTextureCoordinate = textureCoordinate;
}

