//
//  FCShader.m
//  FaceCamera
//
//  Created by  zcating on 2019/1/11.
//  Copyright © 2019 zcat. All rights reserved.
//


#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/gl.h>
#import "FCShader.h"

@interface FCShader()

@property (nonatomic) GLuint program;

@end

@implementation FCShader

- (instancetype)initWithVertexShaderURL:(NSURL *)vertexShaderURL fragmentShaderURL:(NSURL *)fragmentShaderURL {
    self = [super init];
    if (self) {
        GLuint vertexShaderID = [self complieWithType:FCShaderTypeVertex URL:vertexShaderURL];
        GLuint fragmentShaderID = [self complieWithType:FCShaderTypeFragment URL:fragmentShaderURL];
       
        self.program = glCreateProgram();
        glAttachShader(self.program, vertexShaderID);
        glAttachShader(self.program, fragmentShaderID);
        glLinkProgram(self.program);
        
        
        GLint status = 0;
        glGetProgramiv(self.program, GL_LINK_STATUS, &status);
        if (status == 0) {
            GLint logLength;
            glGetProgramiv(self.program, GL_INFO_LOG_LENGTH, &logLength);
            if (logLength > 0) {
                GLchar *log = (GLchar *)malloc(logLength);
                glGetProgramInfoLog(self.program, logLength, &logLength, log);
                NSLog(@"Program link log: %s", log);
                free(log);
            }
        }
        // Release vertex and fragment shaders.
        if (vertexShaderID) {
            glDetachShader(self.program, vertexShaderID);
            glDeleteShader(vertexShaderID);
        }
        if (fragmentShaderID) {
            glDetachShader(self.program, fragmentShaderID);
            glDeleteShader(fragmentShaderID);
        }
    }
    return self;
}

#pragma mark - PUBLIC

-(void)use {
    glUseProgram(self.program);
}


//-uniform
-(void)setUniform:(const char *)name forUIntValue:(GLuint)value {
    
}

#pragma mark - PRIVATE


- (GLuint)complieWithType:(FCShaderType)type URL:(NSURL *)url {
    NSError *error;
    NSString *code = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if (code == nil) {
        NSLog(@"Failed to load vertex shader: %@", [error localizedDescription]);
        return 0;
    }
    
    return [self complieWithType:type code:code];
}

- (GLuint)complieWithType:(FCShaderType)type code:(NSString *)code {
    GLenum glType = type == FCShaderTypeVertex ? GL_VERTEX_SHADER : GL_FRAGMENT_SHADER;
    
    const GLchar* rawCode = [code UTF8String];
    GLuint shaderID = glCreateShader(glType);
    glShaderSource(shaderID, 1, &rawCode, NULL);
    glCompileShader(shaderID);
    
    
    GLint status = 0;
    glGetShaderiv(shaderID, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        [self showCompileErrorWith:shaderID];
        glDeleteShader(shaderID);
        return 0;
    }
    
    return shaderID;
}

- (void)showCompileErrorWith:(GLint)shaderID {
    GLint infoLength;
    glGetShaderiv(shaderID, GL_INFO_LOG_LENGTH, &infoLength);
    if (infoLength == 0) {
        return;
    }
    GLchar *info = (GLchar *)malloc(infoLength);
    glGetShaderInfoLog(shaderID, infoLength, &infoLength, info);
    NSLog(@"Shader compile log:\n%s", info);
    free(info);
}
@end
