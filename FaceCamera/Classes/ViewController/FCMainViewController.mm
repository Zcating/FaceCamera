//
//  ViewController.m
//  FaceCamera
//
//  Created by  zcating on 2018/8/19.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FCMainViewController.h"
#import "FCImageEditingViewController.h"

#import "FaceCameraView.h"
#import "MaskGLView.h"
#import "MaskView.h"
#import "ResolutionSwitchView.h"

#import "FCPresentAnimation.h"
#import "FCDismissAnimation.h"

#import "FCCoreVisualService.h"
#import "ConstantValue.h"

#import <Masonry/Masonry.h>


@interface FCMainViewController () <
ResolutionDelegate,
FaceCameraDelegate,
UIViewControllerTransitioningDelegate
> {
    
}


@property (strong, nonatomic) IBOutlet FaceCameraView *cameraView;

@property (strong, nonatomic) MaskView *maskView;

@property (strong, nonatomic) MaskGLView *maskGLView;

@property (strong, nonatomic) ResolutionSwitchView *scissorView;

@property (strong, nonatomic) UIButton *cameraSwitcher;

@property (strong, nonatomic) UIButton *resolutionSwitcher;

@property (strong, nonatomic) UIButton *shutterButton;

@property (strong, nonatomic) FCCoreVisualService *coreVisualService;

@end

@implementation FCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    [self.view addSubview:self.cameraView];
    [self.view addSubview:self.cameraSwitcher];
    [self.view addSubview:self.resolutionSwitcher];
    [self.view addSubview:self.scissorView];
    [self.view addSubview:self.shutterButton];
    [self.cameraView addSubview:self.maskGLView];
    [self.cameraView addSubview:self.maskView];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restart) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stop) name:UIApplicationDidEnterBackgroundNotification object:nil];
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

// MARK: - PRIVATE

-(void)animateResolutionView:(BOOL)showed {
//    CGFloat width = [UIScreen mainScreen].bounds.size.width;
//    CGRect showingFrame = CGRectMake(20, 100, width - 40 , 70);
//    CGRect hiddenFrame = CGRectMake(20, 100, 0, 0);
    [self.view bringSubviewToFront:self.scissorView];
    [UIView animateWithDuration:0.2 animations:^{
        self.scissorView.alpha = showed ? 1 : 0;
    }];
}


// MARK: - DELEGATE

// Oberserve Events
-(void)restart {
    [self.cameraView start];
}

-(void)stop {
    self.maskGLView.hidden = YES;
    [self.cameraView stop];
}

// Button Events
-(void)switchCamera:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.cameraView switchCamera];
}


-(void)openResolutionSelector:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self animateResolutionView:sender.selected];
}

-(void)resolutionChangeTo:(FCResolutionType)type selectedImage:(nonnull UIImage *)image {
    [self.resolutionSwitcher setImage:image forState:UIControlStateNormal];
    self.maskView.type = type;
    self.resolutionSwitcher.selected = NO;
    [self animateResolutionView:self.resolutionSwitcher.selected];
}

-(void)takingPhoto:(UIButton *)sender {
    UIImage *maskImage = !self.maskGLView.hidden ? self.maskGLView.snapshot : nil;
    [self.coreVisualService generateImageWithMask:maskImage resolutionType:self.maskView.type inBlock:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            FCImageEditingViewController *controller =  [[FCImageEditingViewController alloc] init];
            controller.imageView.image = image;
            controller.type = self.maskView.type;
            controller.transitioningDelegate = self;
            [self presentViewController:controller animated:YES completion:nil];
        });
    }];
}


// Animation Delegate
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [FCPresentAnimation new];
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [FCDismissAnimation new];
}

// Camera Frame Delegate
- (void)processframe:(nonnull CMSampleBufferRef)sampleBuffer faces:(nullable NSArray *)faces {
    [self.coreVisualService runWithSampleBuffer:sampleBuffer inRects:faces forLandmarkBlock:^(const std::vector<cv::Point_<double>>& landmarks, long faceIndex) {
        [self.maskGLView updateLandmarks:landmarks faceIndex:faceIndex];
    }];

    dispatch_async(dispatch_get_main_queue(), ^{
        self.maskGLView.hidden = faces == nil;
    });
}


// MARK: - GETTER & SETTER

-(FCCoreVisualService *)coreVisualService {
    if (_coreVisualService == nil) {
        _coreVisualService = [FCCoreVisualService new];
    }
    return _coreVisualService;
}

-(ResolutionSwitchView *)scissorView {
    if (_scissorView == nil) {
        _scissorView = [[ResolutionSwitchView alloc] initWithFrame:CGRectMake(20, 100, 0, 0)];
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        _scissorView.frame = CGRectMake(20, 100, width - 40 , 70);
        _scissorView.delegate = self;
        _scissorView.alpha = 0;
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
        [_cameraSwitcher setImage:[UIImage imageNamed:BTN_SWITCH_LIGHT] forState:UIControlStateNormal];
        [_cameraSwitcher setImage:[UIImage imageNamed:BTN_SWITCH_DARK] forState:UIControlStateSelected];
        [_cameraSwitcher addTarget:self action:@selector(switchCamera:) forControlEvents:UIControlEventTouchUpInside];

        _cameraSwitcher.frame = CGRectMake(10, 20, 50, 50);
    }
    return _cameraSwitcher;
}

-(UIButton *)resolutionSwitcher {
    if (_resolutionSwitcher == nil) {
        _resolutionSwitcher = [UIButton buttonWithType:UIButtonTypeCustom];
        [_resolutionSwitcher setImage:[UIImage imageNamed:@"btn_camera_ratio_916_light"] forState:UIControlStateNormal];
        [_resolutionSwitcher addTarget:self action:@selector(openResolutionSelector:) forControlEvents:UIControlEventTouchUpInside];

        _resolutionSwitcher.frame = CGRectMake(70, 20, 50, 50);
    }
    return _resolutionSwitcher;
}

-(UIButton *)shutterButton {
    if (_shutterButton == nil) {
        _shutterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shutterButton setImage:[UIImage imageNamed:BTN_PHOTO_TAKING_LIGHT] forState:UIControlStateNormal];
        [_shutterButton setImage:[UIImage imageNamed:BTN_PHOTO_TAKING_DARK] forState:UIControlStateSelected];
        [_shutterButton addTarget:self action:@selector(takingPhoto:) forControlEvents:UIControlEventTouchUpInside];

        CGRect frame = [[UIScreen mainScreen] bounds];
        CGFloat x = CGRectGetMidX(frame) - 40;
        CGFloat y = frame.size.height - 30 - 60;
        _shutterButton.frame = CGRectMake(x, y, 60, 60);
    }
    return _shutterButton;
}



@end
