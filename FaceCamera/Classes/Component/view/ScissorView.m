//
//  ScissorView.m
//  FaceCamera
//
//  Created by  zcating on 2018/11/7.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "ScissorView.h"


@interface ScissorView ()

@property (nonatomic, strong) NSArray *images;

@property (nonatomic, strong) UIButton *ratio4To3Button;

@property (nonatomic, strong) UIButton *ratio16To9Button;

@property (nonatomic, strong) UIButton *ratio1To1Button;

@property (nonatomic, strong) UIButton *roundScissorButton;

@end


@implementation ScissorView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 10;
        
        [self addSubview:self.ratio16To9Button];
        [self addSubview:self.ratio4To3Button];
        [self addSubview:self.ratio1To1Button];
        [self addSubview:self.roundScissorButton];
    }
    return self;
}


-(void)changeState:(FCResolutionType)type {
    self.ratio1To1Button.selected = type == FCResolutionType11;
    self.ratio4To3Button.selected = type == FCResolutionType34;
    self.ratio16To9Button.selected = type == FCResolutionType916;
}


-(void)changeRatio1To1:(UIButton *)sender {
    [self changeState:FCResolutionType11];
    if ([self.delegate respondsToSelector:@selector(resolutionChangeTo:selectedImage:)]) {
        [self.delegate resolutionChangeTo:FCResolutionType11 selectedImage:self.images[0]];
    }
}

-(void)changeRatio4To3:(UIButton *)sender {
    [self changeState:FCResolutionType34];
    if ([self.delegate respondsToSelector:@selector(resolutionChangeTo:selectedImage:)]) {
        [self.delegate resolutionChangeTo:FCResolutionType34 selectedImage:self.images[1]];
    }
}

-(void)changeRatio16To9:(UIButton *)sender {
    [self changeState:FCResolutionType916];
    if ([self.delegate respondsToSelector:@selector(resolutionChangeTo:selectedImage:)]) {
        [self.delegate resolutionChangeTo:FCResolutionType916 selectedImage:self.images[2]];
    }
}


-(NSArray *)images {
    if (_images == nil) {
        _images = @[
                    [UIImage imageNamed:@"btn_camera_ratio_11_light"],
                    [UIImage imageNamed:@"btn_camera_ratio_34_light"],
                    [UIImage imageNamed:@"btn_camera_ratio_916_light"]
                    ];
    }
    return _images;
}


-(UIButton *)ratio1To1Button {
    if (_ratio1To1Button == nil) {
        _ratio1To1Button = [UIButton buttonWithType:UIButtonTypeCustom];
        _ratio1To1Button.frame = CGRectMake(10, 10, 50, 50);
        [_ratio1To1Button setImage:[UIImage imageNamed:@"btn_camera_ratio_11_dark"] forState:UIControlStateNormal];
        [_ratio1To1Button setImage:self.images[0]  forState:UIControlStateSelected];
        [_ratio1To1Button addTarget:self action:@selector(changeRatio1To1:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _ratio1To1Button;
}

-(UIButton *)ratio4To3Button {
    if (_ratio4To3Button == nil) {
        _ratio4To3Button = [UIButton buttonWithType:UIButtonTypeCustom];
        _ratio4To3Button.frame = CGRectMake(60, 10, 50, 50);
        [_ratio4To3Button setImage:[UIImage imageNamed:@"btn_camera_ratio_34_dark"] forState:UIControlStateNormal];
        [_ratio4To3Button setImage:self.images[1] forState:UIControlStateSelected];
        [_ratio4To3Button addTarget:self action:@selector(changeRatio4To3:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _ratio4To3Button;
}

-(UIButton *)ratio16To9Button {
    if (_ratio16To9Button == nil) {
        _ratio16To9Button = [UIButton buttonWithType:UIButtonTypeCustom];
        _ratio16To9Button.frame = CGRectMake(120, 10, 50, 50);
        
        [_ratio16To9Button setImage:[UIImage imageNamed:@"btn_camera_ratio_916_dark"] forState:UIControlStateNormal];
        [_ratio16To9Button setImage:self.images[2] forState:UIControlStateSelected];
        [_ratio16To9Button addTarget:self action:@selector(changeRatio16To9:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _ratio16To9Button;
}




@end
