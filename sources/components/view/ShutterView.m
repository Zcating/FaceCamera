//
//  ShutterView.m
//  FaceCamera
//
//  Created by  zcating on 2018/9/3.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "ShutterView.h"

@interface ShutterView()

@property (nonatomic, strong) UIButton *shutterButton;

@property (nonatomic, strong) UIButton *downloadButton;

@property (nonatomic, copy) ShutterBlock block;

@end


@implementation ShutterView

-(void)drawRect:(CGRect)rect {
    [self addSubview:self.shutterButton];
    [self addSubview:self.downloadButton];
}



-(UIButton *)shutterButton {
    if (_shutterButton == nil) {
        _shutterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shutterButton addTarget:self action:@selector(press:) forControlEvents:UIControlEventTouchUpInside];
        
        _shutterButton.frame = CGRectMake(0, 0, 100, 100);
//        _shutterButton.center = self.center;
        [_shutterButton setTitle:@"click me" forState:UIControlStateNormal];
        
        
        _shutterButton.layer.masksToBounds  = YES;
        _shutterButton.layer.cornerRadius   = 5;
        _shutterButton.layer.borderWidth    = 2;
        _shutterButton.layer.borderColor    = [UIColor redColor].CGColor;
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





@end
