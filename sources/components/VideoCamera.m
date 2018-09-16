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

@property (nonatomic, strong) NSMutableArray *faceLayers;

@property (nonatomic, strong) UIImageView *imageView;

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

-(NSMutableArray *)faceLayers {
    if (_faceLayers == nil) {
        _faceLayers = [NSMutableArray arrayWithCapacity:8];
    }
    return _faceLayers;
}

//-(CALayer *)videoViewLayer {
//    if (_videoViewLayer == nil) {
//        _videoViewLayer = [CALayer layer];
//    }
//    return _videoViewLayer;
//}

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

- (void)start {
    [self.session startRunning];
}

- (void)stop {
    [self.session stopRunning];
}

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

// The coordination of CIDetector result is
// the 0 row is on the bottom, the 0 column is on the left,
// so we need to change to UIKit coordination system.

-(NSArray *)faceRectsFrom:(CIImage *)image {
    
    [CATransaction begin];
    [CATransaction setValue:@(NO) forKey:kCATransactionDisableActions];
    
    for (CALayer *layer in self.faceLayers) {
       layer.hidden = YES;
    }
    

    NSDictionary *featureParameters = @{
        CIDetectorSmile: @YES,
        CIDetectorEyeBlink: @YES,
        CIDetectorImageOrientation: @5
    };
    
    NSArray *resultArr = [self.detector featuresInImage:image options:featureParameters];
    
    if (resultArr.count == 0) {
        [CATransaction commit];
        return resultArr;
    }
    
//    self.videoViewLayer.contents = CFBridgingRelease(uiImage.CGImage);
    
    if (self.faceLayers.count < resultArr.count) {
        for (NSUInteger index = self.faceLayers.count; index < resultArr.count; index++) {
            CALayer *layer = [CALayer layer];
            layer.name = @"FACE";
            layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"whiskers"].CGImage);
            [self.previewLayer addSublayer: layer];

            [self.faceLayers addObject:layer];
        }
    }

    CGSize imageSize = image.extent.size;
    CGSize viewSize = self.previewLayer.frame.size;
    CGRect previewBox = [self previewBoxForFrameSize:viewSize apertureSize:imageSize];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
    for (NSUInteger index = 0; index < resultArr.count; index++) {
        CIFaceFeature *feature = resultArr[index];


        CGRect faceRect = [self faceRectForFeatureRect:feature.bounds PreviewBox:previewBox imageSize:imageSize];
        [array addObject:[NSValue valueWithCGRect:faceRect]];

        NSLog(@"%@", NSStringFromCGRect(faceRect));
        CALayer *layer = self.faceLayers[index];
        layer.hidden = NO;
        faceRect.origin.y += 50;
        layer.frame = faceRect;
    }
    [CATransaction commit];
    
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
//        [self.delegate processCIImage:image];
    }
}

-(void) test:(CMSampleBufferRef)sampleBuffer {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    size_t row = CVPixelBufferGetBytesPerRow(pixelBuffer);
    size_t bytesPerPixel = row/width;
    
    unsigned char *buffer = CVPixelBufferGetBaseAddress(pixelBuffer);
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    unsigned char* data = CGBitmapContextGetData(c);
    if (data != NULL) {
        size_t maxY = height;
        for(int y = 0; y < maxY; y++) {
            for(int x = 0; x < height; x++) {
                size_t offset = bytesPerPixel * ((width * y) + x);
                data[offset] = buffer[offset];     // R
                data[offset + 1] = buffer[offset + 1]; // G
                data[offset + 2] = buffer[offset + 2]; // B
                data[offset + 3] = buffer[offset + 3]; // A
            }
        }
    }
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
}

@end
