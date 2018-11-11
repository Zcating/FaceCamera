//
//  BaseViewController.h
//  FaceCamera
//
//  Created by  zcating on 2018/11/9.
//  Copyright © 2018 zcat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController

-(__kindof UIViewController *)findChildViewController:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
