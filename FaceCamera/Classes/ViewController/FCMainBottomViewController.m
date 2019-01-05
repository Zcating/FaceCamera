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
#import <Photos/Photos.h>

@interface FCMainBottomViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIButton *shutterButton;

@property (strong, nonatomic) UIButton *albumButton;

@property (strong, nonatomic) UIButton *stickerButton;

@property (strong, nonatomic) UICollectionView *stickersView;

@property (strong, nonatomic) PHAsset *asset;

@property (nonatomic) BOOL showSticksView;

@end

@implementation FCMainBottomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.stickerButton];
    [self.view addSubview:self.albumButton];
    [self.view addSubview:self.stickersView];
    [self.view addSubview:self.shutterButton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(concealStickerSelector:)];
    tap.delegate = self;
    [self.parentViewController.view addGestureRecognizer:tap];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    [[PHImageManager defaultManager] requestImageForAsset:self.asset targetSize:CGSizeMake(20 * scale, 20 * scale) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        [self.albumButton setImage:result forState:UIControlStateNormal];
    }];
}

-(void)updateViewConstraints {
    [self.albumButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.showSticksView) {
            make.centerY.equalTo(self.view).offset(30);
            make.size.equalTo(@20);
        } else {
            make.centerY.equalTo(self.view);
            make.size.equalTo(@30);
        }
        make.centerX.equalTo(self.view.mas_left).offset(40);
    }];
    
    [self.stickerButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.showSticksView) {
            make.centerY.equalTo(self.view).offset(30);
            make.size.equalTo(@20);
        } else {
            make.centerY.equalTo(self.view);
            make.size.equalTo(@30);
        }
        make.centerX.equalTo(self.view.mas_left).offset(100);
    }];
    
    [self.shutterButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.showSticksView) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.centerY.equalTo(self.view.mas_centerY).offset(30);
            make.size.equalTo(@40);
        } else {
            make.center.equalTo(self.view);
            make.size.equalTo(@60);
        }
    }];
    
    [self.stickersView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.view);
        if (self.showSticksView) {
            make.top.equalTo(self.view.mas_top);
        } else {
            make.top.equalTo(self.view.mas_bottom);
        }
        make.left.equalTo(self.view).offset(0);
    }];
    [super updateViewConstraints];
}

#pragma mark - PRIVATE


#pragma mark - DELEGATE
-(void)buttonDelegate:(UIButton *)sender {
    if (sender.tag == 1) {
        [self.delegate takingPhoto];
    } else if (sender.tag == 2) {
        [self.delegate selectImageFromPhotoAlbum];
    }
}

-(void)showStickerSelector:(UIButton *)sender {
    self.showSticksView = YES;
    [self updateViewConstraints];
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
        self.stickerButton.alpha = 0;
        self.albumButton.alpha = 0;
    }];
}

-(void)concealStickerSelector:(UITapGestureRecognizer *)sender {
    self.showSticksView = NO;
    [self updateViewConstraints];
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
        self.stickerButton.alpha = 1;
        self.albumButton.alpha = 1;
    }];
}

// UICollection View delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FCMaskCell *cell = (FCMaskCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"STICKER_CELL" forIndexPath:indexPath];
    cell.name = @"mouth";
    cell.image = [UIImage imageNamed:@"mouth"];
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FCMaskCell *cell = (FCMaskCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selected = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectSticker:)]) {
        [self.delegate selectSticker:cell.name];
    }
}

//  Gesture Recognizer Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.view]) {
        return NO;
    }
    return YES;
}

#pragma mark - GETTER & SETTER

-(PHAsset *)asset {
    if (_asset == nil) {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO]];
        // Get the newest photos
        _asset = [[PHAsset fetchAssetsWithOptions:options] objectAtIndex:0];
    }
    return _asset;
}


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
        [_albumButton addTarget:self action:@selector(buttonDelegate:) forControlEvents:UIControlEventTouchUpInside];
        _albumButton.tag = 2;
    }
    return _albumButton;
}

-(UIButton *)stickerButton {
    if (_stickerButton == nil) {
        _stickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_stickerButton setImage:[UIImage imageNamed:BTN_SHOW_STICKERS] forState:UIControlStateNormal];
        [_stickerButton addTarget:self action:@selector(showStickerSelector:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _stickerButton;
}

-(UICollectionView *)stickersView {
    if (_stickersView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 20);
        layout.itemSize = CGSizeMake(60, 60);
        _stickersView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _stickersView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.3];
        _stickersView.delegate = self;
        _stickersView.dataSource = self;
        [_stickersView registerClass:[FCMaskCell class] forCellWithReuseIdentifier:@"STICKER_CELL"];
    }
    return _stickersView;
}



@end
