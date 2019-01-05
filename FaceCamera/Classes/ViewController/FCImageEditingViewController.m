//
//  FCImageEditingViewController.m
//  FaceCamera
//
//  Created by  zcating on 2018/12/22.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FCImageEditingViewController.h"

#import "FCImageEditBottomView.h"
#import "FCCoreEditService.h"
#import "ConstantValue.h"

#import <Photos/Photos.h>
#import <Masonry/Masonry.h>

@interface FCImageEditingViewController ()<FCImageEditBottomViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) FCImageEditBottomView *bottomView;

@property (nonatomic, strong) FCCoreEditService *service;

@end

@implementation FCImageEditingViewController

#pragma mark - PUBLIC
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.bottomView];
}

-(void)updateViewConstraints {
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(0);
        make.left.equalTo(self.view).offset(0);
        make.right.equalTo(self.view).offset(0);
        make.height.equalTo(@([UIScreen mainScreen].bounds.size.height * 1 / 4));
    }];
    [super updateViewConstraints];
}

#pragma mark - DELEGATE
-(void)save {
    [self.service saveImage:self.imageView.image];
}

-(void)edit {
    
}

-(void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}




#pragma mark - GETTER & SETTER
-(UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _imageView;
}

-(FCImageEditBottomView *)bottomView {
    if (_bottomView == nil) {
        _bottomView = [[FCImageEditBottomView alloc] initWithFrame:CGRectZero];
        _bottomView.delegate = self;
    }
    return _bottomView;
}

- (void)setType:(FCResolutionType)type {
    _type = type;
    self.imageView.frame = [GlobalUtils getRectFromResolutionType:_type size:[UIScreen mainScreen].bounds.size];
}

-(FCCoreEditService *)service {
    if (_service == nil) {
        _service = [FCCoreEditService new];
    }
    return _service;
}

-(UIImage *)image {
    return self.imageView.image;
}

-(void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

@end
