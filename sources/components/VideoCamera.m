//
//  VideoCamera.m
//  FaceCamera
//
//  Created by  zcating on 2018/8/21.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "VideoCamera.h"


@interface VideoCamera()<AVCaptureVideoDataOutputSampleBufferDelegate> {
    dispatch_queue_t _videoQueue;
}

@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, strong) AVCaptureDevice *device;

@property (nonatomic, strong) AVCaptureDeviceInput *currentInput;

@property (nonatomic, strong) AVCaptureDeviceInput *frontCameraInput;

@property (nonatomic, strong) AVCaptureDeviceInput *backCameraInput;

@property (nonatomic, strong) AVCaptureConnection *videoConnection;

@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;


@end

@implementation VideoCamera

- (instancetype)initWithParentView:(UIView *)view {
    self = [super init];
    if (self) {
        _videoQueue = dispatch_queue_create("video.queue", 0);
        
        // Camera
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        self.frontCameraInput = [AVCaptureDeviceInput deviceInputWithDevice:devices.lastObject error:nil];
        self.backCameraInput = [AVCaptureDeviceInput deviceInputWithDevice:devices.firstObject error:nil];
        
        self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        self.videoOutput.videoSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
        self.videoOutput.alwaysDiscardsLateVideoFrames = YES;
        [self.videoOutput setSampleBufferDelegate:self queue:_videoQueue];
        
        self.session = [[AVCaptureSession alloc] init];
        //
        if ([self.session canAddOutput:self.videoOutput]) {
            [self.session addOutput:self.videoOutput];
        }
        //
        if ([self.session canAddInput:self.backCameraInput]) {
            [self.session addInput:self.backCameraInput];
            self.currentInput = self.backCameraInput;
        }
        //
        if ([self.session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            self.session.sessionPreset = AVCaptureSessionPreset1280x720;
        }
    
        [view.layer addSublayer:self.previewLayer];
        self.previewLayer.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
        
    }
    return self;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (_previewLayer == nil) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

- (void)setDefaultAVCaptureSessionPreset:(AVCaptureSessionPreset)sessionPreset {
    if ([self.session isRunning]) {
        [self.session beginConfiguration];
        self.session.sessionPreset = sessionPreset;
        [self.session commitConfiguration];
    } else {
        self.session.sessionPreset = sessionPreset;
    }
}

-(void)setDefaultAVCaptureDevicePosition:(AVCaptureDevicePosition)defaultAVCaptureDevicePosition {
    if ([self.session isRunning]) {        
        [self.session beginConfiguration];
        [self switchCamera: defaultAVCaptureDevicePosition];
        [self.session commitConfiguration];
    } else {
        [self switchCamera:defaultAVCaptureDevicePosition];
    }
}

- (void)switchCamera:(AVCaptureDevicePosition)devicePosition {
    if (devicePosition == AVCaptureDevicePositionFront) {
        [self.session removeInput:self.backCameraInput];
        [self.session addInput:self.frontCameraInput];
        self.currentInput = self.frontCameraInput;
    } else {
        [self.session removeInput:self.frontCameraInput];
        [self.session addInput:self.backCameraInput];
        self.currentInput = self.backCameraInput;
    }
}
                   
- (void)start {
    [self.session startRunning];
}

- (void)stop {
    [self.session stopRunning];
}


- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    //    CaptureDataBlock handler = self.handler;
    //    if (handler != nil) {
    //        CVBufferRef buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    //        handler(buffer);
    //    }
    if (self.delegate) {
        
        CVBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        [self.delegate processCIImage:[CIImage imageWithCVPixelBuffer:imageBuffer]];
    }
//    [self.receiver source:self videoCaptureData:imageBuffer];
}

- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
}


-(CGRect)videoPreviewBoxForFrameSize:(CGSize)frameSize {
     //originIsTopLeft == false
    
//    CGRect apertureSize = CMVideoFormatDescriptionGetCleanAperture(fdesc, false);
//    CGRect apertureSize = CGRectZero;
    return [self videoPreviewBoxForGravity:_previewLayer.videoGravity frameSize:frameSize apertureSize:CGRectZero.size];
}

-(CGRect)videoPreviewBoxForGravity:(NSString *)gravity frameSize:(CGSize)frameSize apertureSize:(CGSize)apertureSize {
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    
    CGSize size = CGSizeZero;
    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        if (viewRatio > apertureRatio) {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        } else {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        if (viewRatio > apertureRatio) {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        } else {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResize]) {
        size.width = frameSize.width;
        size.height = frameSize.height;
    }
    
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
