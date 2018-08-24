//
//  FaceDetector.h
//  FaceCamera
//
//  Created by  zcating on 2018/8/20.
//  Copyright © 2018 zcat. All rights reserved.
//


@interface FaceDetector : NSObject



-(std::vector<cv::Rect>)rectDetectForImage:(cv::Mat &)faceImage;

@end
