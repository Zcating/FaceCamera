//
//  FaceCamera.h
//  FaceCamera
//
//  Created by  zcating on 2018/8/21.
//  Copyright © 2018 zcat. All rights reserved.
//

@protocol FaceCameraDelegate;

typedef NS_ENUM(NSUInteger, FCRatioType) {
    FCRatioType4To3,
    FCRatioType16To9,
    FCRatioType1To1,
    FCRatioTypeRound
};


@interface FaceCamera : NSObject

@property (nonatomic) AVCaptureDevicePosition devicePosition;

@property (nonatomic) AVCaptureSessionPreset sessionPreset;

@property (nonatomic) FCRatioType type;

@property (nonatomic, weak) id<FaceCameraDelegate> delegate;

@property (nonatomic, strong, readonly) UIImage *pasterImage;


- (instancetype)initWithDelegate:(id<FaceCameraDelegate>)delegate;

- (void)start;

- (void)stop;

@end

@protocol FaceCameraDelegate <NSObject>


-(void)processframe:(CMSampleBufferRef)frame faces:(NSArray *)faces;


@end
