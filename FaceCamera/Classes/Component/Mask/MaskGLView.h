//
//  MaskGLView.h
//  FaceCamera
//
//  Created by  zcating on 2018/11/28.
//  Copyright © 2018 zcat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface MaskGLView : GLKView

- (void)updateLandmarks:(const std::vector<cv::Point_<double>> &)shape faceIndex:(long)faceIndex;

- (void)prepare;

- (void)setupImage:(NSString *)imageName landmarks:(NSArray *)landmarks;

@end
