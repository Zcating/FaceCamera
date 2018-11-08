//
//  ShutterView.m
//  FaceCamera
//
//  Created by  zcating on 2018/9/3.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "ShutterView.h"


IB_DESIGNABLE
@interface ShutterView()

@property (nonatomic, strong) UIButton *shutterButton;

@property (nonatomic, strong) UIButton *downloadButton;

@property (nonatomic, copy) ShutterBlock block;

@property (nonatomic) IBInspectable CGRect ShutterFrame;

@end


@implementation ShutterView

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self addSubview:self.shutterButton];
}



-(UIButton *)shutterButton {
    if (_shutterButton == nil) {
        _shutterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shutterButton addTarget:self action:@selector(press:) forControlEvents:UIControlEventTouchUpInside];
        
        _shutterButton.layer.cornerRadius = 10;
        _shutterButton.layer.borderColor = [UIColor redColor].CGColor;
        _shutterButton.layer.borderWidth = 5;
        
    }
    
    return _shutterButton;
}


-(void)pressShutter:(ShutterBlock)block {
    self.block = block;
}

-(void)press:(UIButton *)button {
    if (self.block != nil) {
        self.block();
    }
}


-(CGRect)shutterFrame {
    return self.shutterButton.frame;
}

- (void)setShutterFrame:(CGRect)ShutterFrame {
    self.shutterButton.frame = ShutterFrame;
}



@end
