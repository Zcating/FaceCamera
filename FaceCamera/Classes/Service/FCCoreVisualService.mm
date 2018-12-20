//
//  FCCoreVisualService.m
//  FaceCamera
//
//  Created by  zcating on 2018/11/10.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FCCoreVisualService.h"
#import "FaceCore.hpp"


static inline dlib::rectangle ConvertCVRect(const cv::Rect& rect);


@interface FCCoreVisualService () {
    dlib::shape_predictor _shapePredictor;
//    std::shared_ptr<fc::FaceCore> _faceCore;
}

@property (nonatomic, copy) SnapshotBlock snapshotBlock;

@property (nonatomic) BOOL enableSnapshot;

@property (nonatomic, strong) UIImage *snapshot;

@end

@implementation FCCoreVisualService

- (instancetype)init {
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}


- (void)prepare {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"shape_predictor_68_face_landmarks" ofType:@"dat"];
    dlib::deserialize([path UTF8String]) >> _shapePredictor;

//    _faceCore = std::make_shared<fc::FaceCore>(1080, 1920);
    
}



- (void)runWithSampleBuffer:(CMSampleBufferRef)sampleBuffer inRects:(NSArray<NSValue *> *)faces forLandmarkBlock:(LandmarkBlock)landmarkBlock {
    
    // get all pixels in the frame.
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // need to lock buffer to access the pixels.
    CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    char *baseBuffer = (char *)CVPixelBufferGetBaseAddress(pixelBuffer);
    
    // get opencv image object
    cv::Mat image((int)height, (int)width, CV_8UC4, baseBuffer, bytesPerRow);
    
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    
    [faces enumerateObjectsUsingBlock:^(NSValue * _Nonnull value, NSUInteger index, BOOL * _Nonnull stop) {
        CGRect rectValue = value.CGRectValue;
            //
        cv::Rect faceRect(rectValue.origin.x, rectValue.origin.y, rectValue.size.width, rectValue.size.height);
        
        auto landmarks = self->_shapePredictor(dlib::cv_image<dlib::rgb_alpha_pixel>(image), ConvertCVRect(faceRect));
        
#ifdef FC_DEBUG
        cv::rectangle(image, faceRect.tl(), faceRect.br(), cv::Scalar(0, 0, 255, 255), 2);
        
        for (auto index = 0; index < landmarks.num_parts(); index++) {
            auto p = landmarks.part(index);
            cv::Point point(static_cast<int>(p.x()), static_cast<int>(p.y()));
            cv::circle(image, point, 2, cv::Scalar(255, 255, 0, 0));
        }
#endif
        std::vector<cv::Point_<double>> cvLandmarks(landmarks.num_parts(), cv::Point(0, 0));
        for (auto index = 0; index < landmarks.num_parts(); index++) {
            const auto& landmark = landmarks.part(index);
            auto& point = cvLandmarks[index];
            point.x = static_cast<double>(landmark.x());
            point.y = static_cast<double>(landmark.y());
        }
        landmarkBlock(cvLandmarks, index);
    }];
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    width = CVPixelBufferGetWidth(pixelBuffer);
    height = CVPixelBufferGetHeight(pixelBuffer);
    baseBuffer = (char *)CVPixelBufferGetBaseAddress(pixelBuffer);
    
    uint8_t *pixelPtr = (uint8_t *)image.data;
    
    // traslate to sample buffer.
    long size = image.rows * image.cols * image.channels();
    for (int index = 0; index < size; index++) {
        baseBuffer[index] = pixelPtr[index];
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    if(self.enableSnapshot) {
        [self startSnapshot:pixelBuffer];
        self.enableSnapshot = NO;
    }
}

-(void)getSnapshot:(SnapshotBlock)block {
    self.enableSnapshot = YES;
    self.snapshotBlock = block;
}



-(void)startSnapshot:(CVPixelBufferRef)pixelBuffer {
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    void *baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    if(self.snapshotBlock) {
        self.snapshotBlock(image);
        self.snapshotBlock = nil;
    }
//    dispatch_semaphore_signal(self.semaphore);
}


@end


static inline dlib::rectangle ConvertCVRect(const cv::Rect& rect) {
    auto tl = rect.tl();
    auto br = rect.br();
    
    long left = tl.x;
    long top = tl.y;
    long right = br.x;
    long bottom = br.y;
    
    return dlib::rectangle(left, top, right, bottom);
}
