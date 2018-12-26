//
//  FCImageEditingViewController.m
//  FaceCamera
//
//  Created by  zcating on 2018/12/22.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FCImageEditingViewController.h"

#import "ConstantValue.h"

@interface FCImageEditingViewController ()

@property (nonatomic, strong) UIButton *savingButton;

@property (nonatomic, strong) UIButton *backButton;

@end

@implementation FCImageEditingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.savingButton];
    [self.view addSubview:self.backButton];
    
}


// MARK: - DELEGATE
-(void)back:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}


// MARK: - GETTER & SETTER
-(UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _imageView;
}

-(UIButton *)backButton {
    if (_backButton == nil) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:BTN_BACK_LIGHT] forState:UIControlStateNormal];
        [_backButton setImage:[UIImage imageNamed:BTN_BACK_DARK] forState:UIControlStateSelected];
        [_backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        CGRect frame = [[UIScreen mainScreen] bounds];
        CGFloat x = 40;
        CGFloat y = frame.size.height - 30 - 40;
        _backButton.frame = CGRectMake(x, y, 50, 50);
    }
    return _backButton;
}

-(UIButton *)savingButton {
    if (_savingButton == nil) {
        _savingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_savingButton setImage:[UIImage imageNamed:BTN_SAVING_LIGHT] forState:UIControlStateNormal];
        [_savingButton setImage:[UIImage imageNamed:BTN_SAVING_LIGHT] forState:UIControlStateSelected];
        
        CGRect frame = [[UIScreen mainScreen] bounds];
        CGFloat x = CGRectGetMidX(frame) - 40;
        CGFloat y = frame.size.height - 30 - 80;
        _savingButton.frame = CGRectMake(x, y, 80, 80);
    }
    return _savingButton;
}


- (void)setType:(FCResolutionType)type {
    _type = type;
    self.imageView.frame =  [GlobalUtils getRectFromResolutionType:_type size:[UIScreen mainScreen].bounds.size];
}

@end
