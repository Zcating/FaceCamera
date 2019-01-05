//
//  FCImageEditingViewController.h
//  FaceCamera
//
//  Created by  zcating on 2018/12/22.
//  Copyright © 2018 zcat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FCImageEditingViewController : UIViewController

@property (nonatomic) FCResolutionType type;

@property (nonatomic, strong) UIImage *image;

@end

NS_ASSUME_NONNULL_END
