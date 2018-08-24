//
//  VideoCamera.h
//  FaceCamera
//
//  Created by  zcating on 2018/8/21.
//  Copyright © 2018 zcat. All rights reserved.
//

@protocol VideoCameraDelegate;

@interface VideoCamera : NSObject

@property (nonatomic,strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic) AVCaptureDevicePosition defaultAVCaptureDevicePosition;

@property (nonatomic) AVCaptureSessionPreset defaultAVCaptureSessionPreset;

@property (nonatomic, weak) id<VideoCameraDelegate> delegate;

//- (void)startCaptureWithHandler:(CaptureDataBlock)handler;

- (instancetype)initWithParentView:(UIView *)view;

- (void)start;

- (void)stop;

@end

@protocol VideoCameraDelegate

-(void)processCIImage:(CIImage *)image;

@end
