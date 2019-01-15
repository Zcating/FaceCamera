//
//  FaceCamera.h
//  FaceCamera
//
//  Created by  zcating on 2018/8/21.
//  Copyright © 2018 zcat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol FaceCameraDelegate;

typedef NS_ENUM(NSUInteger, FCRatioType) {
    FCRatioType4To3,
    FCRatioType16To9,
    FCRatioType1To1,
    FCRatioTypeRound
};


@interface FaceCamera : NSObject

// NSString type
@property (nonatomic, copy) AVCaptureSessionPreset sessionPreset;

@property (nonatomic) AVCaptureDevicePosition devicePosition;

@property (nonatomic) AVCaptureVideoOrientation orientation;

@property (nonatomic, weak) id<FaceCameraDelegate> delegate;

- (instancetype)initWithDelegate:(id<FaceCameraDelegate>)delegate;

- (void)start;

- (void)stop;

- (void)pause;

- (void)switchCameras;

@end

@protocol FaceCameraDelegate <NSObject>


-(void)processframe:(CMSampleBufferRef)frame faces:(NSArray *)faces;


@end
