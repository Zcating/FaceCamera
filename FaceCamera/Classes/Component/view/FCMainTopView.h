//
//  FCMainTopView.h
//  FaceCamera
//
//  Created by  zcating on 2018/12/28.
//  Copyright © 2018 zcat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FCMainTopViewDelegate <NSObject>

-(void)switchCamera;

-(void)controlResolutionSelector;

@end

@interface FCMainTopView : UIView

@property (nonatomic, strong) id<FCMainTopViewDelegate> delegate;


-(void)changeResolutionImage:(UIImage *)image;

@end
NS_ASSUME_NONNULL_END
