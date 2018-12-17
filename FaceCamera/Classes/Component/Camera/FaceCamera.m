//
//  FaceCamera.m
//  FaceCamera
//
//  Created by  zcating on 2018/8/21.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FaceCamera.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

static const NSString *AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";


@interface FaceCamera()<
AVCaptureVideoDataOutputSampleBufferDelegate,
AVCaptureMetadataOutputObjectsDelegate
> {
    dispatch_queue_t _concurrentQueue;
    dispatch_queue_t _videoQueue;
    dispatch_queue_t _metadataQueue;
    AVCaptureDevicePosition _devicePosition;
    NSArray *_metadataObjects;
    
}

@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, strong) AVCaptureDevice *device;

@property (nonatomic, strong) AVCaptureDeviceInput *currentInput;

@property (nonatomic, strong) AVCaptureDeviceInput *frontCameraInput;

@property (nonatomic, strong) AVCaptureDeviceInput *backCameraInput;

@property (nonatomic, strong) AVCaptureConnection *videoConnection;

@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOuput;

@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;

@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, strong) NSArray *metadataObjects;

@end


@implementation FaceCamera

- (instancetype)initWithDelegate:(id<FaceCameraDelegate>)delegate {
    self = [self init];
    if (self) {
        self.delegate = delegate;
    }
    
    return self;
}

// real initialization function.
- (instancetype) init {
    self = [super init];
    if (self) {
        // Camera
        [self initCamera];
        
        // data output
        [self initVideoDataOutput];
        
        // photo taking.
//        [self initPhotoTaking];
        
        // metadata output
        [self initMetadataOutput];
        
        [self initQueue];
    }
    return self;
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

//-(void)initPhotoTaking {
//    if ([self.session canAddOutput:self.stillImageOutput]) {
//        [self.session addOutput:self.stillImageOutput];
//    }
//}

-(void)initMetadataOutput {
    if ([self.session canAddOutput:self.metadataOuput]) {
        [self.session addOutput:self.metadataOuput];
        _metadataQueue = dispatch_queue_create("face.camera.metadata", 0);
        [self.metadataOuput setMetadataObjectsDelegate:self queue:_metadataQueue];
        [self.metadataOuput setMetadataObjectTypes:@[AVMetadataObjectTypeFace]];
    }
}

-(void)initQueue {
    _concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}


// MARK: - Public Function

- (void)start {
    [self.session startRunning];
}


- (void)stop {
    [self.session stopRunning];
}


// MARK: - Private Function



// MARK: - Video Delegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    if(self.devicePosition == AVCaptureDevicePositionFront && connection.supportsVideoMirroring) {
        [connection setVideoMirrored:YES];
    }
    
    NSMutableArray *bounds = nil;
    if (self.metadataObjects.count != 0) {
        // find faces.
        bounds = [NSMutableArray arrayWithCapacity:2];
        for (AVMetadataObject *object in self.metadataObjects) {
            if([object isKindOfClass:[AVMetadataFaceObject class]]) {
                AVMetadataObject *face = [output transformedMetadataObjectForMetadataObject:object connection:connection];
                [bounds addObject:[NSValue valueWithCGRect:face.bounds]];
            }
        }
    }
    
    // process faces in delegate function.
    if ([self.delegate respondsToSelector:@selector(processframe:faces:)]) {
        [self.delegate processframe:sampleBuffer faces:bounds];
    }
}


- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    if(self.devicePosition == AVCaptureDevicePositionFront && connection.supportsVideoMirroring) {
        [connection setVideoMirrored:YES];
    }
}


- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    self.metadataObjects = metadataObjects;
}



// MARK: - getter & setter

-(AVCaptureSession *)session {
    if (_session == nil) {
        _session = [AVCaptureSession new];
        if ([_session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
            _session.sessionPreset = AVCaptureSessionPresetHigh;
        }
    }
    return _session;
}

-(AVCaptureMetadataOutput *)metadataOuput {
    if (_metadataOuput == nil) {
        _metadataOuput = [[AVCaptureMetadataOutput alloc] init];
    }
    return _metadataOuput;
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

- (AVCaptureSessionPreset)sessionPreset {
    return self.session.sessionPreset;
}

- (void)setSessionPreset:(AVCaptureSessionPreset)sessionPreset{
    if ([self.session isRunning]) {
//        [self.session stopRunning];
        [self.session beginConfiguration];
        self.session.sessionPreset = sessionPreset;
        [self.session commitConfiguration];
//        [self.session startRunning];
        
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
        dispatch_async(_concurrentQueue, ^{
            [self.session stopRunning];
            [self.session beginConfiguration];
            [self.session removeInput:self.currentInput];
            if (devicePosition == AVCaptureDevicePositionFront && [self.session canAddInput:self.frontCameraInput]) {
                [self.session addInput:self.frontCameraInput];
                self.currentInput = self.frontCameraInput;
            } else if ([self.session canAddInput:self.backCameraInput]) {
                [self.session addInput:self.backCameraInput];
                self.currentInput = self.backCameraInput;
            }
            dispatch_barrier_async(self->_metadataQueue, ^{
                self.metadataObjects = nil;
            });
            [self.session commitConfiguration];
            [self.session startRunning];

        });
    } else {
        [self.session removeInput:self.currentInput];
        if (devicePosition == AVCaptureDevicePositionFront && [self.session canAddInput:self.frontCameraInput]) {
            [self.session addInput:self.frontCameraInput];
            self.currentInput = self.frontCameraInput;
        } else if ([self.session canAddInput:self.backCameraInput]) {
            [self.session addInput:self.backCameraInput];
            self.currentInput = self.backCameraInput;
        }
        self.metadataObjects = nil;
    }
}

-(NSArray *)metadataObjects {
    __block NSArray *objects = nil;
//    dispatch_sync(_concurrentQueue, ^{
        objects = self->_metadataObjects;
//    });
    return objects;
}

-(void)setMetadataObjects:(NSArray *)metadataObjects {
//    dispatch_barrier_async(_concurrentQueue, ^{
        self->_metadataObjects = metadataObjects;
//    });
}

@end
