//
//  GlobalUtils.m
//  FaceCamera
//
//  Created by  zcating on 2018/12/25.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "GlobalUtils.h"

@implementation GlobalUtils

+ (CGRect)getRectFromResolutionType:(FCResolutionType)type size:(CGSize)standardSize {
    CGRect result;
    switch (type) {
        case FCResolutionType11: {
            CGFloat y = (standardSize.height - standardSize.width) / 2;
            result = CGRectMake(0, y, standardSize.width, standardSize.width);
            break;
        }
        case FCResolutionType34: {
            result = CGRectMake(0, 0, standardSize.width, standardSize.height * 3 / 4);
            break;
        }
        case FCResolutionType916: {
            result = CGRectMake(0, 0, standardSize.width, standardSize.height);
            break;
        }
    }
    return result;
}

@end
