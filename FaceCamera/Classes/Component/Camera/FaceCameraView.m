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




- (void)processframe:(CMSampleBufferRef)frame faces:(NSArray *)faces {
    
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(processframe:faces:)]) {
        [self.delegate processframe:frame faces:faces];
    }
    
    if (self.displayLayer.status == AVQueuedSampleBufferRenderingStatusFailed) {
        [self.displayLayer flush];
    }

    [self.displayLayer enqueueSampleBuffer:frame];
}


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
    [super setFrame:frame];
}

@end