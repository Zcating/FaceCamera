


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

@interface FaceCamera()<
AVCaptureVideoDataOutputSampleBufferDelegate,
AVCaptureMetadataOutputObjectsDelegate
> {
    dispatch_queue_t _concurrentQueue;
    dispatch_queue_t _videoQueue;
    dispatch_queue_t _metadataQueue;
    AVCaptureDevicePosition _devicePosition;
    NSArray *_metadataObjects;
    
    BOOL _running;
    BOOL _sessionLoaded;
    
}

@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, strong) AVCaptureDeviceInput *frontCameraInput;

@property (nonatomic, strong) AVCaptureDeviceInput *backCameraInput;

@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOuput;

@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;

@property (nonatomic, strong) NSArray *metadataObjects;

@end


@implementation FaceCamera

- (instancetype)initWithDelegate:(id<FaceCameraDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        _metadataQueue = dispatch_queue_create("face.camera.metadata", 0);
        _videoQueue = dispatch_queue_create("video.queue", NULL);
        _concurrentQueue = dispatch_queue_create("concurrent.queue", DISPATCH_QUEUE_CONCURRENT);

    }
    
    return self;
}


// MARK: - Public Function

- (void)start {
    if (_running == YES) {
        return;
    }
    if (_sessionLoaded == NO) {
        [self updateSession];
        _sessionLoaded = YES;
    }
    
    [self.session startRunning];
    _running = YES;
}


- (void)stop {
    if (_running == NO) {
        return;
    }

    for (AVCaptureInput *input in self.session.inputs) {
        [self.session removeInput:input];
    }

    for (AVCaptureOutput *output in self.session.outputs) {
        [self.session removeOutput:output];
    }

    [self.session stopRunning];
    _running = NO;
    _sessionLoaded = NO;
}

-(void)pause {
    [self.session stopRunning];
    _running = NO;
}

-(void)switchCameras {
    BOOL wasRunning = _running;
    if (wasRunning) {
        [self stop];
    }
    if (self.devicePosition == AVCaptureDevicePositionFront) {
        self.devicePosition = AVCaptureDevicePositionBack;
    } else {
        self.devicePosition = AVCaptureDevicePositionFront;
    }
    if (wasRunning) {
        [self start];
    }
}


// MARK: - Private Function

-(void)updateSession {
        // video data output

    if (self.devicePosition == AVCaptureDevicePositionFront) {
        if ([self.session canAddInput:self.frontCameraInput]) {
            [self.session addInput:self.frontCameraInput];
        }
    } else {
        if ([self.session canAddInput:self.backCameraInput]) {
            [self.session addInput:self.backCameraInput];
        }
    }

    if ([self.session canAddOutput:self.videoOutput]) {
        [self.session addOutput:self.videoOutput];
    }
    
    // metadata output
    if ([self.session canAddOutput:self.metadataOuput]) {
        [self.session addOutput:self.metadataOuput];
        [self.metadataOuput setMetadataObjectsDelegate:self queue:_metadataQueue];
        [self.metadataOuput setMetadataObjectTypes:@[AVMetadataObjectTypeFace]];
    }
}


// MARK: - Video Delegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (connection.supportsVideoOrientation) {
        connection.videoOrientation = self.orientation;
    }
    if (connection.supportsVideoMirroring) {
        connection.videoMirrored = self.devicePosition == AVCaptureDevicePositionFront;
        
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


- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    self.metadataObjects = metadataObjects;
}



    // MARK: - getter & setter

-(AVCaptureSession *)session {
    if (_session == nil) {
        _session = [AVCaptureSession new];
        if ([_session canSetSessionPreset:self.sessionPreset]) {
            _session.sessionPreset = self.sessionPreset;
        }
    }
    return _session;
}

-(AVCaptureMetadataOutput *)metadataOuput {
    if (_metadataOuput == nil) {
        _metadataOuput = [AVCaptureMetadataOutput new];
    }
    return _metadataOuput;
}

-(AVCaptureVideoDataOutput *)videoOutput {
    if (_videoOutput == nil) {
        _videoOutput = [AVCaptureVideoDataOutput new];
        _videoOutput.videoSettings = @{
            (NSString*)kCVPixelBufferPixelFormatTypeKey: @(kCMPixelFormat_32BGRA)
        };
        _videoOutput.alwaysDiscardsLateVideoFrames = YES;
        [_videoOutput setSampleBufferDelegate:self queue:_videoQueue];
    }
    return _videoOutput;
}



-(AVCaptureDeviceInput *)backCameraInput {
    if (_backCameraInput == nil) {
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        NSError *error;
        for (AVCaptureDevice *device in devices) {
            if (device.position == AVCaptureDevicePositionFront) {
                continue;
            }
            _backCameraInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
            if (error) {
                NSLog(@"[FaceCamera] error: %@", error.description);
            }
        }
    }
    return _backCameraInput;
}

-(AVCaptureDeviceInput *)frontCameraInput {
    if (_frontCameraInput == nil) {
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        NSError *error;
        for (AVCaptureDevice *device in devices) {
            if (device.position == AVCaptureDevicePositionBack) {
                continue;
            }
            _frontCameraInput  = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
            if (error) {
                NSLog(@"[FaceCamera] error: %@", error.description);
            }
        }
    }
    return _frontCameraInput;
}

- (AVCaptureSessionPreset)sessionPreset {
    if (_sessionPreset == nil) {
        _sessionPreset = AVCaptureSessionPreset1280x720;
    }
    return _sessionPreset;
}

- (AVCaptureDevicePosition)devicePosition {
    return _devicePosition;
}

-(AVCaptureVideoOrientation)orientation {
    if (_orientation == 0) {
        _orientation = AVCaptureVideoOrientationPortrait;
    }
    return _orientation;
}

-(NSArray *)metadataObjects {
    __block NSArray *objects = nil;
    dispatch_sync(_concurrentQueue, ^{
        objects = self->_metadataObjects;
    });
    return objects;
}

-(void)setMetadataObjects:(NSArray *)metadataObjects {
    dispatch_barrier_async(_concurrentQueue, ^{
        self->_metadataObjects = metadataObjects;
    });
}




@end
