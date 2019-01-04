//
//  FCMainBottomViewController.m
//  FaceCamera
//
//  Created by  zcating on 2019/1/1.
//  Copyright © 2019 zcat. All rights reserved.
//

#import "FCMainBottomViewController.h"

#import "FCMaskCell.h"

#import <Masonry/Masonry.h>

@interface FCMainBottomViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UIButton *shutterButton;

@property (strong, nonatomic) UIButton *albumButton;

@property (strong, nonatomic) UIButton *stickerButton;

@property (strong, nonatomic) UICollectionView *stickerView;

@property (nonatomic) BOOL showStickView;
@end

@implementation FCMainBottomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.stickerButton];
    [self.view addSubview:self.albumButton];
    [self.view addSubview:self.stickerView];
    [self.view addSubview:self.shutterButton];
    
    [self prepare];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(concealStickerSelector:)];
    tap.cancelsTouchesInView = NO;
    [self.parentViewController.view addGestureRecognizer:tap];
}

-(void)updateViewConstraints {
    [self.shutterButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.showStickView) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.centerY.equalTo(self.view.mas_centerY).offset(30);
            make.size.equalTo(@40);
        } else {
            make.center.equalTo(self.view);
            make.size.equalTo(@60);
        }
    }];
    [self.stickerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.view);
        if (self.showStickView) {
            make.top.equalTo(self.view.mas_top);
        } else {
            make.top.equalTo(self.view.mas_bottom);
        }
        make.left.equalTo(self.view).offset(0);
    }];
    [super updateViewConstraints];
}

// MARK: - PRIVATE
-(void)prepare {
    [self.albumButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        make.left.equalTo(self.view).offset(20);
        make.size.equalTo(@30);
    }];
    
    [self.stickerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        make.left.equalTo(self.albumButton).offset(20);
        make.size.equalTo(@30);
    }];
}


// MARK: - DELEGATE
-(void)buttonDelegate:(UIButton *)sender {
    if (sender.tag == 1) {
        [self.delegate takingPhoto];
    } else if (sender.tag == 2) {
        [self.delegate selectImageFromPhotoAlbum];
    }
}

-(void)showStickerSelector:(UIButton *)sender {
    self.showStickView = YES;
    [self updateViewConstraints];
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void)concealStickerSelector:(UITapGestureRecognizer *)sender {
    self.showStickView = NO;
    [self updateViewConstraints];
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

// UICollection View delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FCMaskCell *cell = (FCMaskCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"STICKER_CELL" forIndexPath:indexPath];
    cell.image = [UIImage imageNamed:@"nose_001"];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(60, 60);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

// Horizontal
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

// Vertical
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"VIEW" forIndexPath:indexPath];
    headerView.backgroundColor =[UIColor grayColor];
    UILabel *label = [[UILabel alloc] initWithFrame:headerView.bounds];
    label.text = @"header";
    label.font = [UIFont systemFontOfSize:20];
    [headerView addSubview:label];
    return headerView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    FCMaskCell *cell = (FCMaskCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
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

-(UIButton *)albumButton {
    if (_albumButton == nil) {
        _albumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_albumButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_albumButton addTarget:self action:@selector(buttonDelegate:) forControlEvents:UIControlEventTouchUpInside];
        _albumButton.tag = 2;
    }
    return _albumButton;
}

-(UIButton *)stickerButton {
    if (_stickerButton == nil) {
        _stickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_stickerButton setTitle:@"fuck" forState:UIControlStateNormal];
        [_stickerButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [_stickerButton addTarget:self action:@selector(showStickerSelector:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stickerButton;
}

-(UICollectionView *)stickerView {
    if (_stickerView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 20);
        layout.itemSize = CGSizeMake(60, 60);
        _stickerView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _stickerView.backgroundColor = [UIColor clearColor];
        _stickerView.delegate = self;
        _stickerView.dataSource = self;
        [_stickerView registerClass:[FCMaskCell class] forCellWithReuseIdentifier:@"STICKER_CELL"];
        [_stickerView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"VIEW"];
    }
    return _stickerView;
}



@end
