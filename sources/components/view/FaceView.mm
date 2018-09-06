//
//  FaceView.m
//  BikaCamera
//
//  Created by  zcating on 2018/8/26.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FaceView.h"

@implementation FaceView


- (void)drawRect:(CGRect)rect {
    [self addSubview:self.faceContentView];

}

#if UseOpenCV == 1

-(CvVideoCamera *)camera {
    if (_camera == nil) {
        _camera = [[CvVideoCamera alloc] initWithParentView:self];
        _camera.delegate = self;
        _camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
        _camera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetHigh;
        _camera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
        _camera.defaultFPS = 120;
        _camera.useAVCaptureVideoPreviewLayer = YES;
        _camera.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _camera;
}

#else

-(VideoCamera *)camera {
    if (_camera == nil) {
        _camera = [[VideoCamera alloc] initWithParentView:self];
        _camera.delegate = self;
        _camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
        _camera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetHigh;
    }
    return _camera;
}

#endif

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

-(UIView *)faceContentView {
    if (_faceContentView == nil) {
        _faceContentView = [[UIView alloc] init];
        _faceContentView.backgroundColor = [UIColor clearColor];
        _faceContentView.layer.masksToBounds = YES;
        _faceContentView.layer.borderColor = [UIColor yellowColor].CGColor;
        _faceContentView.layer.borderWidth = 2;
    }
    return _faceContentView;
}

-(void)startCapture {
    [self.camera start];
}




// MARK: - Video Delegate

#if UseOpenCV == 1

-(void)processImage:(cv::Mat &)image {
    NSDictionary *featureParameters = @{
        CIDetectorSmile: @YES,
        CIDetectorEyeBlink: @YES,
        CIDetectorImageOrientation: @5
    };
    
    UIImage *uiImage = MatToUIImage(image);
    CIImage *ciImage = [uiImage CIImage];
    
    NSArray *resultArr = [self.detector featuresInImage:ciImage options:featureParameters];
   
    NSLog(@"%@", resultArr);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (resultArr.count == 0) {
//            self.faceContentView.hidden = YES;
            return;
        }
        CGSize imageSize = ciImage.extent.size;
        CGRect previewBox = [self previewBoxForFrameSize:self.frame.size apertureSize:imageSize];
        
        for (CIFaceFeature *feature in resultArr) {
            CGRect faceRect = [self faceRectForFeatureRect:feature.bounds PreviewBox:previewBox frameSize:self.frame imageSize:imageSize];
            
            cv::Point topLeft(faceRect.origin.x, faceRect.origin.y);

            cv::Point botRight = topLeft + cv::Point(faceRect.size.width, faceRect.size.height);

            cv::Scalar magenta = cv::Scalar(255, 0, 255);

            cv::rectangle(image, topLeft, botRight, magenta, 4, 8, 0);

            NSLog(@"%@", NSStringFromCGRect(faceRect));
        }
    });
}



/* The intended display orientation of the image. If present, the value
 * of this key is a CFNumberRef with the same value as defined by the
 * TIFF and Exif specifications.  That is:
 *   1  =  0th row is at the top, and 0th column is on the left.
 *   2  =  0th row is at the top, and 0th column is on the right.
 *   3  =  0th row is at the bottom, and 0th column is on the right.
 *   4  =  0th row is at the bottom, and 0th column is on the left.
 *   5  =  0th row is on the left, and 0th column is the top.
 *   6  =  0th row is on the right, and 0th column is the top.
 *   7  =  0th row is on the right, and 0th column is the bottom.
 *   8  =  0th row is on the left, and 0th column is the bottom.
 * If not present, a value of 1 is assumed. */

#else


-(void)processCIImage:(CIImage *)image {
    NSDictionary *featureParameters = @{
        CIDetectorSmile: @YES,
        CIDetectorEyeBlink: @YES,
        CIDetectorImageOrientation: @5
    };
    
    // get detected result.
    NSArray *resultArr = [self.detector featuresInImage:image options:featureParameters];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (resultArr.count == 0) {
            self.faceContentView.hidden = YES;
            return;
        }
        self.faceContentView.hidden = NO;
//        AVLayerVideoGravity gravity = self.camera.previewLayer.videoGravity;
        CGSize imageSize = image.extent.size;
        CGRect previewBox = [self previewBoxForFrameSize:self.frame.size apertureSize:imageSize];
        
        for (CIFaceFeature *feature in resultArr) {
            CGRect faceRect = [self faceRectForFeatureRect:feature.bounds PreviewBox:previewBox frameSize:self.frame imageSize:imageSize];
            
            self.faceContentView.frame = faceRect;
        }
    });
}

#endif

-(CGRect)previewBoxForFrameSize:(CGSize)frameSize apertureSize:(CGSize)apertureSize {
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = ScreenWidth / ScreenHeight;
    
    CGSize size = CGSizeZero;
    if (viewRatio > apertureRatio) {
        size.width = frameSize.width;
        size.height = apertureSize.width * (frameSize.width / apertureSize.height);
    } else {
        size.width = apertureSize.height * (frameSize.height / apertureSize.width);
        size.height = frameSize.height;
    }
    
    CGRect videoBox;
    videoBox.size = size;
    if (size.width < frameSize.width) {
        videoBox.origin.x = (frameSize.width - size.width) / 2;
        videoBox.origin.y = (frameSize.height - size.height) / 2;
    } else {
        videoBox.origin.x = (size.width - frameSize.width) / 2;
        videoBox.origin.y = (size.height - frameSize.height) / 2;
    }
    NSLog(@"%@", NSStringFromCGRect(videoBox));
    return videoBox;
}


-(CGRect)faceRectForFeatureRect:(CGRect)featureRect PreviewBox:(CGRect)previewBox frameSize:(CGRect)frameSize imageSize:(CGSize)imageSize {
    
    CGFloat widthScaleBy = previewBox.size.width / imageSize.height;
    CGFloat heightScaleBy = previewBox.size.height / imageSize.width;
    
    CGRect faceRect = featureRect;
    
    // flip preview width and height
    CGFloat temp = faceRect.size.width;
    faceRect.size.width = faceRect.size.height;
    faceRect.size.height = temp;
    temp = faceRect.origin.x;
    faceRect.origin.x = faceRect.origin.y;
    faceRect.origin.y = temp;
    
    // scale coordinates so they fit in the preview box, which may be scaled
    faceRect.size.width *= widthScaleBy;
    faceRect.size.height *= heightScaleBy;
    faceRect.origin.x *= widthScaleBy;
    faceRect.origin.y *= heightScaleBy;
    
    faceRect = CGRectOffset(faceRect, previewBox.origin.x + previewBox.size.width - faceRect.size.width - (faceRect.origin.x * 2), previewBox.origin.y);
    
    return faceRect;
}

@end
