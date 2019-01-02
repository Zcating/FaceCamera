//
//  FCMaskCell.m
//  FaceCamera
//
//  Created by  zcating on 2019/1/2.
//  Copyright © 2019 zcat. All rights reserved.
//

#import "FCMaskCell.h"

@interface FCMaskCell() {
    UIImageView *_imageView;
}
@end

@implementation FCMaskCell

//@synthesize _imageView;

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
    }
    return self;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
    return _imageView;
}
@end
