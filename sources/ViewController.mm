//
//  ViewController.m
//  FaceCamera
//
//  Created by  zcating on 2018/8/19.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "ViewController.h"

#import <opencv2/videoio/cap_ios.h>
#import <AVFoundation/AVFoundation.h>

#import "FaceDetector.h"
#import "VideoCamera.h"

@interface ViewController ()<CvVideoCameraDelegate, VideoCameraDelegate> {
    dispatch_queue_t _queue;
    NSUInteger _frameCount;
}

@property (nonatomic, strong) VideoCamera* bkVideoCamera;

@property (nonatomic, strong) CvVideoCamera* videoCamera;

@property (nonatomic, strong) CIDetector *detector;

@property (nonatomic, strong) UIView *faceView;

@property (nonatomic, strong) BKFaceDetector *faceDetector;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _queue = dispatch_queue_create("video.queue", 0);
    
    CIContext *content = [CIContext contextWithOptions:nil];
    
    // 配置识别质量
    NSDictionary *param = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    
    // 创建人脸识别器
    self.detector = [CIDetector detectorOfType:CIDetectorTypeFace context:content options:param];
    
//    self.faceDetector = [[BKFaceDetector alloc] init];
//    [self.videoCamera start];
    
    [self.bkVideoCamera start];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(CvVideoCamera *)videoCamera {
    if (_videoCamera == nil) {
        _videoCamera = [[CvVideoCamera alloc] initWithParentView:self.view];
        _videoCamera.delegate = self;
        _videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
        _videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetHigh;
        //竖屏
        _videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
        _videoCamera.defaultFPS = 30;
        _videoCamera.grayscaleMode = NO;
    }
    return _videoCamera;
}

-(VideoCamera *)bkVideoCamera {
    if (_bkVideoCamera == nil) {
        _bkVideoCamera = [[VideoCamera alloc] initWithParentView:self.view];
        _bkVideoCamera.delegate = self;
        _bkVideoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
        _bkVideoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetHigh;
    }
    return _bkVideoCamera;
}

-(UIView *)faceView {
    if (_faceView == nil) {
        _faceView = [[UIView alloc] init];
        _faceView.backgroundColor = [UIColor clearColor];
        _faceView.layer.masksToBounds = YES;
        _faceView.layer.borderColor = [UIColor yellowColor].CGColor;
        _faceView.layer.borderWidth = 2;
        [self.view addSubview:_faceView];
    }
    return _faceView;
}

//-(void)processImage:(cv::Mat &)image {
//    if (_frameCount == 60) {
//        dispatch_async(_queue, ^{
//            [self parseFaces:[self.faceDetector rectDetectForImage:image]];
//        });
//        _frameCount = 1;
//    } else {
//        _frameCount ++;
//    }
//}
//
//- (void)parseFaces:(const std::vector<cv::Rect> &)faces {
//    if (faces.size() != 1) {
//        [self noFaceToDisplay];
//        return;
//    }
//
//    // We only care about the first face
//    cv::Rect face = faces[0];
//
//    // Learn it
//
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        [self highlightFace:face];
//    });
//}
//
//
//- (void)noFaceToDisplay {
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        self.faceView.hidden = YES;
//    });
//}
//
//- (void)highlightFace:(cv::Rect)face {
//    CGRect faceRect;
//    faceRect.origin.x = face.x;
//    faceRect.origin.y = face.y;
//    faceRect.size.width = face.width;
//    faceRect.size.height = face.height;
//
//    self.faceView.hidden = NO;
//    self.faceView.frame = faceRect;
//}

-(void)processCIImage:(CIImage *)image {
    NSDictionary *featuresParam = @{CIDetectorSmile: @YES,
                                    CIDetectorEyeBlink: @YES};

    // 获取识别结果
    NSArray *resultArr = [self.detector featuresInImage:image options:featuresParam];
//    NSLog(@"%f, %f, %f, %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);

    if (resultArr.count == 0) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        CGSize viewSize = self.view.frame.size;
        CGSize imageSize = image.extent.size;
        CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, -1);
        transform = CGAffineTransformTranslate(transform, 0, -imageSize.height);


        CGFloat scaleX = viewSize.width / imageSize.width;
        CGFloat scaleY = viewSize.height / imageSize.height;
        CGFloat scale = MIN(scaleX, scaleY);


        CGFloat dx = (viewSize.width - imageSize.width * scaleX) / 2;
        CGFloat dy = (viewSize.height - imageSize.height * scaleY) / 2;

//        faceBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
//        faceBounds.origin.x += dx
//        faceBounds.origin.y += dy

        for (CIFaceFeature *feature in resultArr) {
            CGRect faceRect = CGRectApplyAffineTransform(CGRectApplyAffineTransform(feature.bounds, transform), CGAffineTransformMakeScale(scale, scale));
            faceRect.origin.x += dx;
            faceRect.origin.y += dy;

            self.faceView.frame = faceRect;

            NSLog(@"%f, %f, %f, %f", faceRect.origin.x, faceRect.origin.y, faceRect.size.width, faceRect.size.height);
        }
    });


//    if (resultArr.count == 0) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.faceView.hidden = YES;
//        });
//    }
}


@end
