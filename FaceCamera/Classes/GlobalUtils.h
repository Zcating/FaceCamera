//
//  GlobalUtils.h
//  FaceCamera
//
//  Created by  zcating on 2018/12/25.
//  Copyright © 2018 zcat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GlobalUtils : NSObject
+ (CGRect)getRectFromResolutionType:(FCResolutionType)type size:(CGSize)standardSize;
@end

NS_ASSUME_NONNULL_END
