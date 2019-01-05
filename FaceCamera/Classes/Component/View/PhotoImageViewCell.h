//
//  PhotoImageViewCell.h
//  FaceCamera
//
//  Created by  zcating on 2019/1/3.
//  Copyright © 2019 zcat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoImageViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, copy) NSString *assetIdentifier;

//@property (nonatomic) BOOL selected;

@end

NS_ASSUME_NONNULL_END
