//
//  FCMaskCell.m
//  FaceCamera
//
//  Created by  zcating on 2019/1/2.
//  Copyright © 2019 zcat. All rights reserved.
//

#import "FCMaskCell.h"

@interface FCMaskCell()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation FCMaskCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [UIColor greenColor].CGColor;
        [self addSubview:self.imageView];
    }
    return self;
}

#pragma mark - PUBLIC

#pragma mark - PRIVATE

#pragma mark - DELEGATE

#pragma mark - GETTER & SETTER


- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
    return _imageView;
}

-(UIImage *)image {
    return self.imageView.image;
}

-(void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.layer.borderWidth = 2;
    } else {
        self.layer.borderWidth = 0;
    }
}

@end
