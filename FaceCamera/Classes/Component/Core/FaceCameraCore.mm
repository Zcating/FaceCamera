//
//  FaceCameraCore.m
//  FaceCamera
//
//  Created by  zcating on 2019/1/15.
//  Copyright © 2019 zcat. All rights reserved.
//

#import "FaceCameraCore.h"
#import "FaceCore.hpp"

@interface FaceCameraCore() {
    fc::FaceCore _faceCore;
}

@end

@implementation FaceCameraCore

+(instancetype)shared {
    static FaceCameraCore *core;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        core = [[FaceCameraCore alloc] init];
    });
    return core;
}

-(instancetype)init {
    self = [super init];
    if (self){
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:@"shape_predictor_68_face_landmarks" ofType:@"dat"];
        _faceCore.prepare([path UTF8String]);
    }
    return self;
}

-(std::vector<cv::Point_<double>>)getLandmarksWith:(const cv::Mat &)image rect:(const cv::Rect &)rect {
    return _faceCore.landmarks(image, rect);
}

@end
