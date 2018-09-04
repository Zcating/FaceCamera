//
//  ViewController.m
//  FaceCamera
//
//  Created by  zcating on 2018/8/19.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FCMainViewController.h"

#import <opencv2/videoio/cap_ios.h>
#import <AVFoundation/AVFoundation.h>

//#import "FaceDetector.h"
//#import "VideoCamera.h"

#import "FaceView.h"
#import "ShutterView.h"

@interface FCMainViewController ()
//CvVideoCameraDelegate,
//VideoCameraDelegate
//>

@property (weak, nonatomic) IBOutlet FaceView *videoView;


@property (weak, nonatomic) IBOutlet ShutterView *shutterView;


@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation FCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    [self.shutterView pressShutter:^{
        UIImage *image = [self takeOnePhoto];
        self.imageView.image = image;
    
        self.imageView.frame = CGRectMake(0, 0, image.size.width * 0.2, image.size.height * 0.2);
        
//        NSData *pngData = UIImagePNGRepresentation(image);
//
//        NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, NO)[0];
//
//        NSString *fileString = [documents stringByAppendingPathComponent:@"motherfucker.png"];
//
//        [pngData writeToFile:fileString atomically:NO];
    }];
    
    [self.videoView startCapture];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        [self.view addSubview:_imageView];
    }
    return _imageView;
}

- (UIImage *)takeOnePhoto {
    UIGraphicsBeginImageContextWithOptions(self.videoView.bounds.size, NO, [UIScreen mainScreen].scale);
    [self.videoView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


@end
