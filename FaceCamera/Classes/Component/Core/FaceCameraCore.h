//
//  FaceCameraCore.h
//  FaceCamera
//
//  Created by  zcating on 2019/1/15.
//  Copyright © 2019 zcat. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface FaceCameraCore : NSObject

+(instancetype)shared;

-(std::vector<cv::Point_<double>>) getLandmarksWith:(const cv::Mat &)image rect:(const cv::Rect &)rect;

@end

NS_ASSUME_NONNULL_END
