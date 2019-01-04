//
//  FCMainBottomViewController.h
//  FaceCamera
//
//  Created by  zcating on 2019/1/1.
//  Copyright © 2019 zcat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol FCMainBottomViewDelegate <NSObject>

-(void)selectImageFromPhotoAlbum;

-(void)takingPhoto;

-(void)selectSticker:(id)sticker;

@end

@interface FCMainBottomViewController : UIViewController

@property (nonatomic, strong) id<FCMainBottomViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
