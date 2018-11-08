//
//  FaceCameraView.m
//  FaceCamera
//
//  Created by  zcating on 2018/10/26.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FaceCameraView.h"

#import "FaceCamera.h"


IB_DESIGNABLE
@interface FaceCameraView()<FaceCameraDelegate> {
    FaceCamera *_faceCamera;
}

@property (nonatomic, strong) AVSampleBufferDisplayLayer *displayLayer;

@property (nonatomic, strong, readonly) FaceCamera *faceCamera;


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


- (void)changeRatio:(FCRatioType)ratio {
    
}


- (void) processframe:(CMSampleBufferRef)frame faces:(NSArray *)faces {
    [self.displayLayer enqueueSampleBuffer:frame];
    
    if (self.displayLayer.status == AVQueuedSampleBufferRenderingStatusFailed) {
        [self.displayLayer flush];
    }
    
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(processframe:faces:)]) {
        [self.delegate processframe:frame faces:faces];
    }
}


-(AVSampleBufferDisplayLayer *)displayLayer {
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
        _faceCamera.sessionPreset = AVCaptureSessionPresetHigh;
    }
    return _faceCamera;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.displayLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

@end
