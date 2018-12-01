//
//  ViewController.m
//  FaceCamera
//
//  Created by  zcating on 2018/8/19.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FCMainViewController.h"

#import "FaceCameraView.h"

#import "ShutterView.h"

#import "ScissorViewController.h"

#import "FCCoreVisualService.h"

#import <Masonry/Masonry.h>


@interface FCMainViewController () <
FaceCameraDelegate
> {

}


@property (weak, nonatomic) IBOutlet FaceCameraView *cameraView;


@property (weak, nonatomic) IBOutlet ShutterView *shutterView;


@property (weak, nonatomic) IBOutlet UIView *topContainerView;


@property (strong, nonatomic) FCCoreVisualService *coreVisualService;

@end

@implementation FCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"shape_predictor_68_face_landmarks" ofType:@"dat"];
//    _landmarkDetector = std::make_shared<fc::FaceLandmarkDetector>();
//    std::string modelFileNameCString = [path UTF8String];
//    _landmarkDetector->use(modelFileNameCString);
    
    self.coreVisualService = [FCCoreVisualService new];
    
    
    self.cameraView.delegate = self;
    [self.cameraView start];
    
    [self.shutterView pressShutter:^{
        
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self.cameraView selector:@selector(start) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.cameraView selector:@selector(stop) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    ScissorViewController *viewController = [self findChildViewController:NSStringFromClass([ScissorViewController class])];
    
    NSLog(@"viewContoller %@", viewController);
    
    
    __weak typeof(self) weakSelf = self;
    viewController.block = ^(double ratio) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        double width = CGRectGetWidth(strongSelf.cameraView.frame);
        CGRect afterFrame = CGRectMake(0, 0, width, width * ratio);
        [UIView animateWithDuration:0.2 animations:^{
            strongSelf.cameraView.frame = afterFrame;
            if (ratio == 1) {
                strongSelf.cameraView.center = strongSelf.view.center;
            }
        }];
    };
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


- (IBAction)openSwitch:(UIButton *)sender {
    
    if (self.topContainerView.hidden) {
        CGRect originRect = self.topContainerView.frame;
        CGRect beforeRect = self.topContainerView.frame;
        beforeRect.origin.x = sender.center.x;
        beforeRect.size.width = 0;
        beforeRect.size.height = 0;
        self.topContainerView.frame = beforeRect;

        [UIView animateWithDuration:0.2 animations:^{
            self.topContainerView.hidden = NO;
            self.topContainerView.frame = originRect;
        }];
    } else {
        CGRect originRect = self.topContainerView.frame;
        CGRect afterRect = self.topContainerView.frame;
        afterRect.origin.x = sender.center.x;
        afterRect.size.width = 0;
        afterRect.size.height = 0;
        [UIView animateWithDuration:0.2 animations:^{
            self.topContainerView.frame = afterRect;
        } completion:^(BOOL finished) {
            if (finished) {
                self.topContainerView.hidden = YES;
                self.topContainerView.frame = originRect;
            }
        }];
    }
}


- (IBAction)openSetting:(id)sender {
    
}


- (void)processframe:(nonnull CMSampleBufferRef)sampleBuffer faces:(nullable NSArray *)faces {
    if (faces == nil) {
        return;
    }
    [self.coreVisualService runWithSampleBuffer:sampleBuffer inRects:faces];
}


@end
