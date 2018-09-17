//
//  FaceView.h
//  BikaCamera
//
//  Created by  zcating on 2018/8/26.
//  Copyright © 2018 zcat. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "VideoCamera.h"

@interface FaceView : UIView <
VideoCameraDelegate
//,CvVideoCameraDelegate
>

@property (nonatomic, strong) CIDetector *detector;

#if UseOpenCV == 1

@property (nonatomic, strong) CvVideoCamera * camera;


#else
@property (nonatomic, strong) VideoCamera *camera;

//@property (nonatomic, strong) CALayer *faceLayer;

//@property (nonatomic, strong) NSMutableArray<CALayer *> *faceLayers;
#endif

@property (nonatomic, strong) UIView *faceContentView;

-(void)startCapture;


@end
