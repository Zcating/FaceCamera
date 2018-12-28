//
//  FCMainBottomView.h
//  FaceCamera
//
//  Created by  zcating on 2018/12/28.
//  Copyright © 2018 zcat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FCMainBottomViewDelegate <NSObject>

-(void)selectImageFromPhotoAlbum;

-(void)takingPhoto;

@end

@interface FCMainBottomView : UIView

@property (nonatomic, strong) id<FCMainBottomViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
