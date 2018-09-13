//
//  BKDetectUitl.m
//  FaceCamera
//
//  Created by  zcating on 2018/8/20.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FaceDetector.h"

NSString * const kFaceCascadeFilename = @"haarcascade_frontalface_alt2";

const int kHaarOptions =  CV_HAAR_FIND_BIGGEST_OBJECT;

@interface FaceDetector() {
    cv::CascadeClassifier _faceDetector;
    
    NSDictionary *_featureParameters;
}


@property (nonatomic, strong) CIDetector *detector;


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
        
#if UseOpenCV == 1
        
        NSString* cascadePath = [[NSBundle mainBundle]
                                 pathForResource:kFaceCascadeFilename
                                 ofType:@"xml"];
        _faceDetector.load([cascadePath UTF8String]);
        
#else
        
        _featureParameters = @{
            CIDetectorSmile: @YES,
            CIDetectorEyeBlink: @YES,
            CIDetectorImageOrientation: @5
        };
        
#endif
        
    }
    return self;
}


#if UseOpenCV == 1

- (std::vector<cv::Rect>)rectDetectForImage:(cv::Mat &)image {
    // 检测人脸并储存
    std::vector<cv::Rect>faces;
    if (image.empty()) {
        return faces;
    }
    _faceDetector.detectMultiScale(image, faces, 1.1, 2, kHaarOptions, cv::Size(60, 60));
    
    return faces;
}

#else

-(CIDetector *)detector {
    if (_detector == nil) {
        // configure the accuracy quality.
        NSDictionary *parameters = @{
            CIDetectorAccuracy: CIDetectorAccuracyHigh
        };
        _detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:parameters];
    }
    return _detector;
}

- (NSArray *)rectsDetectedForImage:(CIImage *)image {
    
    // get detected result.
    NSArray *resultArr = [self.detector featuresInImage:image options:_featureParameters];
//    if (resultArr.count == 0) {
    
    return resultArr;
//    }

//
//    for (CIFaceFeature *feature in resultArr) {
//        CGRect faceRect = feature.bounds;
//
//    }
}


#endif

@end
