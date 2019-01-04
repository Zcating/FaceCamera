//
//  FCAlbumTopView.m
//  FaceCamera
//
//  Created by  zcating on 2019/1/4.
//  Copyright © 2019 zcat. All rights reserved.
//

#import "FCAlbumTopView.h"

#import <Masonry/Masonry.h>

@interface FCAlbumTopView ()

@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation FCAlbumTopView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.closeButton];
    }
    return self;
}


// MARK: - PUBLIC

-(void)updateConstraints {
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self).offset(10);
        make.size.equalTo(@20);
    }];
    [super updateConstraints];
}

// MARK: - PRIVATE

// MARK: - DELEGATE
-(void)buttonDelegate:(UIButton *)sender {
    if (self.close) {
        self.close();
    }
}

// MARK: - GETTER & SETTER

-(UIButton *)closeButton {
    if (_closeButton == nil) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:BTN_CLOSE] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(buttonDelegate:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

@end
