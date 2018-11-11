//
//  NativeFaceDetector.h
//  FaceCamera
//
//  Created by  zcating on 2018/10/27.
//  Copyright © 2018 zcat. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FaceDetector.h"

NS_ASSUME_NONNULL_BEGIN

@interface LandmarkDetector : NSObject


- (dlib::full_object_detection)target:(cv::Mat)image inRect:(cv::Rect)rect;

@end

NS_ASSUME_NONNULL_END
