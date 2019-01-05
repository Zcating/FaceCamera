//
//  FCAlbumViewController.m
//  FaceCamera
//
//  Created by  zcating on 2019/1/1.
//  Copyright © 2019 zcat. All rights reserved.
//

#import "FCAlbumViewController.h"

#import "FCAlbumTopView.h"
#import "PhotoImageViewCell.h"



#import <Masonry/Masonry.h>
#import <Photos/Photos.h>


@interface FCAlbumViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) FCAlbumTopView *topView;

@property (nonatomic, strong) PHCachingImageManager *imageManager;

@property (nonatomic, strong) PHFetchResult<PHAsset *> *fetchResult;

@property (nonatomic, strong) PHAssetCollection *assetCollection;

@property (nonatomic, strong) UICollectionView *photosView;

@property (nonatomic, strong) UICollectionViewFlowLayout *photosViewFlowLayout;

@property (nonatomic) CGSize cellImageSize;

@end

@implementation FCAlbumViewController

#pragma mark - PUBLIC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    self.cellImageSize = CGSizeMake(self.photosViewFlowLayout.itemSize.width * scale, self.photosViewFlowLayout.itemSize.height * scale);
    
    [self.view addSubview:self.photosView];
    [self.view addSubview:self.topView];

    [self prepare];
}



#pragma mark - PRIVATE
-(void)prepare {
    [self.photosView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(50, 0, 0, 0));
    }];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(0);
        make.left.equalTo(self.view).offset(0);
        make.width.equalTo(self.view.mas_width);
        make.height.equalTo(@50);
    }];
}

#pragma mark - DELEGATE

// UICollection View delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoImageViewCell *cell = (PhotoImageViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PHOTO_CELL" forIndexPath:indexPath];

    PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.item];
    cell.assetIdentifier = asset.localIdentifier;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:self.cellImageSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if ([cell.assetIdentifier isEqualToString:asset.localIdentifier]) {
            cell.image = result;
        }
    }];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma mark - GETTER & SETTER

-(PHFetchResult<PHAsset *> *)fetchResult {
    if (_fetchResult == nil) {
        // Get all photos
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[[NSSortDescriptor alloc]initWithKey:@"creationDate" ascending:NO]];
        _fetchResult = [PHAsset fetchAssetsWithOptions:options];
    }
    return _fetchResult;
}

-(FCAlbumTopView *)topView {
    if (_topView == nil) {
        _topView = [[FCAlbumTopView alloc] initWithFrame:CGRectZero];
    }
    return _topView;
}

-(UICollectionView *)photosView {
    if (_photosView == nil) {
        _photosView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.photosViewFlowLayout];
        _photosView.backgroundColor = [UIColor clearColor];
        _photosView.delegate = self;
        _photosView.dataSource = self;
        [_photosView registerClass:[PhotoImageViewCell class] forCellWithReuseIdentifier:@"PHOTO_CELL"];
        [_photosView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"VIEW"];
    }
    return _photosView;
}

-(UICollectionViewFlowLayout *)photosViewFlowLayout {
    if (_photosViewFlowLayout == nil) {
        _photosViewFlowLayout = [UICollectionViewFlowLayout new];
        // vertical
        _photosViewFlowLayout.minimumInteritemSpacing = 2;
        // horizontal
        _photosViewFlowLayout.minimumLineSpacing = 1;
        
        CGFloat width = ([UIScreen mainScreen].bounds.size.width - 4) / 3;
        _photosViewFlowLayout.itemSize = CGSizeMake(width, width);
    }
    return _photosViewFlowLayout;
}

-(CloseBlock)close {
    return self.topView.close;
}

-(void)setClose:(CloseBlock)close {
    self.topView.close = close;
}

@end

