//
//  NativeFaceDetector.m
//  FaceCamera
//
//  Created by  zcating on 2018/10/27.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "NativeFaceDetector.h"


#import "FaceLandmarkDetector.hpp"

@implementation DlibWrapper {
    dlib::shape_predictor sp;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _prepared = NO;
    }
    return self;
}

- (void)prepare {
    NSString *modelFileName = [[NSBundle mainBundle] pathForResource:@"shape_predictor_68_face_landmarks" ofType:@"dat"];
    std::string modelFileNameCString = [modelFileName UTF8String];
    
    dlib::deserialize(modelFileNameCString) >> sp;
    
        // FIXME: test this stuff for memory leaks (cpp object destruction)
    self.prepared = YES;
}

- (void)doWorkOnSampleBuffer:(CMSampleBufferRef)sampleBuffer inRects:(NSArray<NSValue *> *)rects {
    
    if (!self.prepared) {
        [self prepare];
    }
    
    
        // MARK: magic
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
    
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    char *baseBuffer = (char *)CVPixelBufferGetBaseAddress(imageBuffer);
        //    dlib::array2d<dlib::bgr_pixel>img();
    
    long position = 0;
    cv::Mat image((int)height, (int)width, CV_8UC4, baseBuffer, bytesPerRow);
    
    dlib::cv_image<dlib::rgb_alpha_pixel>img(image);
    
        // unlock buffer again until we need it again
    CVPixelBufferUnlockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
    
        // convert the face bounds list to dlib format
    std::vector<dlib::rectangle> convertedRectangles = [DlibWrapper convertCGRectValueArray:rects];
    
    
        // for every detected face
    for (unsigned long j = 0; j < convertedRectangles.size(); ++j)
    {
        dlib::rectangle oneFaceRect = convertedRectangles[j];
        cv::rectangle(image, cv::Point(oneFaceRect.left(), oneFaceRect.top()), cv::Point(oneFaceRect.right(), oneFaceRect.bottom()), cv::Scalar(255,255,255,255));
        
            // detect all landmarks
        dlib::full_object_detection shape = sp(img, oneFaceRect);
        
            // and draw them into the image (samplebuffer)
        for (unsigned long k = 0; k < shape.num_parts(); k++) {
            dlib::point p = shape.part(k);
                //            draw_solid_circle(img, p, 3, dlib::rgb_pixel(0, 255, 255));
            cv::circle(image, cv::Point(p.x(), p.y()), 4, cv::Scalar(255,255,255,255));
        }
    }
    
    
        // lets put everything back where it belongs
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
        // copy dlib image data back into samplebuffer
    uint8_t* pixelPtr = (uint8_t *)image.data;
    int channels = image.channels();
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
    
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}

+ (std::vector<dlib::rectangle>)convertCGRectValueArray:(NSArray<NSValue *> *)rects {
    std::vector<dlib::rectangle> myConvertedRects;
    for (NSValue *rectValue in rects) {
        CGRect rect = [rectValue CGRectValue];
        long left = rect.origin.x;
        long top = rect.origin.y;
        long right = left + rect.size.width;
        long bottom = top + rect.size.height;
        dlib::rectangle dlibRect(left, top, right, bottom);
        
        myConvertedRects.push_back(dlibRect);
    }
    return myConvertedRects;
}

@end
