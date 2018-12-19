//
//  MaskView.m
//  FaceCamera
//
//  Created by  zcating on 2018/12/19.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "MaskView.h"
#import "MaskGLView.h"

@interface MaskView()

@property (nonatomic) CGRect resolutionRect;

@end

@implementation MaskView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.resolutionRect = [UIScreen mainScreen].bounds;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

*/

- (void)drawRect:(CGRect)rect {
    
    [[UIColor colorWithWhite:0 alpha:1] setFill];

    // The mask area.
    UIRectFill(rect);
    
    // The no mask area.
    CGRect noMaskArea = self.resolutionRect;
    
    // Get the intersection of them.
    CGRect intersection = CGRectIntersection(noMaskArea, rect);
    [[UIColor clearColor] setFill];
    
    UIRectFill(intersection);
}


-(void)setType:(FCResolutionType)type {
    _type = type;
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    switch (_type) {
        case FCResolutionType11: {
            CGPoint center = CGPointMake(CGRectGetMidX(screenFrame), CGRectGetMidY(screenFrame));
            CGFloat y = center.y - screenFrame.size.width / 2;
            self.resolutionRect = CGRectMake(0, y, screenFrame.size.width, screenFrame.size.width);
            break;
        }
        case FCResolutionType34: {
            self.resolutionRect = CGRectMake(0, 0, screenFrame.size.width, screenFrame.size.height * 3 / 4);
            break;
        }
        case FCResolutionType916: {
            self.resolutionRect = CGRectMake(0, 0, screenFrame.size.width, screenFrame.size.height);
            break;
        }
        default:
            break;
    }
    [self setNeedsDisplay];
}

@end
