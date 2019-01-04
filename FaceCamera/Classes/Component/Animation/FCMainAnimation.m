//
//  FCMainAnimation.m
//  FaceCamera
//
//  Created by  zcating on 2018/12/24.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FCMainAnimation.h"

@interface FCMainPresentAnimation()

@property (nonatomic, strong) UIView *maskView;

@end

@implementation FCMainPresentAnimation

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
    
    [toView addSubview:self.maskView];
    [[transitionContext containerView] addSubview:toView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        self.maskView.alpha = 0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        [self.maskView removeFromSuperview];
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


@implementation FCMainDismissAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.2;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    [[transitionContext containerView] addSubview:toView];
    
    toView.alpha = 0;
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toView.alpha = 1;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}
@end
