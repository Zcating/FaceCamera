//
//  FCDismissAnimation.m
//  FaceCamera
//
//  Created by  zcating on 2018/12/25.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FCMainDismissAnimation.h"

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
