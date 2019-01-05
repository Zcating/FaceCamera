//
//  ViewController.m
//  FaceCamera
//
//  Created by  zcating on 2018/8/19.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FCMainViewController.h"
#import "FCImageEditingViewController.h"
#import "FCAlbumViewController.h"
#import "FCMainBottomViewController.h"

#import "FaceCameraView.h"
#import "MaskGLView.h"
#import "MaskView.h"
#import "ResolutionSwitchView.h"
#import "FCMainTopView.h"

#import "FCMainAnimation.h"
#import "FCAlbumAnimation.h"

#import "FCCoreVisualService.h"
#import "ConstantValue.h"

#import <Masonry/Masonry.h>


@interface FCMainViewController () <
ResolutionDelegate,
FaceCameraDelegate,
UIViewControllerTransitioningDelegate,
FCMainTopViewDelegate,
FCMainBottomViewDelegate
>


@property (strong, nonatomic) FaceCameraView *cameraView;

@property (strong, nonatomic) MaskView *maskView;

@property (strong, nonatomic) MaskGLView *maskGLView;

@property (strong, nonatomic) ResolutionSwitchView *switchView;

@property (strong, nonatomic) FCMainTopView *topView;

@property (strong, nonatomic) UIView *bottomView;

@property (strong, nonatomic) UIView *albumView;

@property (strong, nonatomic) FCCoreVisualService *coreVisualService;

@end

@implementation FCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.cameraView];
    [self.view addSubview:self.topView];
    [self.view addSubview:self.switchView];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.albumView];
    
    [self.cameraView addSubview:self.maskGLView];
    [self.cameraView addSubview:self.maskView];
    
    [self prepare];
    
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

#pragma mark - PRIVATE


-(void)prepare {
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(0);
        make.left.equalTo(self.view).offset(0);
        make.right.equalTo(self.view).offset(0);
        make.height.equalTo(@100);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(0);
        make.left.equalTo(self.view).offset(0);
        make.right.equalTo(self.view).offset(0);
        make.height.equalTo(@([UIScreen mainScreen].bounds.size.height * 1 / 4));
    }];
    
    [self.switchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.height.equalTo(@70);
    }];
    
    [self.albumView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(self.view.frame.size.height);
        make.left.equalTo(self.view).offset(0);
        make.size.equalTo(self.view);
    }];
}


-(void)animateResolutionView {
    [UIView animateWithDuration:0.2 animations:^{
        self.switchView.alpha = self.switchView.alpha ? 0 : 1;
    }];
}

-(void)animateAlbumView:(BOOL)show {
    [self.albumView mas_updateConstraints:^(MASConstraintMaker *make) {
        if (show) {
            make.top.equalTo(self.view.mas_top).offset(0);
        } else {
            make.top.equalTo(self.view.mas_top).offset(self.view.frame.size.height);
        }
    }];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - DELEGATE

// Oberserve Events
-(void)restart {
    [self.cameraView start];
}

-(void)stop {
    self.maskGLView.hidden = YES;
    [self.cameraView stop];
}

// Button Events
-(void)switchCamera {
    [self.cameraView switchCamera];
}

-(void)controlResolutionSelector {
    [self animateResolutionView];
}

-(void)resolutionChangeTo:(FCResolutionType)type selectedImage:(nonnull UIImage *)image {
    self.maskView.type = type;
    [self.topView changeResolutionImage:image];
}

-(void)takingPhoto {
    UIImage *maskImage = self.maskGLView.hidden == NO ? self.maskGLView.snapshot : nil;
    [self.coreVisualService generateImageWithMask:maskImage resolutionType:self.maskView.type inBlock:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            FCImageEditingViewController *controller =  [[FCImageEditingViewController alloc] init];
            controller.image = image;
            controller.type = self.maskView.type;
            controller.transitioningDelegate = self;
            [self presentViewController:controller animated:YES completion:nil];
        });
    }];
}

- (void)selectImageFromPhotoAlbum {
    [self animateAlbumView:YES];
}

- (void)selectSticker:(NSString *)name {
    NSError *error = nil;
    NSURL *path = [[NSBundle mainBundle] URLForResource:@"mask" withExtension:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfURL:path];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
    [self.maskGLView setupImage:name landmarks:array];
}


// Animation Delegate
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
//    if ([presenting isKindOfClass:[FCImageEditingViewController class]]) {
//        return [FCMainPresentAnimation new];
//    } else if ([presenting isKindOfClass:[FCAlbumViewController class]]) {
////        return
//        return [FCAlbumPresentAnimation new];
//    } else {
//
//    }
    return [FCMainPresentAnimation new];
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [FCMainDismissAnimation new];
}

// Camera Frame Delegate
- (void)processframe:(nonnull CMSampleBufferRef)sampleBuffer faces:(nullable NSArray *)faces {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.maskGLView.hidden = faces == nil;
    });
    
    [self.coreVisualService runWithSampleBuffer:sampleBuffer inRects:faces forLandmarkBlock:^(const std::vector<cv::Point_<double>>& landmarks, long faceIndex) {
        [self.maskGLView updateLandmarks:landmarks faceIndex:faceIndex];
    }];
}


#pragma mark - GETTER & SETTER

-(FCCoreVisualService *)coreVisualService {
    if (_coreVisualService == nil) {
        _coreVisualService = [FCCoreVisualService new];
    }
    return _coreVisualService;
}

-(ResolutionSwitchView *)switchView {
    if (_switchView == nil) {
        _switchView = [[ResolutionSwitchView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _switchView.delegate = self;
        _switchView.alpha = 0;
    }
    return _switchView;
    
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
        EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        [EAGLContext setCurrentContext:context];
        
        CGRect frame = [UIScreen mainScreen].bounds;
        _maskGLView = [[MaskGLView alloc] initWithFrame:frame context:context];
        _maskGLView.hidden = YES;
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

-(FCMainTopView *)topView {
    if (_topView == nil) {
        _topView = [[FCMainTopView alloc] initWithFrame:CGRectZero];
        _topView.delegate = self;
    }
    return _topView;
}

-(UIView *)bottomView {
    if (_bottomView == nil) {
        FCMainBottomViewController *controller = [[FCMainBottomViewController alloc] init];
        controller.delegate = self;
        [self addChildViewController:controller];
        _bottomView = controller.view;
    }
    return _bottomView;
}

-(UIView *)albumView {
    if (_albumView == nil) {
        FCAlbumViewController *controller = [FCAlbumViewController new];
        __weak FCMainViewController *weakSelf = self;
        controller.close = ^{
            __strong FCMainViewController *strongSelf = weakSelf;
            [strongSelf animateAlbumView:NO];
        };
        [self addChildViewController:controller];
        _albumView = controller.view;
    }
    return _albumView;
}
@end
