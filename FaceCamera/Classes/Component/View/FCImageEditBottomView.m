//
//  FCEditSelectionView.m
//  FaceCamera
//
//  Created by  zcating on 2018/12/26.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FCImageEditBottomView.h"

#import "ConstantValue.h"

#import <Masonry/Masonry.h>

@interface FCImageEditBottomView ()

@property (nonatomic, strong) UIButton *savingButton;

@property (nonatomic, strong) UIButton *backButton;

@end

@implementation FCImageEditBottomView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.savingButton];
        [self addSubview:self.backButton];
    }
    return self;
}

- (void)updateConstraints {
    [self.savingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.equalTo(@(60));
    }];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.size.equalTo(@(40));
        make.left.equalTo(self).with.offset(40);
    }];
    [super updateConstraints];
}

#pragma mark DELEGATE

-(void)buttonDelegate:(UIButton *)sender {
    if (self.delegate == nil) {
        return;
    }
    if (sender.tag == 1) {
        [self.delegate save];
    } else if (sender.tag == 2) {
        [self.delegate back];
    } else if (sender.tag == 3) {
        
    }
}



#pragma mark - GETTER & SETTER

-(UIButton *)savingButton {
    if (_savingButton == nil) {
        _savingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_savingButton setImage:[UIImage imageNamed:BTN_SAVING_LIGHT] forState:UIControlStateNormal];
        [_savingButton setImage:[UIImage imageNamed:BTN_SAVING_LIGHT] forState:UIControlStateSelected];
        [_savingButton addTarget:self action:@selector(buttonDelegate:) forControlEvents:UIControlEventTouchUpInside];
//        _savingButton.frame = CGRectMake(0, 0, 60, 60);
        _savingButton.tag = 1;
    }
    return _savingButton;
}

-(UIButton *)backButton {
    if (_backButton == nil) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:BTN_BACK_LIGHT] forState:UIControlStateNormal];
        [_backButton setImage:[UIImage imageNamed:BTN_BACK_DARK] forState:UIControlStateSelected];
        [_backButton addTarget:self action:@selector(buttonDelegate:) forControlEvents:UIControlEventTouchUpInside];
//        _backButton.frame = CGRectMake(0, 0, 40, 40);
        _backButton.tag = 2;
    }
    return _backButton;
}

@end
