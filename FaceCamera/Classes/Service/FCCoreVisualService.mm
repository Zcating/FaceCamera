//
//  FCCoreVisualService.m
//  FaceCamera
//
//  Created by  zcating on 2018/11/10.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FCCoreVisualService.h"
#import "FaceCore.hpp"
#import "ImageProcession.hpp"


@interface FCCoreVisualService () {
//    dlib::shape_predictor _shapePredictor;
    fc::FaceCore _faceCore;
}

@property (nonatomic, copy) SnapshotBlock snapshotBlock;

@property (nonatomic) BOOL enableSnapshot;

@property (nonatomic) FCResolutionType resolutionType;

@property (nonatomic, strong) UIImage *mask;

@end

@implementation FCCoreVisualService

- (instancetype)init {
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}


- (void)prepare {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"shape_predictor_68_face_landmarks" ofType:@"dat"];
    _faceCore.prepare([path UTF8String]);
}


- (void)runWithSampleBuffer:(CMSampleBufferRef)sampleBuffer inRects:(NSArray<NSValue *> *)faces forLandmarkBlock:(LandmarkBlock)landmarkBlock {
    // get all pixels in the frame.
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);

    cv::Mat image = fc::PixelBufferToCvMat(pixelBuffer);
    
    [faces enumerateObjectsUsingBlock:^(NSValue * _Nonnull value, NSUInteger index, BOOL * _Nonnull stop) {
        CGRect rectValue = value.CGRectValue;
        
        cv::Rect faceRect(rectValue.origin.x, rectValue.origin.y, rectValue.size.width, rectValue.size.height);
        
        auto cvLandmarks = self->_faceCore.landmarks(image, faceRect);
        landmarkBlock(cvLandmarks, index);
        
        // Draw all 68 point.
#ifdef FC_DEBUG
        cv::rectangle(image, faceRect.tl(), faceRect.br(), cv::Scalar(0, 0, 255, 255), 2);
        
        for (auto index = 0; index < landmarks.num_parts(); index++) {
            auto p = landmarks.part(index);
            cv::Point point(static_cast<int>(p.x()), static_cast<int>(p.y()));
            cv::circle(image, point, 2, cv::Scalar(255, 255, 0, 0));
        }
#endif
    }];
    
    fc::SaveCvMatToPixelBuffer(image, pixelBuffer);
    
    if(self.enableSnapshot) {
        [self startSnapshot:image];
        self.enableSnapshot = NO;
    }
}

-(void)generateImageWithMask:(UIImage *)mask resolutionType:(FCResolutionType)type inBlock:(SnapshotBlock)block {
    self.enableSnapshot = YES;
    self.mask = mask;
    self.resolutionType = type;
    self.snapshotBlock = block;
}



-(void)startSnapshot:(cv::Mat &)mat {
    if(!self.snapshotBlock) {
        return;
    }
    
    cv::Mat convertedMat;
    cv::cvtColor(mat, convertedMat, CV_BGRA2RGBA);
    UIImage *image = fc::MatToUIImage(convertedMat);
    UIGraphicsBeginImageContextWithOptions(image.size, FALSE, 0.0);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    [self.mask drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();

    CGSize size = CGSizeMake(CGImageGetWidth(result.CGImage), CGImageGetHeight(result.CGImage));
    CGRect rect = [GlobalUtils getRectFromResolutionType:self.resolutionType size:size];
    CGImageRef cgImageRef = CGImageCreateWithImageInRect(result.CGImage, rect);
    UIImage *cutting = [UIImage imageWithCGImage:cgImageRef];
    CGImageRelease(cgImageRef);
    
    UIGraphicsEndImageContext();
    
    
    self.snapshotBlock(cutting);
    self.snapshotBlock = nil;
    self.mask = nil;
}


@end

