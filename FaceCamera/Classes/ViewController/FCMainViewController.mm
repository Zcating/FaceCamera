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
#import "MaskView.h"

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

@property (strong, nonatomic) MaskView *maskView;

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
    [self.view addSubview:self.scissorView];
    [self.cameraView addSubview:self.maskGLView];
    [self.cameraView addSubview:self.maskView];
    
    
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
    sender.selected = !sender.selected;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
//    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGRect showingFrame = CGRectMake(20, 100, width - 40 , 70);
    CGRect hiddenFrame = CGRectMake(20, 100, 0, 0);
    [self.view bringSubviewToFront:self.scissorView];
    [UIView animateWithDuration:0.2 animations:^{
        self.scissorView.frame = sender.selected ? showingFrame : hiddenFrame;
    }];
}

//- (IBAction)openSetting:(id)sender {
//    [UIView animateWithDuration:0.2 animations:^{
//        self.scissorView.hidden = !self.scissorView.hidden;
//    }];
//}


-(void)resolutionChangeTo:(FCResolutionType)type selectedImage:(nonnull UIImage *)image {
    [self.resolutionSwitcher setImage:image forState:UIControlStateNormal];
    self.maskView.type = type;
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
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        _scissorView = [[ScissorView alloc] initWithFrame:CGRectMake(20, 100, 0, 0)];
//        _scissorView.frame = CGRectMake(20, 100, 0, 0);
        _scissorView.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1];
        _scissorView.delegate = self;
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

        CGRect frame = [UIScreen mainScreen].bounds;
        _maskGLView = [[MaskGLView alloc] initWithFrame:frame context:context];
        _maskGLView.hidden = YES;
        [_maskGLView setupVBOs:@"leopard" withLandmarkArray:array];
    }
    return _maskGLView;
}

-(MaskView *)maskView {
    if (_maskView == nil) {
        CGRect frame = [UIScreen mainScreen].bounds;
        _maskView = [[MaskView alloc] initWithFrame:frame];
    }
    return _maskView;
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
        [_resolutionSwitcher addTarget:self action:@selector(openResolutionSelector:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resolutionSwitcher;
}

@end
