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

@property (nonatomic) AVCaptureDevicePosition devicePosition;

@property (nonatomic) AVCaptureSessionPreset sessionPreset;

@property (nonatomic, weak) id<VideoCameraDelegate> delegate;

@property (nonatomic, strong) UIImage *pasterImage;



- (instancetype)initWithParentView:(UIView *)view;

- (void)start;

- (void)stop;

@end

@protocol VideoCameraDelegate <NSObject>

@optional
-(void)processCIImage:(CIImage *)image;

-(void)processForFaces:(NSArray *)faces;

@end
