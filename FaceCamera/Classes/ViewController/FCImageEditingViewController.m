//
//  FCImageEditingViewController.m
//  FaceCamera
//
//  Created by  zcating on 2018/12/22.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FCImageEditingViewController.h"

#import "FCImageEditBottomView.h"

#import "ConstantValue.h"

#import <Photos/Photos.h>
#import <Masonry/Masonry.h>

@interface FCImageEditingViewController ()<FCImageEditBottomViewDelegate>

@property (nonatomic, strong) FCImageEditBottomView *bottomView;

@end

@implementation FCImageEditingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.bottomView];
//    [self.selectionView prepare];
    [self prepare];
}

-(void)prepare {
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(0);
        make.left.equalTo(self.view).offset(0);
        make.right.equalTo(self.view).offset(0);
        make.height.equalTo(@100);
    }];
}

// MARK: - DELEGATE
-(void)save {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
    
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
    }];
}

-(void)edit {
    
}

-(void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}




// MARK: - GETTER & SETTER
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
    self.imageView.frame =  [GlobalUtils getRectFromResolutionType:_type size:[UIScreen mainScreen].bounds.size];
}

@end
