//
//  FaceDetector.mm
//  FaceCamera
//
//  Created by  zcating on 2018/8/20.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FaceDetector.h"

#import "FaceLandmarkDetector.hpp"

NSString * const kFaceCascadeFilename = @"haarcascade_frontalface_alt2";

const int kHaarOptions =  CV_HAAR_FIND_BIGGEST_OBJECT;

using namespace cv;
//using namespace cv::face;


@interface FaceDetector() {
    cv::CascadeClassifier _faceDetector;

    fc::FaceLandmarkDetector *landmarkDetector;
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
        NSString *modelFileName = [[NSBundle mainBundle] pathForResource:@"shape_predictor_68_face_landmarks" ofType:@"dat"];
        std::string modelFileNameCString = [modelFileName UTF8String];
        
//        Ptr<cv::face::Facemark> facemark = FacemarkLBF::create();
        landmarkDetector = new fc::FaceLandmarkDetector(modelFileNameCString);
    }
    return self;
}



-(void)faceLandmarkDetectOn:(CMSampleBufferRef)sampleBuffer inRects:(NSArray<NSValue *> *)rects landmarkResult:(void(^)(long index, CGPoint point))landmarkResult {
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);

    CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);

    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    char *baseBuffer = (char *)CVPixelBufferGetBaseAddress(imageBuffer);
    
    cv::Mat pixelBuffer((int)height, (int)width, CV_8UC4, baseBuffer, bytesPerRow);
    
    dlib::cv_image<dlib::rgb_alpha_pixel> dPixelBuffer(pixelBuffer);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);

    std::vector<dlib::rectangle> faceRects;
    for (NSValue *value in rects) {
        faceRects.push_back([self convertCGRect:value]);
    }
    
    landmarkDetector->detectLandmark(dPixelBuffer, faceRects, [&](dlib::full_object_detection& detection) {
        for (long index = 0; index < detection.num_parts(); index++) {
            dlib::point point = detection.part(index);
            if (landmarkResult != nil) {
                CGPoint cgPoint = CGPointMake(point.x(), point.y());
                landmarkResult(index, cgPoint);
            }
        }
    });

//    dlib::full_object_detection shape = shapePredictor(dPixelBuffer, faceRect);
//    for (long index = 0; index < shape.num_parts(); index++) {
//        dlib::point dpoint = shape.part(index);
//        draw_solid_circle(dPixelBuffer, dpoint, 3, dlib::rgb_pixel(0, 255, 255));
//
//        cv::Point point((int)dpoint.x(), (int)dpoint.y());
//        std::string indexString = [[NSString stringWithFormat:@"%ld", index] UTF8String];
//        putText(pixelBuffer, indexString, point, cv::FONT_HERSHEY_DUPLEX, 1, cv::Scalar(0, 255, 0), 1);
//    }

    CVPixelBufferLockBaseAddress(imageBuffer, 0);

    pixelBuffer = dlib::toMat(dPixelBuffer);
    
    width = CVPixelBufferGetWidth(imageBuffer);
    height = CVPixelBufferGetHeight(imageBuffer);
    baseBuffer = (char *)CVPixelBufferGetBaseAddress(imageBuffer);

    int cn = pixelBuffer.channels();
    cv::Scalar_<uint8_t> rgbPixel;
    uint8_t* pixelPtr = (uint8_t *)pixelBuffer.data;


    long position = 0;
    for(int i = 0; i < pixelBuffer.rows; i++)
    {
        for(int j = 0; j < pixelBuffer.cols; j++)
        {
            long bufferLocation = position * 4;

            rgbPixel.val[0] = pixelPtr[i*pixelBuffer.cols*cn + j*cn + 0];
            rgbPixel.val[1] = pixelPtr[i*pixelBuffer.cols*cn + j*cn + 1];
            rgbPixel.val[2] = pixelPtr[i*pixelBuffer.cols*cn + j*cn + 2];
            rgbPixel.val[3] = pixelPtr[i*pixelBuffer.cols*cn + j*cn + 3];
            
            baseBuffer[bufferLocation] = rgbPixel.val[0];
            baseBuffer[bufferLocation + 1] = rgbPixel.val[1];
            baseBuffer[bufferLocation + 2] = rgbPixel.val[2];
            baseBuffer[bufferLocation + 3] = rgbPixel.val[3];
            
            position++;
        }
    }

    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}


-(dlib::rectangle)convertCGRect:(NSValue *)rectValue {
    CGRect rect = [rectValue CGRectValue];
    long left = rect.origin.x;
    long top = rect.origin.y;
    long right = left + rect.size.width;
    long bottom = top + rect.size.height;
    return dlib::rectangle(left, top, right, bottom);
}


@end
