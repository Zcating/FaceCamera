//
//  FaceDetector.mm
//  FaceCamera
//
//  Created by  zcating on 2018/8/20.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FaceDetector.h"


@interface FaceDetector() {

//    dlib::shape_predictor shapePredictor;

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
//        NSString *modelFileName = [[NSBundle mainBundle] pathForResource:@"shape_predictor_68_face_landmarks" ofType:@"dat"];
//        std::string modelFileNameCString = [modelFileName UTF8String];
//
//        dlib::deserialize(modelFileNameCString) >> shapePredictor;
    }
    return self;
}


-(void)detectOn:(CMSampleBufferRef)sampleBuffer inRects:(NSArray<NSValue *> *)rects {
}


-(void)faceLandmarkDetectOn:(CMSampleBufferRef)sampleBuffer inRects:(NSArray<NSValue *> *)rects {
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
    
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    char *baseBuffer = (char *)CVPixelBufferGetBaseAddress(imageBuffer);

    cv::Mat pixelBuffer((int)height, (int)width, CV_8UC4, baseBuffer,     CVPixelBufferGetBytesPerRow(imageBuffer));
    
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
    

    for (NSValue *value in rects) {
        CGRect rect = value.CGRectValue;
        cv::Rect face(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
        cv::Scalar magenta = cv::Scalar(255, 0, 0, 255);
        cv::rectangle(pixelBuffer, face.tl(), face.br(), magenta, 11, 8, 0);
    }
    
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    
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
            
            rgbPixel.val[0] = pixelPtr[i*pixelBuffer.cols*cn + j*cn + 0]; // B
            rgbPixel.val[1] = pixelPtr[i*pixelBuffer.cols*cn + j*cn + 1]; // G
            rgbPixel.val[2] = pixelPtr[i*pixelBuffer.cols*cn + j*cn + 2]; // R
            
            baseBuffer[bufferLocation] = rgbPixel.val[0];
            baseBuffer[bufferLocation + 1] = rgbPixel.val[1];
            baseBuffer[bufferLocation + 2] = rgbPixel.val[2];
            
            position++;
        }
    }
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);

//
//    dlib::array2d<dlib::bgr_pixel> pixelBuffer;
//    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//
//    // operation for pixel.
//    CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
//
//    size_t width = CVPixelBufferGetWidth(imageBuffer);
//    size_t height = CVPixelBufferGetHeight(imageBuffer);
//    char *baseBuffer = (char *)CVPixelBufferGetBaseAddress(imageBuffer);
//
//    pixelBuffer.set_size(height, width);
//
//    pixelBuffer.reset();
//    long position = 0;
//    while (pixelBuffer.move_next()) {
//        // ref of pixel
//        dlib::bgr_pixel& pixel = pixelBuffer.element();
//
//        // step for each pixel.
//        long location = position * 4;
//        char blue   = baseBuffer[location];
//        char green  = baseBuffer[location + 1];
//        char red    = baseBuffer[location + 2];
//
//        // BGRA
////        char alpha = baseBuffer[location + 3];
//
//
//        pixel = dlib::bgr_pixel(blue, green, red);
//
//        position++;
//    }
//    CVPixelBufferUnlockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
//
//    std::vector<dlib::rectangle> rectangles = [self convertCGRectArray:rects];
//
//    for (dlib::rectangle faceRect: rectangles) {
//        dlib::full_object_detection shape = shapePredictor(pixelBuffer, faceRect);
////        for (long index = 0; index < shape.num_parts(); index++) {
////            dlib::point point = shape.part(index);
////
////
////            // arg 1: the 2D array of the image.
////            // arg 2: the coordination of the circle.
////            // arg 3: the radius of the circle.
////            // arg 4: the pixel of the circle.
////            draw_solid_circle(pixelBuffer, point, 3, dlib::rgb_pixel(0, 255, 255));
////        }
//
//        dlib::draw_rectangle(pixelBuffer, faceRect, dlib::rgb_pixel(0, 225, 225), 10);
//    }
//
//    CVPixelBufferLockBaseAddress(imageBuffer, 0);
//
//
//    pixelBuffer.reset();
//    for (long position = 0; pixelBuffer.move_next(); position++) {
//        dlib::bgr_pixel& pixel = pixelBuffer.element();
//        long location = position * 4;
//        baseBuffer[location] = pixel.blue;
//        baseBuffer[location + 1] = pixel.green;
//        baseBuffer[location + 2] = pixel.red;
//    }
//
//    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}

//-(std::vector<dlib::rectangle>)convertCGRectArray:(NSArray *)rects {
//    std::vector<dlib::rectangle> convertedRects;
//    for (NSValue *rectValue in rects) {
//        CGRect rect = [rectValue CGRectValue];
//        long left = rect.origin.x;
//        long top = rect.origin.y;
//        long right = left + rect.size.width;
//        long bottom = top + rect.size.height;
//        dlib::rectangle dlibRect(left, top, right, bottom);
//
//        convertedRects.push_back(dlibRect);
//    }
//    return convertedRects;
//}


@end
