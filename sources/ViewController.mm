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

@property (weak, nonatomic) IBOutlet UIView *videoView;

@property (weak, nonatomic) IBOutlet UIImageView *faceImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _queue = dispatch_queue_create("video.queue", 0);
    
    // 配置识别质量
    NSDictionary *param = @{
      CIDetectorAccuracy: CIDetectorAccuracyHigh
    };
    
    // 创建人脸识别器
    self.detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:param];
    
    [self.videoCamera start];
    
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
        _videoCamera = [[VideoCamera alloc] initWithParentView:self.videoView];
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
        [self.videoView addSubview:_faceView];
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
    NSDictionary *featuresParam = @{
        CIDetectorSmile: @YES,
        CIDetectorEyeBlink: @YES,
        CIDetectorImageOrientation: @6
    };
    // 获取识别结果
    NSArray *resultArr = [self.detector featuresInImage:image options:featuresParam];

    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (resultArr.count == 0) {
            self.faceView.hidden = YES;
            return;
        }
        self.faceView.hidden = NO;
        CGSize imageSize = image.extent.size;
        CGRect previewBox = [self videoPreviewBoxForFrameSize:self.videoView.frame.size apertureSize:imageSize];
        
        CGFloat widthScaleBy = previewBox.size.width / imageSize.height;
        CGFloat heightScaleBy = previewBox.size.height / imageSize.width;
        
        for (CIFaceFeature *feature in resultArr) {
            // (Bottom right if mirroring is turned on)
            CGRect faceRect = feature.bounds;
            
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
//            faceRect = CGRectOffset(faceRect, previewBox.origin.x, previewBox.origin.y);
            
            
            NSLog(@"%.2f, %.2f, %.2f, %.2f", faceRect.origin.x, faceRect.origin.y, faceRect.size.width, faceRect.size.height);
            
            self.label.text = [NSString stringWithFormat:@"%.2f, %.2f, %.2f, %.2f", faceRect.origin.x, faceRect.origin.y, faceRect.size.width, faceRect.size.height];
            
            self.faceView.frame = faceRect;
        }
    });
}


-(CGRect)videoPreviewBoxForFrameSize:(CGSize)frameSize apertureSize:(CGSize)apertureSize {
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    
    CGSize size = CGSizeZero;
//    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        if (viewRatio > apertureRatio) {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        } else {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        }
//    } else if ([gravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
//        if (viewRatio > apertureRatio) {
//            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
//            size.height = frameSize.height;
//        } else {
//            size.width = frameSize.width;
//            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
//        }
//    } else if ([gravity isEqualToString:AVLayerVideoGravityResize]) {
//        size.width = frameSize.width;
//        size.height = frameSize.height;
//    }
    
    CGRect videoBox;
    videoBox.size = size;
    if (size.width < frameSize.width)
        videoBox.origin.x = (frameSize.width - size.width) / 2;
    else
        videoBox.origin.x = (size.width - frameSize.width) / 2;
    
    if ( size.height < frameSize.height )
        videoBox.origin.y = (frameSize.height - size.height) / 2;
    else
        videoBox.origin.y = (size.height - frameSize.height) / 2;
    
    return videoBox;
}

@end
