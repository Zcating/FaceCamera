//
//  FCPresentAnimation.m
//  FaceCamera
//
//  Created by  zcating on 2018/12/24.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FCPresentAnimation.h"

@interface FCPresentAnimation()

@property (nonatomic, strong) UIView *maskView;

@end

@implementation FCPresentAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView* toView = nil;
    UIView* fromView = nil;
    
    if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {
        fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    } else {
        fromView = fromViewController.view;
        toView = toViewController.view;
    }
    
    [fromView addSubview:self.maskView];
    [[transitionContext containerView] addSubview:toView];
    
//    transView.frame = CGRectMake(_isPresent ?width :0, 0, width, height);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
//        transView.frame = CGRectMake(_isPresent ?0 :width, 0, width, height);
        
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}


-(UIView *)maskView {
    if (_maskView == nil) {
        _maskView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _maskView.backgroundColor = [UIColor whiteColor];
    }
    return _maskView;
}

@end
