//
//  FaceDetector.h
//  FaceCamera
//
//  Created by  zcating on 2018/8/20.
//  Copyright © 2018 zcat. All rights reserved.
//


@interface FaceDetector : NSObject

+(instancetype)shared;

-(void)detectOn:(CMSampleBufferRef)sampleBuffer inRects:(NSArray<NSValue *> *)rects;

-(void)faceLandmarkDetectOn:(CMSampleBufferRef)sampleBuffer inRects:(NSArray<NSValue *> *)rects landmarkResult:(void(^)(long index, CGPoint point))landmarkResult;


@end
