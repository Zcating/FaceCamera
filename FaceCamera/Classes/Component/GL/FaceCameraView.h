//
//  FaceCameraView.h
//  FaceCamera
//
//  Created by  zcating on 2018/10/26.
//  Copyright © 2018 zcat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

#import "FaceCamera.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^FilterBlock)(void);

@interface FaceCameraView : GLKView

@property (nonatomic, weak) id<FaceCameraDelegate> cameraDelegate;

-(void)start;

-(void)stop;

-(void)switchCamera;

@end

NS_ASSUME_NONNULL_END
