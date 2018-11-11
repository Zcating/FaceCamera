//
//  NativeFaceDetector.m
//  FaceCamera
//
//  Created by  zcating on 2018/10/27.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "LandmarkDetector.h"


#import "FaceLandmarkDetector.hpp"


static inline dlib::rectangle ConvertCVRect(cv::Rect rect);

@implementation LandmarkDetector {
    dlib::shape_predictor sp;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}

- (void)prepare {
    NSString *modelFileName = [[NSBundle mainBundle] pathForResource:@"shape_predictor_68_face_landmarks" ofType:@"dat"];
    std::string modelFileNameCString = [modelFileName UTF8String];
    
    dlib::deserialize(modelFileNameCString) >> sp;
}

- (dlib::full_object_detection)target:(cv::Mat)image inRect:(cv::Rect)rect {
    dlib::cv_image<dlib::rgb_alpha_pixel>img(image);
    return sp(img, ConvertCVRect(rect));
}

@end

static inline dlib::rectangle ConvertCVRect(cv::Rect rect) {
    auto tl = rect.tl();
    auto br = rect.br();
    
    long left = tl.x;
    long top = tl.y;
    long right = br.x;
    long bottom = br.y;
    
    return dlib::rectangle(left, top, right, bottom);
}
