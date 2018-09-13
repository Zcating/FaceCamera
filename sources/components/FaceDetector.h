//
//  FaceDetector.h
//  FaceCamera
//
//  Created by  zcating on 2018/8/20.
//  Copyright © 2018 zcat. All rights reserved.
//


@interface FaceDetector : NSObject

+(instancetype)shared;

#if UseOpenCV == 1

-(std::vector<cv::Rect>)rectDetectForImage:(cv::Mat &)faceImage;

#else

-(NSArray *)rectsDetectedForImage:(CIImage *)image;

#endif

@end
