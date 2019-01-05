//
//  FCAlbumViewController.h
//  FaceCamera
//
//  Created by  zcating on 2019/1/1.
//  Copyright © 2019 zcat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CloseBlock)(void);

@interface FCAlbumViewController : UIViewController

@property (nonatomic, copy) CloseBlock close;

@end


NS_ASSUME_NONNULL_END
