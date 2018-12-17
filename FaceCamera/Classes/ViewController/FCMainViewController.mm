//
//  ViewController.m
//  FaceCamera
//
//  Created by  zcating on 2018/8/19.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FCMainViewController.h"

#import "FaceCameraView.h"

#import "MaskGLView.h"

#import "ShutterView.h"

#import "ScissorView.h"

#import "FCCoreVisualService.h"

#import <Masonry/Masonry.h>


@interface FCMainViewController () <
ResolutionDelegate,
FaceCameraDelegate
> {
    
}


@property (strong, nonatomic) IBOutlet FaceCameraView *cameraView;

@property (strong, nonatomic) MaskGLView *maskGLView;

@property (strong, nonatomic) ScissorView *scissorView;

@property (strong, nonatomic) UIButton *cameraSwitcher;

@property (strong, nonatomic) UIButton *resolutionSwitcher;


@property (strong, nonatomic) FCCoreVisualService *coreVisualService;

@end

@implementation FCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    [self.view addSubview:self.cameraView];
    [self.view addSubview:self.cameraSwitcher];
    [self.view addSubview:self.resolutionSwitcher];
//    [self.view addSubview:self.scissorView];
    
    [self.cameraView addSubview:self.maskGLView];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self.cameraView selector:@selector(start) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.cameraView selector:@selector(stop) name:UIApplicationDidEnterBackgroundNotification object:nil];
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


// MARK: - DELEGATE

-(void)switchCamera:(UIButton *)sender {
//    NSLog(@"shit");
    sender.selected = !sender.selected;
    [self.cameraView switchCamera];
}

-(void)openResolutionSelector:(UIButton *)sender {
    
}

//- (IBAction)openSetting:(id)sender {
//    [UIView animateWithDuration:0.2 animations:^{
//        self.scissorView.hidden = !self.scissorView.hidden;
//    }];
//}


-(void)resolutionChangeTo:(double)ratio selectedImage:(nonnull UIImage *)image {
    double width = CGRectGetWidth(self.cameraView.frame);
    CGRect afterFrame = CGRectMake(0, 0, width, width * ratio);
    [UIView animateWithDuration:0.2 animations:^{
        self.cameraView.frame = afterFrame;
        if (ratio == 1) {
            self.cameraView.center = self.view.center;
        }
    }];
}

- (void)processframe:(nonnull CMSampleBufferRef)sampleBuffer faces:(nullable NSArray *)faces {
    if (faces == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.maskGLView.hidden) {
                self.maskGLView.hidden = YES;
            }
        });
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.maskGLView.hidden) {
            self.maskGLView.hidden = NO;
        }
    });
    [self.coreVisualService runWithSampleBuffer:sampleBuffer inRects:faces forLandmarkBlock:^(const std::vector<cv::Point_<double>>& landmarks, long faceIndex) {
        [self.maskGLView updateLandmarks:landmarks faceIndex:faceIndex];
    }];
}


// MARK: - GETTER & SETTER

-(FCCoreVisualService *)coreVisualService {
    if (_coreVisualService == nil) {
        _coreVisualService = [FCCoreVisualService new];
    }
    return _coreVisualService;
}

-(ScissorView *)scissorView {
    if (_scissorView == nil) {
        _scissorView = [[ScissorView alloc] init];
    }
    return _scissorView;
}

-(FaceCameraView *)cameraView {
    if (_cameraView == nil) {
        CGSize size = self.view.frame.size;
        _cameraView = [[FaceCameraView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        _cameraView.delegate = self;
    }
    return _cameraView;
}

-(MaskGLView *)maskGLView {
    if (_maskGLView == nil) {
        NSError *error = nil;
        NSURL *path = [[NSBundle mainBundle] URLForResource:@"mask" withExtension:@"json"];
        NSData *jsonData = [NSData dataWithContentsOfURL:path];
        NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
        
        EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        [EAGLContext setCurrentContext:context];
        
        _maskGLView = [[MaskGLView alloc] initWithFrame:self.cameraView.frame context:context];
        _maskGLView.hidden = YES;
        [_maskGLView setupVBOs:@"leopard" withLandmarkArray:array];
    }
    return _maskGLView;
}

-(UIButton *)cameraSwitcher {
    if (_cameraSwitcher == nil) {
        _cameraSwitcher = [UIButton buttonWithType:UIButtonTypeCustom];
        _cameraSwitcher.frame = CGRectMake(10, 20, 50, 50);
        [_cameraSwitcher setImage:[UIImage imageNamed:@"btn_camera_switch_camera_light"] forState:UIControlStateNormal];
        [_cameraSwitcher setImage:[UIImage imageNamed:@"btn_camera_switch_camera_dark"] forState:UIControlStateSelected];
        [_cameraSwitcher addTarget:self action:@selector(switchCamera:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraSwitcher;
}

-(UIButton *)resolutionSwitcher {
    if (_resolutionSwitcher == nil) {
        _resolutionSwitcher = [UIButton buttonWithType:UIButtonTypeCustom];
        _resolutionSwitcher.frame = CGRectMake(70, 20, 50, 50);
        [_resolutionSwitcher setImage:[UIImage imageNamed:@"btn_camera_ratio_916_light"] forState:UIControlStateNormal];
        [_resolutionSwitcher setImage:[UIImage imageNamed:@"btn_camera_ratio_916_dark"] forState:UIControlStateSelected];
        [_resolutionSwitcher addTarget:self action:@selector(openResolutionSelector:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resolutionSwitcher;
    
}

@end