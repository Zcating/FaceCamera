//
//  FCMainBottomView.m
//  FaceCamera
//
//  Created by  zcating on 2018/12/28.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FCMainBottomView.h"

#import "ConstantValue.h"

#import <Masonry/Masonry.h>

@interface FCMainBottomView()

@property (strong, nonatomic) UIButton *shutterButton;

@end

@implementation FCMainBottomView

// MARK: - CONSTRUCTOR

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.shutterButton];
//        [self addSubview:self.backButton];
        [self prepare];
        
    }
    return self;
}

// MARK: - PRIVATE
-(void)prepare {
    [self.shutterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.equalTo(@60);
    }];
}

// MARK: - PUBLIC


// MARK: - DELEGATE
-(void)buttonDelegate:(UIButton *)sender {
    if (sender.tag == 1) {
        [self.delegate takingPhoto];
    } else if (sender.tag == 2) {
        [self.delegate selectImageFromPhotoAlbum];
    }
}

// MARK: - GETTER & SETTER
-(UIButton *)shutterButton {
    if (_shutterButton == nil) {
        _shutterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shutterButton setImage:[UIImage imageNamed:BTN_PHOTO_TAKING_LIGHT] forState:UIControlStateNormal];
        [_shutterButton setImage:[UIImage imageNamed:BTN_PHOTO_TAKING_DARK] forState:UIControlStateSelected];
        [_shutterButton addTarget:self action:@selector(buttonDelegate:) forControlEvents:UIControlEventTouchUpInside];
        _shutterButton.tag = 1;
    }
    return _shutterButton;
}

@end
