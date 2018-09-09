//
//  BKDetectUitl.m
//  FaceCamera
//
//  Created by  zcating on 2018/8/20.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FaceDetector.h"

NSString * const kFaceCascadeFilename = @"haarcascade_frontalface_alt2";

const int kHaarOptions =  CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_DO_ROUGH_SEARCH;

@interface FaceDetector() {
    cv::CascadeClassifier _faceDetector;
}


@end

@implementation FaceDetector

+ (instancetype)shared {
    static FaceDetector *detector;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        detector = [[FaceDetector alloc] init];
    });
    return detector;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        NSString* cascadePath = [[NSBundle mainBundle]
                                 pathForResource:kFaceCascadeFilename
                                 ofType:@"xml"];
        _faceDetector.load([cascadePath UTF8String]);
    }
    return self;
}

- (std::vector<cv::Rect>)rectDetectForImage:(cv::Mat &)image {
    // 检测人脸并储存
    std::vector<cv::Rect>faces;
    if (image.empty()) {
        return faces;
    }
    _faceDetector.detectMultiScale(image, faces, 1.1, 2, kHaarOptions, cv::Size(60, 60));
    
    return faces;
}

@end
