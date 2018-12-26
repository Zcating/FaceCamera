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

@property (nonatomic) CGRect noMaskArea;

@end

@implementation MaskView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.noMaskArea = [UIScreen mainScreen].bounds;
        
        _type = FCResolutionType916;
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
    
    // Get the intersection of them.
    CGRect intersection = CGRectIntersection(self.noMaskArea, rect);
    [[UIColor clearColor] setFill];
    
    UIRectFill(intersection);
}


-(void)setType:(FCResolutionType)type {
    _type = type;
    self.noMaskArea = [GlobalUtils getRectFromResolutionType:_type size:[UIScreen mainScreen].bounds.size];
    [self setNeedsDisplay];
}

@end
