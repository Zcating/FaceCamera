//
//  FCImageEditingViewController.m
//  FaceCamera
//
//  Created by  zcating on 2018/12/22.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FCImageEditingViewController.h"

#import "FCEditSelectionView.h"

#import "ConstantValue.h"

@interface FCImageEditingViewController ()<FCEditSelectionDelegate>

@property (nonatomic, strong) FCEditSelectionView *selectionView;


@end

@implementation FCImageEditingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.selectionView];
//    [self.selectionView prepare];
}


// MARK: - DELEGATE
-(void)save {
    
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

-(FCEditSelectionView *)selectionView {
    if (_selectionView == nil) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        _selectionView = [[FCEditSelectionView alloc] initWithFrame:CGRectMake(0, screenSize.height - 100, screenSize.width, 100)];
        _selectionView.delegate = self;
    }
    return _selectionView;
}

- (void)setType:(FCResolutionType)type {
    _type = type;
    self.imageView.frame =  [GlobalUtils getRectFromResolutionType:_type size:[UIScreen mainScreen].bounds.size];
}

@end
