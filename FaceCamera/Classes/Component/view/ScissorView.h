//
//  ScissorView.h
//  FaceCamera
//
//  Created by  zcating on 2018/11/7.
//  Copyright © 2018 zcat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@protocol ResolutionDelegate <NSObject>

-(void) resolutionChangeTo:(FCResolutionType)type selectedImage:(UIImage *)image;

@end

@interface ScissorView : UIView

@property (nonatomic, weak) id <ResolutionDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
