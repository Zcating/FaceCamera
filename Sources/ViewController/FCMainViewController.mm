//
//  ViewController.m
//  FaceCamera
//
//  Created by  zcating on 2018/8/19.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FCMainViewController.h"

#import "FaceCameraView.h"

#import "ShutterView.h"

#import "ScissorViewController.h"


#import <Masonry/Masonry.h>



@interface FCMainViewController () <
FaceCameraDelegate
>


@property (weak, nonatomic) IBOutlet FaceCameraView *cameraView;


@property (weak, nonatomic) IBOutlet ShutterView *shutterView;


@property (weak, nonatomic) IBOutlet UIView *topContainerView;


@end

@implementation FCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.scissorSwitch.hidden = YES;
    
    self.cameraView.delegate = self;
    [self.cameraView start];
    
    [self.shutterView pressShutter:^{
        
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.cameraView selector:@selector(stop) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.cameraView selector:@selector(start) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(BOOL)prefersStatusBarHidden {
    return YES;
}


- (IBAction)openSwitch:(UIButton *)sender {
    
    if (self.topContainerView.hidden) {
        CGRect originRect = self.topContainerView.frame;
        CGRect beforeRect = self.topContainerView.frame;
        beforeRect.origin.x = sender.center.x;
        beforeRect.size.width = 0;
        beforeRect.size.height = 0;
        self.topContainerView.frame = beforeRect;

        [UIView animateWithDuration:0.2 animations:^{
            self.topContainerView.hidden = NO;
            self.topContainerView.frame = originRect;
        }];
    } else {
        CGRect originRect = self.topContainerView.frame;
        CGRect afterRect = self.topContainerView.frame;
        afterRect.origin.x = sender.center.x;
        afterRect.size.width = 0;
        afterRect.size.height = 0;
        [UIView animateWithDuration:0.2 animations:^{
            self.topContainerView.frame = afterRect;
        } completion:^(BOOL finished) {
            if (finished) {
                self.topContainerView.hidden = YES;
                self.topContainerView.frame = originRect;
            }
        }];
    }
}


- (IBAction)openSetting:(id)sender {
    
}



- (void)processframe:(nonnull CMSampleBufferRef)sampleBuffer faces:(nullable NSArray *)faces {
    if (faces == nil) {
        return;
    }
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);

    CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);

    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    char *baseBuffer = (char *)CVPixelBufferGetBaseAddress(imageBuffer);

    cv::Mat pixelBuffer((int)height, (int)width, CV_8UC4, baseBuffer, bytesPerRow);


    CVPixelBufferUnlockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);

    std::vector<cv::Rect> faceRects;
    for (NSValue *value in faces) {
        CGRect rectValue = value.CGRectValue;
        CGFloat midX = rectValue.origin.x + rectValue.size.width / 2;
        CGFloat midY = rectValue.origin.y + rectValue.size.height / 2;
        CGFloat radius = rectValue.size.width > rectValue.size.height ? rectValue.size.width / 2 : rectValue.size.height / 2;
        radius *= 1.5;
            //
        CGFloat top = midX - radius;
        CGFloat left = midY - radius;
        CGFloat sideLength = radius * 2;
            //
        cv::Rect faceRect1(top, left, sideLength, sideLength);
        cv::Rect faceRect(rectValue.origin.x, rectValue.origin.y, rectValue.size.width, rectValue.size.height);

        cv::rectangle(pixelBuffer, faceRect.tl(), faceRect.br(), cv::Scalar(0, 0, 255, 255), 2);

        faceRects.push_back(faceRect1);
    }
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);

        //    pixelBuffer = dlib::toMat(dPixelBuffer);

    width = CVPixelBufferGetWidth(imageBuffer);
    height = CVPixelBufferGetHeight(imageBuffer);
    baseBuffer = (char *)CVPixelBufferGetBaseAddress(imageBuffer);

    int channels = pixelBuffer.channels();
    uint8_t* pixelPtr = (uint8_t *)pixelBuffer.data;

    // traslate to sample buffer.
    long position = 0;
    for(int i = 0; i < pixelBuffer.rows; i++) {
        for(int j = 0; j < pixelBuffer.cols; j++) {
            long bufferLocation = position * 4;
            // red
            baseBuffer[bufferLocation]  = pixelPtr[i * pixelBuffer.cols * channels + j * channels + 0];
            // green
            baseBuffer[bufferLocation + 1] = pixelPtr[i * pixelBuffer.cols * channels + j * channels + 1];
            // blue
            baseBuffer[bufferLocation + 2] = pixelPtr[i * pixelBuffer.cols * channels + j * channels + 2];
            // alpha
            baseBuffer[bufferLocation + 3] = pixelPtr[i * pixelBuffer.cols * channels + j * channels + 3];
            
            position++;
        }
    }

    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}


@end
