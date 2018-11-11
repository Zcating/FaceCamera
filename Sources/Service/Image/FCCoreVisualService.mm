//
//  FCCoreVisualService.m
//  FaceCamera
//
//  Created by  zcating on 2018/11/10.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FCCoreVisualService.h"


static inline dlib::rectangle ConvertCVRect(cv::Rect rect);



@interface FCCoreVisualService () {
    dlib::shape_predictor shapePredictor;
}


@end

@implementation FCCoreVisualService

- (instancetype)init {
    self = [super init];
    if (self) {
//        self.detector = [LandmarkDetector new];
        [self prepare];
    }
    return self;
}


- (void)prepare {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"shape_predictor_68_face_landmarks" ofType:@"dat"];
    
    dlib::deserialize([path UTF8String]) >> shapePredictor;
}



- (void)runWithSampleBuffer:(CMSampleBufferRef)sampleBuffer inRects:(NSArray<NSValue *> *)faces {
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
//    dlib::cv_image<dlib::rgb_alpha_pixel> dimg(image);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    
    
    for (NSValue *value in faces) {
        CGRect rectValue = value.CGRectValue;
//        CGFloat midX = rectValue.origin.x + rectValue.size.width / 2;
//        CGFloat midY = rectValue.origin.y + rectValue.size.height / 2;
//        CGFloat radius = rectValue.size.width > rectValue.size.height ? rectValue.size.width / 2 : rectValue.size.height / 2;
//        radius *= 1.5;
//        //
//        CGFloat top = midX - radius;
//        CGFloat left = midY - radius;
//        CGFloat sideLength = radius * 2;
        //
        cv::Rect rect(rectValue.origin.x, rectValue.origin.y, rectValue.size.width, rectValue.size.height);
        
#ifdef FC_DEBUG
        cv::rectangle(image, rect.tl(), rect.br(), cv::Scalar(0, 0, 255, 255), 2);
#endif
        [self processForLandmarkWithImage:image inRect:rect];
        
//        auto result = shapePredictor(dimg, ConvertCVRect(rect));
////
//        for (auto index = 0; index < result.num_parts(); index++) {
//            auto p = result.part(index);
//            cv::Point point(static_cast<int>(p.x()), static_cast<int>(p.y()));
//            cv::circle(image, point, 4, cv::Scalar(255, 255, 0, 255));
//        }
    }
    
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    
    width = CVPixelBufferGetWidth(pixelBuffer);
    height = CVPixelBufferGetHeight(pixelBuffer);
    baseBuffer = (char *)CVPixelBufferGetBaseAddress(pixelBuffer);
    
    int channels = image.channels();
    uint8_t* pixelPtr = (uint8_t *)image.data;
    
        // traslate to sample buffer.
    long position = 0;
    for(int i = 0; i < image.rows; i++) {
        for(int j = 0; j < image.cols; j++) {
            long bufferLocation = position * 4;
                // blue
            baseBuffer[bufferLocation]  = pixelPtr[i * image.cols * channels + j * channels + 0];
                // green
            baseBuffer[bufferLocation + 1] = pixelPtr[i * image.cols * channels + j * channels + 1];
                // red
            baseBuffer[bufferLocation + 2] = pixelPtr[i * image.cols * channels + j * channels + 2];
                // alpha
            baseBuffer[bufferLocation + 3] = pixelPtr[i * image.cols * channels + j * channels + 3];
            
            position++;
        }
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
}


-(void)processForLandmarkWithImage:(cv::Mat)image inRect:(cv::Rect)rect {
    // get dlib image object
    auto result = shapePredictor(dlib::cv_image<dlib::rgb_alpha_pixel>(image), ConvertCVRect(rect));
    
    for (auto index = 0; index < result.num_parts(); index++) {
        auto p = result.part(index);
        cv::Point point(static_cast<int>(p.x()), static_cast<int>(p.y()));
        cv::circle(image, point, 2, cv::Scalar(255, 255, 0, 255));
    }
}

//- ()

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



