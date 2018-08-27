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

@interface ViewController ()<
//CvVideoCameraDelegate,
VideoCameraDelegate
> {
    dispatch_queue_t _queue;
    NSUInteger _frameCount;
}

@property (nonatomic, strong) VideoCamera* videoCamera;

//@property (nonatomic, strong) CvVideoCamera* videoCamera;

@property (nonatomic, strong) CIDetector *detector;

@property (nonatomic, strong) UIView *faceView;

@property (nonatomic, strong) FaceDetector *faceDetector;

@property (nonatomic, strong) UILabel *label;

@property (weak, nonatomic) IBOutlet UIView *imageView;

@property (weak, nonatomic) IBOutlet UIImageView *faceImageView;

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
    
    [self.videoCamera start];
    
//    self.imageView.image = [UIImage imageNamed:@"myself.jpg"];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//-(CvVideoCamera *)videoCamera {
//    if (_videoCamera == nil) {
//        _videoCamera = [[CvVideoCamera alloc] initWithParentView:self.view];
//        _videoCamera.delegate = self;
//        _videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
//        _videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetHigh;
//        //竖屏
//        _videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
//        _videoCamera.defaultFPS = 30;
//        _videoCamera.grayscaleMode = NO;
//    }
//    return _videoCamera;
//}

-(VideoCamera *)videoCamera {
    if (_videoCamera == nil) {
        _videoCamera = [[VideoCamera alloc] initWithParentView:self.imageView];
        _videoCamera.delegate = self;
        _videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
        _videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetHigh;
    }
    return _videoCamera;
}

-(UIView *)faceView {
    if (_faceView == nil) {
        _faceView = [[UIView alloc] init];
        _faceView.backgroundColor = [UIColor clearColor];
        _faceView.layer.masksToBounds = YES;
        _faceView.layer.borderColor = [UIColor yellowColor].CGColor;
        _faceView.layer.borderWidth = 2;
        [self.imageView addSubview:_faceView];
    }
    return _faceView;
}

-(UILabel *)label {
    if (_label == nil) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 400, 200)];
        _label.font = [UIFont systemFontOfSize:15];
        [self.view addSubview: _label];
    }
    return _label;
}


-(void)processCIImage:(CIImage *)image {
    NSDictionary *featuresParam = @{CIDetectorSmile: @YES,
                                    CIDetectorEyeBlink: @YES};

    // 获取识别结果
    NSArray *resultArr = [self.detector featuresInImage:image options:featuresParam];

    if (resultArr.count == 0) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{

        for (CIFaceFeature *feature in resultArr) {
            // (Bottom right if mirroring is turned on)
            CGRect faceRect = [feature bounds];
            
            // flip preview width and height
            CGFloat temp = faceRect.size.width;
            faceRect.size.width = faceRect.size.height;
            faceRect.size.height = temp;
            temp = faceRect.origin.x;
            faceRect.origin.x = faceRect.origin.y;
            faceRect.origin.y = temp;
            // scale coordinates so they fit in the preview box, which may be scaled
            CGFloat widthScaleBy = self.view.frame.size.width / clap.size.height;
            CGFloat heightScaleBy = self.view.frame.size.height / clap.size.width;
            faceRect.size.width *= widthScaleBy;
            faceRect.size.height *= heightScaleBy;
            faceRect.origin.x *= widthScaleBy;
            faceRect.origin.y *= heightScaleBy;

            self.label.text = [NSString stringWithFormat:@"%.2f, %.2f, %.2f, %.2f", feature.bounds.origin.x, feature.bounds.origin.y, feature.bounds.size.width, feature.bounds.size.height];
        }
    });
}


@end
