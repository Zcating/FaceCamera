//
//  FCCoreVisualService.h
//  FaceCamera
//
//  Created by  zcating on 2018/11/10.
//  Copyright © 2018 zcat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FCCoreVisualService : NSObject

- (void)runWithSampleBuffer:(CMSampleBufferRef)sampleBuffer inRects:(NSArray<NSValue *> *)faces;

@end

NS_ASSUME_NONNULL_END
