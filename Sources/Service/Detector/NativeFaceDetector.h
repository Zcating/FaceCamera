//
//  NativeFaceDetector.h
//  FaceCamera
//
//  Created by  zcating on 2018/10/27.
//  Copyright © 2018 zcat. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FaceDetector.h"

NS_ASSUME_NONNULL_BEGIN


@interface NativeFaceDetector : NSObject<
FaceDetector,
AVCaptureMetadataOutputObjectsDelegate>



-(NSArray *)detectFaceByAVCaptureOutput:(AVCaptureOutput *)output fromConnection:(AVCaptureConnection *)connection;
//-(void)faceLandmarkDetectOn:(CMSampleBufferRef)sampleBuffer inRects:(NSArray<NSValue *> *)rects landmarkResult:(void(^)(long index, CGPoint point))landmarkResult;

@end

NS_ASSUME_NONNULL_END
