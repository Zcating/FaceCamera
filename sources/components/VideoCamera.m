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

#import "FaceDetector.h"

static const NSString *AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";


@interface VideoCamera()<
AVCaptureVideoDataOutputSampleBufferDelegate,
AVCaptureMetadataOutputObjectsDelegate
> {
    dispatch_queue_t _videoQueue;
    dispatch_queue_t _metadataQueue;
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

@property (nonatomic, strong) NSMutableArray *faceLayers;


@property (nonatomic, strong) AVSampleBufferDisplayLayer *displayLayer;


@property (nonatomic, strong) NSArray *metadataObjects;

@end

@implementation VideoCamera

- (instancetype)initWithParentView:(UIView *)view {
    self = [super init];
    if (self) {
        // Camera
        [self initCamera];
        
        // data output
        [self initVideoDataOutput];

        //
        [self initPhotoTaking];
        
        //
        [self initMetadataOutput];

        [view.layer addSublayer:self.displayLayer];
        self.displayLayer.frame = view.bounds;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stop) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)initCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    self.frontCameraInput = [AVCaptureDeviceInput deviceInputWithDevice:devices.lastObject error:nil];
    self.backCameraInput = [AVCaptureDeviceInput deviceInputWithDevice:devices.firstObject error:nil];
    if ([self.session canAddInput:self.backCameraInput]) {
        [self.session addInput:self.backCameraInput];
        self.currentInput = self.backCameraInput;
    }
}

-(void)initVideoDataOutput {
    if ([self.session canAddOutput:self.videoOutput]) {
        [self.session addOutput:self.videoOutput];
    }
}

-(void)initPhotoTaking {
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
}

-(void)initMetadataOutput {
    AVCaptureMetadataOutput *metadataOutput = [AVCaptureMetadataOutput new];
    _metadataQueue = dispatch_queue_create("face.camera.metadata.queue", NULL);
    [metadataOutput setMetadataObjectsDelegate:self queue:_metadataQueue];
    if ([self.session canAddOutput:metadataOutput]) {
        [self.session addOutput:metadataOutput];
        metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
    }
}


// MARK: - getter & setter

-(AVCaptureSession *)session {
    if (_session == nil) {
        _session = [AVCaptureSession new];
        if ([_session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            _session.sessionPreset = AVCaptureSessionPreset1280x720;
        }
    }
    return _session;
}

-(AVCaptureVideoDataOutput *)videoOutput {
    if (_videoOutput == nil) {
        _videoQueue = dispatch_queue_create("video.queue", NULL);
        
        _videoOutput = [AVCaptureVideoDataOutput new];
        _videoOutput.videoSettings = @{
            (NSString*)kCVPixelBufferPixelFormatTypeKey: @(kCMPixelFormat_32BGRA)
        };
        _videoOutput.alwaysDiscardsLateVideoFrames = YES;
        [_videoOutput setSampleBufferDelegate:self queue:_videoQueue];
    }
    return _videoOutput;
}


-(AVCaptureStillImageOutput *)stillImageOutput {
    if (_stillImageOutput == nil) {
        _stillImageOutput = [AVCaptureStillImageOutput new];
        [_stillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _stillImageOutput;
}

-(AVSampleBufferDisplayLayer *)displayLayer {
    if (_displayLayer == nil) {
        _displayLayer = [AVSampleBufferDisplayLayer layer];
        _displayLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _displayLayer;
}


- (void)setSessionPreset:(AVCaptureSessionPreset)sessionPreset{
    if ([self.session isRunning]) {
        [self.session beginConfiguration];
        self.session.sessionPreset = sessionPreset;
        [self.session commitConfiguration];
    } else {
        self.session.sessionPreset = sessionPreset;
    }
}


- (AVCaptureDevicePosition)devicePosition {
    return _devicePosition;
}

-(void)setDevicePosition:(AVCaptureDevicePosition)devicePosition {
    _devicePosition = devicePosition;
    if ([self.session isRunning]) {        
        [self.session beginConfiguration];
        [self switchCamera: devicePosition];
        [self.session commitConfiguration];
    } else {
        [self switchCamera:devicePosition];
    }
}


// MARK: - Public Function

- (void)start {
    [self.session startRunning];
}

- (void)stop {
    [self.session stopRunning];
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
//    [self videoMirrored:devicePosition];
}



- (void)takePicture {
    AVCaptureConnection *stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
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
            
//            UIImage *uiImage = [self renderForFeatures:features inCIImage:ciImage];
            
//            [self saveCGImage:cgImageResult];
        });
    }];
}

// MARK: - Private Function


// Generate CIImage
- (CIImage *)generateCIImageFrom:(CMSampleBufferRef)sampleBuffer {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    NSDictionary *attachments = CFBridgingRelease(CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate));
    CIImage *image = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:attachments];
    
    return image;
}

- (void)saveCGImage:(CGImageRef)cgImage {

//    ALAssetsLibrary *library = [ALAssetsLibrary new];
//    [library writeImageDataToSavedPhotosAlbum:(__bridge id)destinationData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
//        if (destinationData) {
//            CFRelease(destinationData);
//        }
//    }];
    
//    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//        [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:tmpURL];
//    }   completionHandler:^(BOOL success, NSError *error) {
//            //cleanup the tmp file after import, if needed
//    }];
    
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

- (UIImage *)renderForFeatures:(NSArray *)features withCIImage:(CIImage *)image {
    
    CIContext *context = [CIContext context];
    CGImageRef sourceImage = [context createCGImage:image fromRect:image.extent];
    
    CGRect imageRect            = image.extent;
    int bitmapBytesPerRow       =  (imageRect.size.width * 4);
    CGColorSpaceRef colorSpace  = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext  = CGBitmapContextCreate (NULL,
                                                         imageRect.size.width,
                                                         imageRect.size.height,
                                                         8,
                                                         bitmapBytesPerRow,
                                                         colorSpace,
                                                         kCGImageAlphaPremultipliedLast);
    
    CGContextSetAllowsAntialiasing(bitmapContext, NO);
    
    CGContextClearRect(bitmapContext, imageRect);
    
    CGContextDrawImage(bitmapContext, imageRect, sourceImage);
    
    // features found by the face detector
    for (CIFaceFeature *feature in features) {
        CGRect faceRect = [feature bounds];
        CGContextDrawImage(bitmapContext, faceRect, self.pasterImage.CGImage);
    }
    CGImageRef resultImage = CGBitmapContextCreateImage(bitmapContext);
    UIImage *uiImage = [UIImage imageWithCGImage:resultImage];
    CGContextRelease (bitmapContext);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(sourceImage);
        
    return uiImage;
}





// MARK: - Video Delegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if (self.metadataObjects.count != 0) {
        NSMutableArray *bounds = [NSMutableArray arrayWithCapacity:2];
        for ( AVMetadataObject *object in self.metadataObjects) {
            if([object isKindOfClass:[AVMetadataFaceObject class]]) {
                AVMetadataObject *face = [output transformedMetadataObjectForMetadataObject:object connection:connection];
                
                [bounds addObject:[NSValue valueWithCGRect:face.bounds]];
            }
        }
        [[FaceDetector shared] faceLandmarkDetectOn:sampleBuffer inRects: bounds];
    }
    [self.displayLayer enqueueSampleBuffer:sampleBuffer];
}

- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    if(self.devicePosition == AVCaptureDevicePositionFront) {
        if(connection.supportsVideoMirroring) {
            [connection setVideoMirrored:YES];
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    self.metadataObjects = metadataObjects;
}


@end
