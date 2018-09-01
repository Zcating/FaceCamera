//
//  FaceView.h
//  BikaCamera
//
//  Created by  zcating on 2018/8/26.
//  Copyright © 2018 zcat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VideoCamera.h"

@interface FaceView : UIView <VideoCameraDelegate>

@property (nonatomic, strong) CIDetector *detector;

@property (nonatomic, strong) VideoCamera *camera;

@property (nonatomic, strong) CALayer *faceLayer;

@property (nonatomic, strong) NSMutableArray<CALayer *> *faceLayers;

@property (nonatomic, strong) UIView *faceContentView;

-(void)startCapture;

-(UIImage *)takeOnePhoto;

@end
