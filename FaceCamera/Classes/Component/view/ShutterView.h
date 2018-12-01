//
//  ShutterView.h
//  FaceCamera
//
//  Created by  zcating on 2018/9/3.
//  Copyright © 2018 zcat. All rights reserved.
//
#import <UIKit/UIKit.h>

typedef void(^ShutterBlock)(void);

@interface ShutterView : UIView

-(void)pressShutter:(ShutterBlock)block;


@end
