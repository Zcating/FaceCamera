//
//  FaceCameraView.m
//  FaceCamera
//
//  Created by  zcating on 2018/10/26.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FaceCameraView.h"

//#import "MaskGLView.h"

#import "FaceCamera.h"


@interface FaceCameraView()<FaceCameraDelegate>

@property (nonatomic, strong) AVSampleBufferDisplayLayer *displayLayer;

@property (nonatomic, strong) FaceCamera *faceCamera;

//@property (nonatomic, strong) MaskGLView *glView;

@end


@implementation FaceCameraView


-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}



-(void)start {
    [self.faceCamera start];
}

-(void)stop {
    [self.faceCamera stop];
}

-(void)takePhoto {
    UIGraphicsBeginImageContext(self.bounds.size);

    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
//    return image;
}

-(void)switchCamera {
    [self.faceCamera switchCameras];
}

- (void)processframe:(CMSampleBufferRef)frame faces:(NSArray *)faces {
    
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(processframe:faces:)]) {
        [self.delegate processframe:frame faces:faces];
    }
    
    if (self.displayLayer.status == AVQueuedSampleBufferRenderingStatusFailed) {
        [self.displayLayer flush];
    }

    [self.displayLayer enqueueSampleBuffer:frame];
}


// MARK: GETTER & SETTER

- (AVSampleBufferDisplayLayer *)displayLayer {
    if (_displayLayer == nil) {
        _displayLayer = [AVSampleBufferDisplayLayer layer];
        _displayLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.layer addSublayer:_displayLayer];
        _displayLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
    return _displayLayer;
}

- (FaceCamera *)faceCamera {
    if (_faceCamera == nil) {
        _faceCamera = [[FaceCamera alloc] initWithDelegate:self];
        _faceCamera.devicePosition = AVCaptureDevicePositionFront;
        _faceCamera.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    return _faceCamera;
}

- (void)setFrame:(CGRect)frame {
    self.displayLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    for (UIView *view in self.subviews) {
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }
    [super setFrame:frame];
}

@end
