//
//  ResolutionSwitchView.m
//  FaceCamera
//
//  Created by  zcating on 2018/11/7.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "ResolutionSwitchView.h"

#import "ConstantValue.h"

#import <Masonry/Masonry.h>

@interface ResolutionSwitchView ()

@property (nonatomic, strong) UIButton *ratio4To3Button;

@property (nonatomic, strong) UIButton *ratio16To9Button;

@property (nonatomic, strong) UIButton *ratio1To1Button;

@property (nonatomic, strong) UIButton *roundScissorButton;

@end


@implementation ResolutionSwitchView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.ratio16To9Button];
        [self addSubview:self.ratio4To3Button];
        [self addSubview:self.ratio1To1Button];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [self drawArrow: rect];
}

-(void)updateConstraints {
    [self.ratio1To1Button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self).offset(40);
        make.size.equalTo(@50);
    }];
    
    [self.ratio4To3Button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.centerX.equalTo(self.mas_centerX);
            //        make.left.greaterThanOrEqualTo(self).offset(40);
        make.size.equalTo(@50);
    }];
    
    [self.ratio16To9Button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
            //        make.left.greaterThanOrEqualTo(self).offset(40);
        make.right.equalTo(self).offset(-40);
        make.size.equalTo(@50);
    }];
    [super updateConstraints];
}

#pragma mark - PRIVATE


-(void)drawArrow:(CGRect)rect {
    CGFloat width = rect.size.width;
    CGRect currentRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:currentRect cornerRadius:10];
    bezierPath.lineWidth = 1;
    bezierPath.lineCapStyle = kCGLineCapRound;
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    
    CGFloat midX = width * 0.5;
    [bezierPath addLineToPoint:CGPointMake(midX - 10, 0)];
    [bezierPath addLineToPoint:CGPointMake(midX, -10)];
    [bezierPath addLineToPoint:CGPointMake(midX + 10, 0)];
    [bezierPath closePath];
    
    CAShapeLayer *shaperLayer = [CAShapeLayer new];
    shaperLayer.fillColor =  [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:0.8].CGColor;
    shaperLayer.path = bezierPath.CGPath;
    self.layer.mask = shaperLayer;
    [self.layer insertSublayer:shaperLayer atIndex:0];
}



-(void)changeState:(FCResolutionType)type {
    self.ratio1To1Button.selected = type == FCResolutionType11;
    self.ratio4To3Button.selected = type == FCResolutionType34;
    self.ratio16To9Button.selected = type == FCResolutionType916;
}


#pragma mark - DELEGATE

-(void)changeRatio1To1:(UIButton *)sender {
    [self changeState:FCResolutionType11];
    if ([self.delegate respondsToSelector:@selector(resolutionChangeTo:selectedImage:)]) {
        [self.delegate resolutionChangeTo:FCResolutionType11 selectedImage:[sender imageForState:UIControlStateSelected]];
    }
}

-(void)changeRatio4To3:(UIButton *)sender {
    [self changeState:FCResolutionType34];
    if ([self.delegate respondsToSelector:@selector(resolutionChangeTo:selectedImage:)]) {
        [self.delegate resolutionChangeTo:FCResolutionType34 selectedImage:[sender imageForState:UIControlStateSelected]];
    }
}

-(void)changeRatio16To9:(UIButton *)sender {
    [self changeState:FCResolutionType916];
    if ([self.delegate respondsToSelector:@selector(resolutionChangeTo:selectedImage:)]) {
        [self.delegate resolutionChangeTo:FCResolutionType916 selectedImage:[sender imageForState:UIControlStateSelected]];
    }
}

#pragma mark - GETTER & SETTER

-(UIButton *)ratio1To1Button {
    if (_ratio1To1Button == nil) {
        _ratio1To1Button = [UIButton buttonWithType:UIButtonTypeCustom];
        _ratio1To1Button.frame = CGRectMake(10, 10, 50, 50);
        [_ratio1To1Button setImage:[UIImage imageNamed:BTN_RATIO_11_DARK] forState:UIControlStateNormal];
        [_ratio1To1Button setImage:[UIImage imageNamed:BTN_RATIO_11_LIGHT]  forState:UIControlStateSelected];
        [_ratio1To1Button addTarget:self action:@selector(changeRatio1To1:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _ratio1To1Button;
}

-(UIButton *)ratio4To3Button {
    if (_ratio4To3Button == nil) {
        _ratio4To3Button = [UIButton buttonWithType:UIButtonTypeCustom];
        _ratio4To3Button.frame = CGRectMake(60, 10, 50, 50);
        [_ratio4To3Button setImage:[UIImage imageNamed:BTN_RATIO_34_DARK] forState:UIControlStateNormal];
        [_ratio4To3Button setImage:[UIImage imageNamed:BTN_RATIO_34_LIGHT] forState:UIControlStateSelected];
        [_ratio4To3Button addTarget:self action:@selector(changeRatio4To3:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _ratio4To3Button;
}

-(UIButton *)ratio16To9Button {
    if (_ratio16To9Button == nil) {
        _ratio16To9Button = [UIButton buttonWithType:UIButtonTypeCustom];
        _ratio16To9Button.frame = CGRectMake(120, 10, 50, 50);
        
        [_ratio16To9Button setImage:[UIImage imageNamed:BTN_RATIO_916_DARK] forState:UIControlStateNormal];
        [_ratio16To9Button setImage:[UIImage imageNamed:BTN_RATIO_916_LIGHT] forState:UIControlStateSelected];
        [_ratio16To9Button addTarget:self action:@selector(changeRatio16To9:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _ratio16To9Button;
}


@end
