//
//  FCImageFilter.m
//  FaceCamera
//
//  Created by  zcating on 2018/12/30.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FCImageFilter.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>



@interface FCImageFilter ()

@property (nonatomic) BOOL enable;



@end
//public static void createFrameBuffer(int[] frameBuffer, int[] frameBufferTexture,
//                                     int width, int height) {
//    GLES30.glGenFramebuffers(frameBuffer.length, frameBuffer, 0);
//    GLES30.glGenTextures(frameBufferTexture.length, frameBufferTexture, 0);
//    for (int i = 0; i < frameBufferTexture.length; i++) {
//        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, frameBufferTexture[i]);
//        GLES30.glTexImage2D(GLES30.GL_TEXTURE_2D, 0, GLES30.GL_RGBA, width, height, 0,
//                            GLES30.GL_RGBA, GLES30.GL_UNSIGNED_BYTE, null);
//        GLES30.glTexParameterf(GLES30.GL_TEXTURE_2D,
//                               GLES30.GL_TEXTURE_MAG_FILTER, GLES30.GL_LINEAR);
//        GLES30.glTexParameterf(GLES30.GL_TEXTURE_2D,
//                               GLES30.GL_TEXTURE_MIN_FILTER, GLES30.GL_LINEAR);
//        GLES30.glTexParameterf(GLES30.GL_TEXTURE_2D,
//                               GLES30.GL_TEXTURE_WRAP_S, GLES30.GL_CLAMP_TO_EDGE);
//        GLES30.glTexParameterf(GLES30.GL_TEXTURE_2D,
//                               GLES30.GL_TEXTURE_WRAP_T, GLES30.GL_CLAMP_TO_EDGE);
//        GLES30.glBindFramebuffer(GLES30.GL_FRAMEBUFFER, frameBuffer[i]);
//        GLES30.glFramebufferTexture2D(GLES30.GL_FRAMEBUFFER, GLES30.GL_COLOR_ATTACHMENT0,
//                                      GLES30.GL_TEXTURE_2D, frameBufferTexture[i], 0);
//        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, 0);
//        GLES30.glBindFramebuffer(GLES30.GL_FRAMEBUFFER, 0);
//    }
//    checkGlError("createFrameBuffer");
//}
@implementation FCImageFilter

//-(void)createFrameBuffer:(int[])frameBuffer frameBufferTexture:(int[])frameBufferTexture width:(long)width height:(long)height {
//    glGenFramebuffers(<#GLsizei n#>, <#GLuint *framebuffers#>);
//}
@end
