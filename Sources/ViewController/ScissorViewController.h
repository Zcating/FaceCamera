//
//  ScissorViewController.h
//  FaceCamera
//
//  Created by  zcating on 2018/11/7.
//  Copyright © 2018 zcat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FaceCamera.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ScissorBlock)(double ratio);


@interface ScissorViewController : UIViewController

@property (nonatomic, copy) ScissorBlock block;



@end

NS_ASSUME_NONNULL_END
