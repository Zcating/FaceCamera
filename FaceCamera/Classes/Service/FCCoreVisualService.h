//
//  FCCoreVisualService.h
//  FaceCamera
//
//  Created by  zcating on 2018/11/10.
//  Copyright © 2018 zcat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^LandmarkBlock)(const std::vector<cv::Point_<double>>& landmarks, long faceIndex);

typedef void(^SnapshotBlock)(UIImage *image);

@interface FCCoreVisualService : NSObject

- (void)runWithSampleBuffer:(CMSampleBufferRef)sampleBuffer inRects:(NSArray<NSValue *> *)faces forLandmarkBlock:(LandmarkBlock)landmarkBlock;

-(void)generateImageWithMask:(UIImage *)mask resolutionType:(FCResolutionType)type inBlock:(SnapshotBlock)block;

@end

NS_ASSUME_NONNULL_END
