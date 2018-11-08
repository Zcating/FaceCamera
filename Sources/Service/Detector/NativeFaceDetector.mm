//
//  NativeFaceDetector.m
//  FaceCamera
//
//  Created by  zcating on 2018/10/27.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "NativeFaceDetector.h"


#import "FaceLandmarkDetector.hpp"

NSString * const kFaceCascadeFilename = @"haarcascade_frontalface_alt2";

const int kHaarOptions =  CV_HAAR_FIND_BIGGEST_OBJECT;


using namespace cv;
using namespace cv::face;


@interface NativeFaceDetector() {
//    cv::CascadeClassifier _faceDetector;
//    std::shared_ptr<fc::FaceLandmarkDetector> landmarkDetector;
}

@property (nonatomic, strong) NSArray *metadataObjects;



@end

@implementation NativeFaceDetector



- (instancetype) init {
    self = [super init];
    if (self) {
//        landmarkDetector = std::make_shared<fc::FaceLandmarkDetector>();
        
            //        NSString *modelFileName = [[NSBundle mainBundle] pathForResource:@"shape_predictor_68_face_landmarks" ofType:@"dat"];
            //        std::string modelFileNameCString = [modelFileName UTF8String];
            //
            //        landmarkDetector->use(DlibModule, modelFileName);
        
        
//        NSString *modelFileName = [[NSBundle mainBundle] pathForResource:@"lbfmodel" ofType:@"yaml"];
//        std::string modelFileNameCString = [modelFileName UTF8String];
//
//        landmarkDetector->use(fc::FaceLandmarkDetector::OpencvModel, modelFileNameCString);
        
    }
    return self;
}



-(NSArray *)detectFaceByAVCaptureOutput:(AVCaptureOutput *)output fromConnection:(AVCaptureConnection *)connection {
    if (self.metadataObjects.count == 0) {
        return nil;
    }
    NSMutableArray *bounds = [NSMutableArray arrayWithCapacity:2];
    for (AVMetadataObject *object in self.metadataObjects) {
        if([object isKindOfClass:[AVMetadataFaceObject class]]) {
            AVMetadataObject *face = [output transformedMetadataObjectForMetadataObject:object connection:connection];

            [bounds addObject:[NSValue valueWithCGRect:face.bounds]];
        }
    }
    return bounds;
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    self.metadataObjects = metadataObjects;
}


//-(void)faceLandmarkDetectOn:(CMSampleBufferRef)sampleBuffer inRects:(NSArray<NSValue *> *)rects landmarkResult:(void(^)(long index, CGPoint point))landmarkResult {
//
//    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//
//    CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
//
//    size_t width = CVPixelBufferGetWidth(imageBuffer);
//    size_t height = CVPixelBufferGetHeight(imageBuffer);
//    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
//    char *baseBuffer = (char *)CVPixelBufferGetBaseAddress(imageBuffer);
//
//    cv::Mat pixelBuffer((int)height, (int)width, CV_8UC4, baseBuffer, bytesPerRow);
//
//
//    CVPixelBufferUnlockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
//
//        //    std::vector<dlib::rectangle> faceRects;
//        //    for (NSValue *value in rects) {
//        //        faceRects.push_back([self convertCGRect:value]);
//        //    }
//        //    landmarkDetector->detectLandmark(dPixelBuffer, faceRects, [&](dlib::full_object_detection& detection) {
//        //        for (long index = 0; index < detection.num_parts(); index++) {
//        //            dlib::point point = detection.part(index);
//        //            if (landmarkResult != nil) {
//        //                CGPoint cgPoint = CGPointMake(point.x(), point.y());
//        //                landmarkResult(index, cgPoint);
//        //            }
//        //        }
//        //    });
//
//    std::vector<cv::Rect> faceRects;
//    for (NSValue *value in rects) {
//        CGRect rectValue = value.CGRectValue;
//        CGFloat midX = rectValue.origin.x + rectValue.size.width / 2;
//        CGFloat midY = rectValue.origin.y + rectValue.size.height / 2;
//        CGFloat radius = rectValue.size.width > rectValue.size.height ? rectValue.size.width / 2 : rectValue.size.height / 2;
//        radius *= 1.5;
//            //
//        CGFloat top = midX - radius;
//        CGFloat left = midY - radius;
//        CGFloat sideLength = radius * 2;
//            //
//        cv::Rect faceRect1(top, left, sideLength, sideLength);
//        cv::Rect faceRect(rectValue.origin.x, rectValue.origin.y, rectValue.size.width, rectValue.size.height);
//
//        cv::rectangle(pixelBuffer, faceRect.tl(), faceRect.br(), cv::Scalar(0, 0, 255, 255));
//        cv::rectangle(pixelBuffer, faceRect1.tl(), faceRect1.br(), cv::Scalar(0,0, 255, 255));
//
//        faceRects.push_back(faceRect1);
//    }
//
//    landmarkDetector->detectLandmark(pixelBuffer, faceRects);
//
//        //        if (landmarkResult != nil) {
//        //            CGPoint cgPoint = CGPointMake(point.x(), point.y());
//        //            landmarkResult(index, cgPoint);
//        //        }
//
//    CVPixelBufferLockBaseAddress(imageBuffer, 0);
//
//        //    pixelBuffer = dlib::toMat(dPixelBuffer);
//
//    width = CVPixelBufferGetWidth(imageBuffer);
//    height = CVPixelBufferGetHeight(imageBuffer);
//    baseBuffer = (char *)CVPixelBufferGetBaseAddress(imageBuffer);
//
//    int channels = pixelBuffer.channels();
//    cv::Scalar_<uint8_t> rgbPixel;
//    uint8_t* pixelPtr = (uint8_t *)pixelBuffer.data;
//
//
//    long position = 0;
//    for(int i = 0; i < pixelBuffer.rows; i++)
//    {
//        for(int j = 0; j < pixelBuffer.cols; j++)
//        {
//            long bufferLocation = position * 4;
//
//            rgbPixel.val[0] = pixelPtr[i * pixelBuffer.cols * channels + j * channels + 0];
//            rgbPixel.val[1] = pixelPtr[i * pixelBuffer.cols * channels + j * channels + 1];
//            rgbPixel.val[2] = pixelPtr[i * pixelBuffer.cols * channels + j * channels + 2];
//            rgbPixel.val[3] = pixelPtr[i * pixelBuffer.cols * channels + j * channels + 3];
//
//            baseBuffer[bufferLocation] = rgbPixel.val[0];
//            baseBuffer[bufferLocation + 1] = rgbPixel.val[1];
//            baseBuffer[bufferLocation + 2] = rgbPixel.val[2];
//            baseBuffer[bufferLocation + 3] = rgbPixel.val[3];
//
//            position++;
//        }
//    }
//
//    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
//}
//
//
//-(dlib::rectangle)convertCGRect:(NSValue *)rectValue {
//    CGRect rect = [rectValue CGRectValue];
//    long left = rect.origin.x;
//    long top = rect.origin.y;
//    long right = left + rect.size.width;
//    long bottom = top + rect.size.height;
//    return dlib::rectangle(left, top, right, bottom);
//}


@end
