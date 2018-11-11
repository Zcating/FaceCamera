//
//  BaseViewController.m
//  FaceCamera
//
//  Created by  zcating on 2018/11/9.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@property (nonatomic, strong) NSMutableDictionary *viewControllerDict;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(NSMutableDictionary *)viewControllerDict {
    if (_viewControllerDict == nil) {
        _viewControllerDict = [NSMutableDictionary new];
    }
    return _viewControllerDict;
}

-(void)addChildViewController:(UIViewController *)childController {
    [super addChildViewController:childController];
    [self.viewControllerDict setObject:childController forKey:NSStringFromClass([childController class])];
}

-(__kindof UIViewController *)findChildViewController:(NSString *)name {
    return self.viewControllerDict[name];
}

@end
