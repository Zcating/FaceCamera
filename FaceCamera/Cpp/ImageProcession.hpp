//
//  ImageProcession.hpp
//  FaceCamera
//
//  Created by  zcating on 2018/12/21.
//  Copyright © 2018 zcat. All rights reserved.
//

#ifndef ImageProcession_h
#define ImageProcession_h

namespace fc {
    static void OverlayImage(cv::Mat& image, cv::Mat& mask) {
        cv::Rect rect(0, 0, image.cols, image.rows);
        cv::Mat resizedMask;
        cv::resize(mask, resizedMask, rect.size());

        long channels = image.channels();
        long size = image.rows * image.cols;

        for (long index = 0; index < size; index += 4) {
            // get opacity for the over image.
            double opacity = ((double)resizedMask.data[index + 3]) / 255.;
            
            for(int channel = 0; opacity > 0 && channel < channels; channel++) {
                uchar targetPixel = resizedMask.data[index + channel];
                uchar roiPixel = image.data[index + channel];
                image.data[index + channel] = static_cast<uchar>(roiPixel * (1. - opacity) + targetPixel * opacity);
            }
        }
    }
    
    static cv::Mat PixelBufferToCvMat(CVPixelBufferRef pixelBuffer) {
        
        // need to lock buffer to access the pixels.
        CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
        
        size_t width = CVPixelBufferGetWidth(pixelBuffer);
        size_t height = CVPixelBufferGetHeight(pixelBuffer);
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
        char *baseBuffer = (char *)CVPixelBufferGetBaseAddress(pixelBuffer);
        
        // get opencv image object BGR
        cv::Mat image(static_cast<int>(height), static_cast<int>(width), CV_8UC4, baseBuffer, bytesPerRow);
        
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
        
        return image;
    }
    
    static void SaveCvMatToPixelBuffer(const cv::Mat &image, CVPixelBufferRef pixelBuffer) {
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);

        uint8_t *baseBuffer = (uint8_t *)CVPixelBufferGetBaseAddress(pixelBuffer);
        uint8_t *pixelPtr = (uint8_t *)image.data;
        
        //Mat traslate to sample buffer.
        long size = image.rows * image.cols * image.channels();
        for (int index = 0; index < size; index++) {
            baseBuffer[index] = pixelPtr[index];
        }
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    }
    
    static cv::Mat MatFromUIImage(UIImage *image) {
        CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
        CGFloat cols = image.size.width;
        CGFloat rows = image.size.height;
        
        // 8 bits per component, 4 channels (color channels + alpha)
        cv::Mat cvMat(rows, cols, CV_8UC4);
        
        CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                        cols,                       // Width of bitmap
                                                        rows,                       // Height of bitmap
                                                        8,                          // Bits per component
                                                        cvMat.step[0],              // Bytes per row
                                                        colorSpace,                 // Colorspace
                                                        kCGImageAlphaLast |
                                                        kCGBitmapByteOrderDefault); // Bitmap info flags
        
        CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
        CGContextRelease(contextRef);
        
        return cvMat;
    }
    
    
    static UIImage *MatToUIImage(cv::Mat &cvMat) {
        NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
        CGColorSpaceRef colorSpace;
        
        if (cvMat.elemSize() == 1) {
            colorSpace = CGColorSpaceCreateDeviceGray();
        } else {
            colorSpace = CGColorSpaceCreateDeviceRGB();
        }
        
        CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
        
            // Creating CGImage from cv::Mat
        CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                            cvMat.rows,                                 //height
                                            8,                                          //bits per component
                                            8 * cvMat.elemSize(),                       //bits per pixel
                                            cvMat.step[0],                            //bytesPerRow
                                            colorSpace,                                 //colorspace
                                            kCGImageAlphaNoneSkipLast|kCGBitmapByteOrderDefault,// bitmap info
                                            provider,                                   //CGDataProviderRef
                                            NULL,                                       //decode
                                            false,                                      //should interpolate
                                            kCGRenderingIntentDefault                   //intent
                                            );
        
        
            // Getting UIImage from CGImage
        UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        CGDataProviderRelease(provider);
        CGColorSpaceRelease(colorSpace);
        
        return finalImage;
    }
}

#endif /* ImageProcession_h */
