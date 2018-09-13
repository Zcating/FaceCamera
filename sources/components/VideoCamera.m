//
//  VideoCamera.m
//  FaceCamera
//
//  Created by  zcating on 2018/8/21.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "VideoCamera.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

static const NSString *AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";

static CGContextRef CreateCGBitmapContextForSize(CGSize size) {
    
    CGContextRef    context             = NULL;
    CGColorSpaceRef colorSpace          = CGColorSpaceCreateDeviceRGB();
    int             bitmapBytesPerRow   =  (size.width * 4);
    
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    context = CGBitmapContextCreate (NULL,
                                     size.width,
                                     size.height,
                                     8,
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedLast);
    CGContextSetAllowsAntialiasing(context, NO);
    CGColorSpaceRelease(colorSpace);
    
    return context;
}


@interface VideoCamera()<AVCaptureVideoDataOutputSampleBufferDelegate> {
    dispatch_queue_t _videoQueue;
    AVCaptureDevicePosition _devicePosition;
}

@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, strong) AVCaptureDevice *device;

@property (nonatomic, strong) AVCaptureDeviceInput *currentInput;

@property (nonatomic, strong) AVCaptureDeviceInput *frontCameraInput;

@property (nonatomic, strong) AVCaptureDeviceInput *backCameraInput;

@property (nonatomic, strong) AVCaptureConnection *videoConnection;

@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;

@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, strong) CIDetector *detector;

@end

@implementation VideoCamera

- (instancetype)initWithParentView:(UIView *)view {
    self = [super init];
    if (self) {
        _videoQueue = dispatch_queue_create("video.queue", DISPATCH_QUEUE_SERIAL);
        
        // Camera
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        self.frontCameraInput = [AVCaptureDeviceInput deviceInputWithDevice:devices.lastObject error:nil];
        self.backCameraInput = [AVCaptureDeviceInput deviceInputWithDevice:devices.firstObject error:nil];
        
        self.videoOutput = [AVCaptureVideoDataOutput new];
        self.videoOutput.videoSettings = @{
            (NSString*)kCVPixelBufferPixelFormatTypeKey: @(kCMPixelFormat_32BGRA)
        };
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
        if ([self.session canAddOutput:self.stillImageOutput]) {
            [self.session addOutput:self.stillImageOutput];
        }
        
        [view.layer addSublayer:self.previewLayer];
        self.previewLayer.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
        
    }
    return self;
}

// MARK: - getter & setter

- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (_previewLayer == nil) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

-(AVCaptureStillImageOutput *)stillImageOutput {
    if (_stillImageOutput == nil) {
        _stillImageOutput = [AVCaptureStillImageOutput new];
        [_stillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _stillImageOutput;
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

// MARK: - Public Function

- (void)switchCamera:(AVCaptureDevicePosition)devicePosition {
    _devicePosition = devicePosition;
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

- (void)takePicture {
    AVCaptureConnection *stillImageConnection = [_stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
//
//    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
//    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
//    [stillImageConnection setVideoOrientation:avcaptureOrientation];
//    [stillImageConnection setVideoScaleAndCropFactor:effectiveScale];
    
    NSDictionary *settings = @{
        (id)kCVPixelBufferPixelFormatTypeKey: @(kCMPixelFormat_32BGRA)
    };
    
    [self.stillImageOutput setOutputSettings:settings];
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"error: %@", error);
            return;
        }
        CIImage *ciImage = [self generateCIImageFrom:imageDataSampleBuffer];
        
        NSDictionary *imageOptions = nil;
        
        NSNumber *orientation = CMGetAttachment(imageDataSampleBuffer, kCGImagePropertyOrientation, NULL);
        
        if (orientation) {
            imageOptions = @{
                CIDetectorImageOrientation:orientation
            };
        }
        
        
        dispatch_sync(self->_videoQueue, ^(void) {
            
            NSArray *features = [self.detector featuresInImage:ciImage options:imageOptions];
            CIContext *context = [CIContext context];
            CGImageRef srcImage = [context createCGImage:ciImage fromRect:ciImage.extent];
            
            CGImageRef cgImageResult = [self newSquareOverlayedImageForFeatures:features inCGImage:srcImage];
            
            [self saveCGImage:cgImageResult];
            
            if (srcImage) {
                CFRelease(srcImage);
            }
            if (cgImageResult) {
                CFRelease(cgImageResult);
            }
        });
    }];
}

// MARK: - Private Function


- (void)saveCGImage:(CGImageRef)cgImage {

//    ALAssetsLibrary *library = [ALAssetsLibrary new];
//    [library writeImageDataToSavedPhotosAlbum:(__bridge id)destinationData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
//        if (destinationData) {
//            CFRelease(destinationData);
//        }
//    }];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:tmpURL];
    }   completionHandler:^(BOOL success, NSError *error) {
            //cleanup the tmp file after import, if needed
    }];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        UIImage *uiImage = [UIImage imageWithCGImage:cgImage];
        PHAssetChangeRequest* createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:uiImage];
        
        PHObjectPlaceholder *placeholder = [createAssetRequest placeholderForCreatedAsset];
        
        NSLog(@"photo identifier: %@", placeholder.localIdentifier);
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"success");
        } else {
            NSLog(@"%@", error);
        }
    }];
    
}

