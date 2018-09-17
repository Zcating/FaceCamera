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
        _metadataQueue = dispatch_queue_create("face.camera.metadata.queue", NULL);
        // Camera
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        self.frontCameraInput = [AVCaptureDeviceInput deviceInputWithDevice:devices.lastObject error:nil];
        self.backCameraInput = [AVCaptureDeviceInput deviceInputWithDevice:devices.firstObject error:nil];
        
        
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
        
        AVCaptureMetadataOutput *metadataOutput = [AVCaptureMetadataOutput new];
        
        [metadataOutput setMetadataObjectsDelegate:self queue:_metadataQueue];
        if ([self.session canAddOutput:metadataOutput]) {
            [self.session addOutput:metadataOutput];
            metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
        }
        
        
        
//        [view.layer addSublayer:self.previewLayer];
//        self.previewLayer.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
        
        [view.layer addSublayer:self.displayLayer];
        self.displayLayer.frame = view.bounds;
//        self.displayLayer.position = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
//        self.displayLayer.transform =
        
    }
    return self;
}

// MARK: - getter & setter

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

-(NSMutableArray *)faceLayers {
    if (_faceLayers == nil) {
        _faceLayers = [NSMutableArray arrayWithCapacity:8];
    }
    return _faceLayers;
}

-(AVSampleBufferDisplayLayer *)displayLayer {
    if (_displayLayer == nil) {
        _displayLayer = [AVSampleBufferDisplayLayer layer];
        _displayLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _displayLayer;
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


- (AVCaptureDevicePosition)defaultAVCaptureDevicePosition {
    return _devicePosition;
}

-(void)setDefaultAVCaptureDevicePosition:(AVCaptureDevicePosition)defaultAVCaptureDevicePosition {
    _devicePosition = defaultAVCaptureDevicePosition;
    if ([self.session isRunning]) {        
        [self.session beginConfiguration];
        [self switchCamera: defaultAVCaptureDevicePosition];
        [self.session commitConfiguration];
    } else {
        [self switchCamera:defaultAVCaptureDevicePosition];
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

-(void)videoMirrored:(AVCaptureDevicePosition)devicePosition {
    AVCaptureSession* session = (AVCaptureSession *)self.session;
    for (AVCaptureVideoDataOutput* output in session.outputs) {
        for (AVCaptureConnection * av in output.connections) {
            if (devicePosition == AVCaptureDevicePositionFront) {
                if (av.supportsVideoMirroring) {
                    av.videoMirrored = YES;
                }
            }
        }
    }
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

// Generate CIImage
- (CIImage *)generateCIImageFrom:(CMSampleBufferRef)sampleBuffer {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    NSDictionary *attachments = CFBridgingRelease(CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate));
    CIImage *image = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:attachments];

    return image;
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
        NSLog(@"%@", bounds);
        
        [[FaceDetector shared] faceLandmarkDetectOn:sampleBuffer inRects: bounds];
    }
    [self.displayLayer enqueueSampleBuffer:sampleBuffer];
    
//    CIImage *image = [self generateCIImageFrom:sampleBuffer];

    if ([self.delegate respondsToSelector:@selector(processForFaces:)]) {
//        [self.delegate processForFaces: [self faceRectsFrom:image]];
    }
    
    if ([self.delegate respondsToSelector:@selector(processCIImage:)]) {
//        [self.delegate processCIImage:image];
    }
}

- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    if(self.defaultAVCaptureDevicePosition == AVCaptureDevicePositionFront) {
        if(connection.supportsVideoMirroring) {
            [connection setVideoMirrored:YES];
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    self.metadataObjects = metadataObjects;
}


//-(void) test:(CMSampleBufferRef)sampleBuffer {
//    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//    size_t width = CVPixelBufferGetWidth(pixelBuffer);
//    size_t height = CVPixelBufferGetHeight(pixelBuffer);
//    size_t row = CVPixelBufferGetBytesPerRow(pixelBuffer);
//    size_t bytesPerPixel = row/width;
//
//    unsigned char *buffer = CVPixelBufferGetBaseAddress(pixelBuffer);
//
//    UIGraphicsBeginImageContext(CGSizeMake(width, height));
//
//    CGContextRef c = UIGraphicsGetCurrentContext();
//
//    unsigned char* data = CGBitmapContextGetData(c);
//    if (data != NULL) {
//        size_t maxY = height;
//        for(int y = 0; y < maxY; y++) {
//            for(int x = 0; x < height; x++) {
//                size_t offset = bytesPerPixel * ((width * y) + x);
//                data[offset] = buffer[offset];     // R
//                data[offset + 1] = buffer[offset + 1]; // G
//                data[offset + 2] = buffer[offset + 2]; // B
//                data[offset + 3] = buffer[offset + 3]; // A
//            }
//        }
//    }
//    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
//
//    UIGraphicsEndImageContext();
//}

@end
