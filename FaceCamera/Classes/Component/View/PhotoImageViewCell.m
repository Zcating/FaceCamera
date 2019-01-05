//
//  PhotoImageViewCell.m
//  FaceCamera
//
//  Created by  zcating on 2019/1/3.
//  Copyright © 2019 zcat. All rights reserved.
//

#import "PhotoImageViewCell.h"

@interface PhotoImageViewCell ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation PhotoImageViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
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
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

-(UIImage *)image {
    return self.imageView.image;
}

-(void)setImage:(UIImage *)image {
    self.imageView.image = image;
}


@end