- (CGImageRef)newSquareOverlayedImageForFeatures:(NSArray *)features inCGImage:(CGImageRef)backgroundImage
{
    CGImageRef      returnImage         = NULL;
    CGRect          backgroundImageRect = CGRectMake(0., 0., CGImageGetWidth(backgroundImage), CGImageGetHeight(backgroundImage));
    CGColorSpaceRef colorSpace          = CGColorSpaceCreateDeviceRGB();
    int             bitmapBytesPerRow   =  (backgroundImageRect.size.width * 4);
    CGContextRef    bitmapContext       = CGBitmapContextCreate (NULL,
                                           backgroundImageRect.size.width,
                                           backgroundImageRect.size.height,
                                           8,
                                           bitmapBytesPerRow,
                                           colorSpace,
                                           kCGImageAlphaPremultipliedLast);
    
    CGContextSetAllowsAntialiasing(bitmapContext, NO);
    
    CGContextClearRect(bitmapContext, backgroundImageRect);
    
    CGContextDrawImage(bitmapContext, backgroundImageRect, backgroundImage);

    
    // features found by the face detector
    for (CIFaceFeature *feature in features) {
        CGRect faceRect = [feature bounds];
        CGContextDrawImage(bitmapContext, faceRect, self.pasterImage.CGImage);
    }
    returnImage = CGBitmapContextCreateImage(bitmapContext);

    CGContextRelease (bitmapContext);
    CGColorSpaceRelease(colorSpace);
    
    return returnImage;
}


- (CIImage *)generateCIImageFrom:(CMSampleBufferRef)sampleBuffer {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *image = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
    if (attachments) {
        CFRelease(attachments);
    }
    return image;
}

// 人脸检测
-(NSArray *)faceRectsFrom:(CIImage *)image {
    NSDictionary *featureParameters = @{
                                        CIDetectorSmile: @YES,
                                        CIDetectorEyeBlink: @YES,
                                        CIDetectorImageOrientation: @5
                                        };
    NSArray *resultArr = [self.detector featuresInImage:image options:featureParameters];
    if (resultArr.count == 0) {
        return resultArr;
    }
    CGSize imageSize = image.extent.size;
    CGSize viewSize = self.previewLayer.frame.size;
    CGRect previewBox = [self previewBoxForFrameSize:viewSize apertureSize:imageSize];
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
    for (CIFaceFeature *feature in resultArr) {
        CGRect faceRect = [self faceRectForFeatureRect:feature.bounds PreviewBox:previewBox imageSize:imageSize];
        [array addObject:[NSValue valueWithCGRect:faceRect]];
    }
    return array;
}

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


-(CGRect)faceRectForFeatureRect:(CGRect)featureRect PreviewBox:(CGRect)previewBox imageSize:(CGSize)imageSize {
    
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


// MARK: - Video Delegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    //    CaptureDataBlock handler = self.handler;
    //    if (handler != nil) {
    //        CVBufferRef buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    //        handler(buffer);
    //    }
    CIImage *image = [self generateCIImageFrom:sampleBuffer];
    
    
    if ([self.delegate respondsToSelector:@selector(processForFaces:)]) {
        [self.delegate processForFaces: [self faceRectsFrom:image]];
    }
    
    if ([self.delegate respondsToSelector:@selector(processCIImage:)]) {
        [self.delegate processCIImage:image];
    }
    
}

@end
