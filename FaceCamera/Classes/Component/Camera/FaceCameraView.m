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

@property (nonatomic, strong) UIImage *snapshot;


@end


@implementation FaceCameraView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer addSublayer:self.displayLayer];
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
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


// MARK: PRIVATE



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

//- (void)setFrame:(CGRect)frame {
//    self.displayLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
//    for (UIView *view in self.subviews) {
//        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
//    }
//    [super setFrame:frame];
//}

@end
