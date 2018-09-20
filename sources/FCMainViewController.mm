//
//  ViewController.m
//  FaceCamera
//
//  Created by  zcating on 2018/8/19.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FCMainViewController.h"

#import <AVFoundation/AVFoundation.h>

//#import "FaceDetector.h"
#import "VideoCamera.h"

//#import "FaceView.h"
#import "ShutterView.h"

@interface FCMainViewController () <
//CvVideoCameraDelegate,
VideoCameraDelegate
>

@property (weak, nonatomic) IBOutlet UIView *videoView;


@property (weak, nonatomic) IBOutlet ShutterView *shutterView;


@property (strong, nonatomic) UIImageView *imageView;


@property (strong, nonatomic) VideoCamera *camera;

@end

@implementation FCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    [self.shutterView pressShutter:^{
//        UIImage *image = [self takeOnePhoto];
//        self.imageView.image = image;
//
//        self.imageView.frame = CGRectMake(0, 0, image.size.width * 0.2, image.size.height * 0.2);
//
//        NSData *pngData = UIImagePNGRepresentation(image);
//
//        NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, NO)[0];
//
//        NSString *fileString = [documents stringByAppendingPathComponent:@"motherfucker.png"];
//
//        [pngData writeToFile:fileString atomically:NO];
    }];
    
    [self.camera start];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(VideoCamera *)camera {
    if (_camera == nil) {
        _camera = [[VideoCamera alloc] initWithParentView:self.videoView];
        _camera.delegate = self;
        _camera.devicePosition = AVCaptureDevicePositionFront;
        _camera.sessionPreset = AVCaptureSessionPresetHigh;
    }
    return _camera;
}

-(UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        [self.view addSubview:_imageView];
    }
    return _imageView;
}




@end
