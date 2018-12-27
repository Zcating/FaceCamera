//
//  FCEditSelectionView.h
//  FaceCamera
//
//  Created by  zcating on 2018/12/26.
//  Copyright © 2018 zcat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FCEditSelectionDelegate <NSObject>

-(void)save;

-(void)edit;

-(void)back;

@end

@interface FCEditSelectionView : UIView

@property (nonatomic, weak) id<FCEditSelectionDelegate> delegate;


-(void)prepare;

@end

NS_ASSUME_NONNULL_END
