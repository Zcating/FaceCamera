//
//  FaceCameraView.m
//  FaceCamera
//
//  Created by  zcating on 2018/10/26.
//  Copyright © 2018 zcat. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <AVFoundation/AVUtilities.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

#import "FaceCameraView.h"
#import "FaceCamera.h"

#import "FCMaskFilter.h"
#import "FCShader.h"

#import "FaceCameraCore.h"

#import "ImageProcession.hpp"

struct CameraUniformVariable {
    GLuint samplerRGBA;
};

enum CameraAttributes {
    CameraAttributesPosition = 0,
    CameraAttributesTextureCoordinate = 1,
};

GLfloat quadTextureData[] =  {
    0, 0,
    1, 0,
    0, 1,
    1, 1
};


@interface FaceCameraView ()<FaceCameraDelegate>
{
    GLint _renderBufferWidth;
    GLint _renderBufferHeight;
    
    GLuint _frameBufferID;
    GLuint _colorBufferID;
    
    CameraAttributes attributes;
    CameraUniformVariable _variable;
    
    GLfloat _imageVertices[8];
}

@property (nonatomic) CVOpenGLESTextureCacheRef cameraTextureCache;

@property (nonatomic, strong) FCShader *shader;

@property (nonatomic, strong) FaceCamera *faceCamera;

@property (nonatomic, strong) FCMaskFilter *filter;


@end

@implementation FaceCameraView

#pragma mark - PUBLIC

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentScaleFactor = [[UIScreen mainScreen] scale];

        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
        [EAGLContext setCurrentContext:self.context];

        NSURL *vertShaderURL = [[NSBundle mainBundle] URLForResource:@"CameraRGBA" withExtension:@"vsh"];
        NSURL *fragShaderURL = [[NSBundle mainBundle] URLForResource:@"CameraRGBA" withExtension:@"fsh"];
        _shader = [[FCShader alloc] initWithVertexShaderURL:vertShaderURL fragmentShaderURL:fragShaderURL];

        _filter = [[FCMaskFilter alloc] init];
        
        [self setupLayer];
        [self setupBuffers];
        
        NSError *error = nil;
        NSURL *path = [[NSBundle mainBundle] URLForResource:@"mask" withExtension:@"json"];
        NSData *jsonData = [NSData dataWithContentsOfURL:path];
        NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
//        [_filter setupImage:[UIImage imageNamed:@"mouth"] landmarks:array];
    }
    return self;
}

- (void)dealloc {
    
    if(self.cameraTextureCache) {
        CFRelease(self.cameraTextureCache);
    }
}

-(void)start {
    [self.faceCamera start];
}

-(void)stop {
    [self.faceCamera stop];
}


-(void)switchCamera {
    [self.faceCamera switchCameras];
}

#pragma mark - PRIVATE

- (void)setupLayer {
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = TRUE;
    eaglLayer.drawableProperties = @{
        kEAGLDrawablePropertyRetainedBacking: @(YES),
        kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
    };
}

// Drawing table
- (void)setupBuffers {
    glDisable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glEnableVertexAttribArray(CameraAttributesPosition);
    glVertexAttribPointer(CameraAttributesPosition, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), 0);
    
    glEnableVertexAttribArray(CameraAttributesTextureCoordinate);
    glVertexAttribPointer(CameraAttributesTextureCoordinate, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), 0);
    
    glGenFramebuffers(1, &_frameBufferID);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferID);
    
    glGenRenderbuffers(1, &_colorBufferID);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferID);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorBufferID);
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
    
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_renderBufferWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_renderBufferHeight);
}



#pragma mark - DELEGATE

-(void)processframe:(CMSampleBufferRef)frame faces:(NSArray *)faces {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(frame);
//
//    cv::Mat image = fc::PixelBufferToCvMat(pixelBuffer);
//    [faces enumerateObjectsUsingBlock:^(NSValue * _Nonnull value, NSUInteger idx, BOOL * _Nonnull stop) {
//        CGRect rectValue = value.CGRectValue;
//        cv::Rect faceRect(rectValue.origin.x, rectValue.origin.y, rectValue.size.width, rectValue.size.height);
//        auto landmarks = [[FaceCameraCore shared] getLandmarksWith:image rect:faceRect];
//        [self->_filter updateLandmarks:landmarks];
//    }];
    
    [self displayPixelBuffer:pixelBuffer runFilter:^{
        if (faces.count > 0) {
            [self->_filter draw];
        }
    }];
}

- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer runFilter:(FilterBlock)runFilter {
    int frameWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
    int frameHeight = (int)CVPixelBufferGetHeight(pixelBuffer);

    [EAGLContext setCurrentContext:self.context];
    CVOpenGLESTextureCacheFlush(self.cameraTextureCache, 0);
    
    glClear(GL_COLOR_BUFFER_BIT);
    glActiveTexture(GL_TEXTURE0);
    CVOpenGLESTextureRef cameraTexture;
    CVReturn err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.cameraTextureCache, pixelBuffer, NULL, GL_TEXTURE_2D, GL_RGBA, frameWidth, frameHeight, GL_BGRA, GL_UNSIGNED_BYTE, 0, &cameraTexture);
    if (err) {
        NSLog(@"Create Texture Failed: %d", err);
    }
    
    glBindTexture(CVOpenGLESTextureGetTarget(cameraTexture), CVOpenGLESTextureGetName(cameraTexture));
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferID);
    glViewport(0, 0, _renderBufferWidth, _renderBufferHeight);
    
    // Use shader program.
    [_shader use];
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGRect insideRect = AVMakeRectWithAspectRatioInsideRect(CGSizeMake(frameWidth, frameHeight), bounds);
    CGFloat heightScaling, widthScaling;
    widthScaling = bounds.size.height / insideRect.size.height;
    heightScaling = bounds.size.width / insideRect.size.width;
    _imageVertices[0] = -widthScaling;
    _imageVertices[1] = -heightScaling;
    _imageVertices[2] = widthScaling;
    _imageVertices[3] = -heightScaling;
    _imageVertices[4] = -widthScaling;
    _imageVertices[5] = heightScaling;
    _imageVertices[6] = widthScaling;
    _imageVertices[7] = heightScaling;
    
    glVertexAttribPointer(CameraAttributesPosition, 2, GL_FLOAT, 0, 0, _imageVertices);
    glEnableVertexAttribArray(CameraAttributesPosition);
    
    glVertexAttribPointer(CameraAttributesTextureCoordinate, 2, GL_FLOAT, 0, 0, quadTextureData);
    glEnableVertexAttribArray(CameraAttributesTextureCoordinate);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferID);
    
//    runFilter();
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    CFRelease(cameraTexture);
}


#pragma mark - GETTER & SETTER

- (FaceCamera *)faceCamera {
    if (_faceCamera == nil) {
        _faceCamera = [[FaceCamera alloc] initWithDelegate:self];
        _faceCamera.devicePosition = AVCaptureDevicePositionFront;
        _faceCamera.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    return _faceCamera;
}


- (CVOpenGLESTextureCacheRef)cameraTextureCache {
    if (_cameraTextureCache == NULL) {
        CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, self.context, NULL, &_cameraTextureCache);
    }
    return _cameraTextureCache;
}

@end

