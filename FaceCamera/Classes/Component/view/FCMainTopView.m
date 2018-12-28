//
//  FCMainTopView.m
//  FaceCamera
//
//  Created by  zcating on 2018/12/28.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FCMainTopView.h"

#import <Masonry/Masonry.h>

@interface FCMainTopView()

@property (strong, nonatomic) UIButton *cameraSwitcher;

@property (strong, nonatomic) UIButton *resolutionSwitcher;

@property (strong, nonatomic) UIButton *settingButton;

@end

@implementation FCMainTopView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.cameraSwitcher];
        [self addSubview:self.resolutionSwitcher];
        [self prepare];
    }
    return self;
}



-(void)prepare {
    [self.resolutionSwitcher mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.equalTo(@40);
    }];
    
    [self.cameraSwitcher mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-20);
        make.centerY.equalTo(self.mas_centerY);
        make.size.equalTo(@40);
    }];
}

// MARK: PUBLIC
-(void)changeResolutionImage:(UIImage *)image {
    [self.resolutionSwitcher setImage:image forState:UIControlStateNormal];
}


-(void)buttonDelegate:(UIButton *)sender {
    if (sender.tag == 1) {
        [self.delegate switchCamera];
    } else if (sender.tag == 2) {
        [self.delegate controlResolutionSelector];
    }
}

-(UIButton *)cameraSwitcher {
    if (_cameraSwitcher == nil) {
        _cameraSwitcher = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraSwitcher setImage:[UIImage imageNamed:BTN_SWITCH_LIGHT] forState:UIControlStateNormal];
        [_cameraSwitcher setImage:[UIImage imageNamed:BTN_SWITCH_DARK] forState:UIControlStateSelected];
        [_cameraSwitcher addTarget:self action:@selector(buttonDelegate:) forControlEvents:UIControlEventTouchUpInside];
        _cameraSwitcher.tag = 1;
    }
    return _cameraSwitcher;
}

-(UIButton *)resolutionSwitcher {
    if (_resolutionSwitcher == nil) {
        _resolutionSwitcher = [UIButton buttonWithType:UIButtonTypeCustom];
        [_resolutionSwitcher setImage:[UIImage imageNamed:@"btn_camera_ratio_916_light"] forState:UIControlStateNormal];
        [_resolutionSwitcher addTarget:self action:@selector(buttonDelegate:) forControlEvents:UIControlEventTouchUpInside];
        _resolutionSwitcher.tag = 2;
    }
    return _resolutionSwitcher;
}

@end
