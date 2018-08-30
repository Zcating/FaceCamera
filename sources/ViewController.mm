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

//#import "FaceDetector.h"
//#import "VideoCamera.h"

#import "FaceView.h"

@interface ViewController ()
//CvVideoCameraDelegate,
//VideoCameraDelegate
//>

@property (weak, nonatomic) IBOutlet FaceView *videoView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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


@end
