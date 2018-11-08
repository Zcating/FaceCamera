//
//  FaceDetector.h
//  FaceCamera
//
//  Created by  zcating on 2018/8/20.
//  Copyright © 2018 zcat. All rights reserved.
//


@protocol FaceDetector <NSObject>

@optional
-(NSArray *)detectFacesByFrame:(CMSampleBufferRef)sampleBuffer;



@end
