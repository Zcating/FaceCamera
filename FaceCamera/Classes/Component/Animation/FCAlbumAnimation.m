//
//  FCAlbumAnimation.m
//  FaceCamera
//
//  Created by  zcating on 2019/1/4.
//  Copyright © 2019 zcat. All rights reserved.
//

#import "FCAlbumAnimation.h"

@implementation FCAlbumPresentAnimation

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
    
    toView.frame = CGRectMake(0, fromView.frame.size.height, CGRectGetWidth(toView.frame), CGRectGetHeight(toView.frame));
    [[transitionContext containerView] addSubview:toView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toView.frame = CGRectMake(0, 0, CGRectGetWidth(toView.frame), CGRectGetHeight(toView.frame));
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end


@implementation FCAlbumDismissAnimation

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
//    toView.frame = CGRectMake(0, fromView.frame.size.height, CGRectGetWidth(toView.frame), CGRectGetHeight(toView.frame));
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toView.frame = CGRectMake(0, fromView.frame.size.height, CGRectGetWidth(toView.frame), CGRectGetHeight(toView.frame));
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end
