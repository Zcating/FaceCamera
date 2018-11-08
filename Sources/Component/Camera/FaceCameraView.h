//
//  FaceCameraView.h
//  FaceCamera
//
//  Created by  zcating on 2018/10/26.
//  Copyright © 2018 zcat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FaceCamera.h"

NS_ASSUME_NONNULL_BEGIN


IB_DESIGNABLE
@interface FaceCameraView : UIView

@property (nonatomic, weak) id<FaceCameraDelegate> delegate;

-(void)start;

-(void)stop;

-(void)changeRatio:(FCRatioType)ratio;

@end

NS_ASSUME_NONNULL_END
