//
//  FaceView.m
//  BikaCamera
//
//  Created by  zcating on 2018/8/26.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FaceView.h"
#import "FaceDetector.h"

@implementation FaceView


- (void)drawRect:(CGRect)rect {
    [self addSubview:self.faceContentView];
//    [self addSubview:self.imageView];
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

#if UseOpenCV == 1

-(CvVideoCamera *)camera {
    if (_camera == nil) {
        _camera = [[CvVideoCamera alloc] initWithParentView:self];
        _camera.delegate = self;
        _camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
        _camera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetHigh;
        _camera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
        _camera.defaultFPS = 60;
        _camera.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        
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


-(void)startCapture {
    [self.camera start];
}




// MARK: - Video Delegate

#if UseOpenCV == 1

-(void)processImage:(cv::Mat &)image {
//    UIImage *uiImage = MatToUIImage(image);
//
//    CIImage *ciImage = [uiImage CIImage];
//    NSDictionary *featureParameters = @{
//        CIDetectorSmile: @YES,
//        CIDetectorEyeBlink: @YES,
//        CIDetectorImageOrientation: @5
//    };
//
//    // get detected result.
//    NSArray *resultArr = [self.detector featuresInImage:ciImage options:featureParameters];
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.imageView.image = uiImage;
//
//        if (resultArr.count == 0) {
//            NSLog(@"%@", resultArr);
//            self.faceContentView.hidden = YES;
//            return;
//        }
//        self.faceContentView.hidden = NO;
//        CGSize imageSize = ciImage.extent.size;
//        CGRect previewBox = [self previewBoxForFrameSize:self.frame.size apertureSize:imageSize];
//
//        for (CIFaceFeature *feature in resultArr) {
//            CGRect faceRect = [self faceRectForFeatureRect:feature.bounds PreviewBox:previewBox frameSize:self.frame imageSize:imageSize];
//
//            self.faceContentView.frame = faceRect;
//        }
//    });
    std::vector<cv::Rect> rects = [[FaceDetector shared] rectDetectForImage:image];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (rects.size() == 0) {
            self.faceContentView.hidden = YES;
        }

        for (cv::Rect rect : rects) {

            CGRect r = CGRectMake(rect.x, rect.y, rect.width, rect.height);
            NSLog(@"%@", NSStringFromCGRect(r));

//            self.faceContentView.hidden = NO;
//            self.faceContentView.frame = r;

            cv::Scalar magenta = cv::Scalar(255, 0, 0, 255);
            cv::rectangle(image, rect.tl(), rect.br(), magenta, 11, 8, 0);
        }
    });
}




#else

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
        CGSize imageSize = image.extent.size;
        CGRect previewBox = [self previewBoxForFrameSize:self.frame.size apertureSize:imageSize];

        for (CIFaceFeature *feature in resultArr) {
            CGRect faceRect = [self faceRectForFeatureRect:feature.bounds PreviewBox:previewBox frameSize:self.frame imageSize:imageSize];

            self.faceContentView.frame = faceRect;
        }
    });
}

#endif

@end
