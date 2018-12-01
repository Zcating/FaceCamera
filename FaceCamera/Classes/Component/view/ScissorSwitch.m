//
//  ScissorSwitch.m
//  FaceCamera
//
//  Created by  zcating on 2018/11/7.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "ScissorSwitch.h"


IB_DESIGNABLE
@interface ScissorSwitch ()

@property (nonatomic, strong) IBInspectable UIImage *ratio1To1Image;

@property (nonatomic, strong) IBInspectable UIImage *ratio16To9Image;

@property (nonatomic, strong) IBInspectable UIImage *ratio4To3Image;

@property (nonatomic, strong) IBInspectable UIImage *roundScissorImage;

@property (nonatomic, strong) UIButton *ratio4To3Button;

@property (nonatomic, strong) UIButton *ratio16To9Button;

@property (nonatomic, strong) UIButton *ratio1To1Button;

@property (nonatomic, strong) UIButton *roundScissorButton;

@end


@implementation ScissorSwitch


- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 10;
    [self addSubview:self.ratio16To9Button];
    [self addSubview:self.ratio4To3Button];
    [self addSubview:self.ratio1To1Button];
    [self addSubview:self.roundScissorButton];
}


-(void)setRatio1To1Image:(UIImage *)ratio1To1Image {
    [self.ratio1To1Button setImage:ratio1To1Image forState:UIControlStateNormal];
}

-(void)setRatio4To3Image:(UIImage *)ratio4To3Image{
    [self.ratio4To3Button setImage:ratio4To3Image forState:UIControlStateNormal];
}

-(void)setRatio16To9Image:(UIImage *)ratio16To9Image{
    [self.ratio16To9Button setImage:ratio16To9Image forState:UIControlStateNormal];
}

-(void)setRoundScissorImage:(UIImage *)roundScissorImage {
    [self.roundScissorButton setImage:roundScissorImage forState:UIControlStateNormal];
}


-(UIButton *)ratio1To1Button {
    if (_ratio1To1Button == nil) {
        _ratio1To1Button = [UIButton buttonWithType:UIButtonTypeCustom];
        _ratio1To1Button.frame = CGRectMake(10, 10, 50, 50);
    }
    return _ratio1To1Button;
}

- (UIButton *)ratio4To3Button{
    if (_ratio4To3Button == nil) {
        _ratio4To3Button = [UIButton buttonWithType:UIButtonTypeCustom];
        _ratio4To3Button.frame = CGRectMake(60, 10, 50, 50);
    }
    return _ratio4To3Button;
}

-(UIButton *)ratio16To9Button {
    if (_ratio16To9Button == nil) {
        _ratio16To9Button = [UIButton buttonWithType:UIButtonTypeCustom];
        _ratio16To9Button.frame = CGRectMake(120, 10, 50, 50);
    }
    return _ratio16To9Button;
}


-(UIButton *)roundScissorButton {
    if (_roundScissorButton == nil) {
        _roundScissorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _roundScissorButton.frame = CGRectMake(180, 10, 50, 50);
    }
    return _roundScissorButton;
}



@end
