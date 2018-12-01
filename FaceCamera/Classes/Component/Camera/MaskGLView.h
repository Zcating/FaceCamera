//
//  MaskGLView.h
//  FaceCamera
//
//  Created by  zcating on 2018/11/28.
//  Copyright © 2018 zcat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

// vertex data
typedef struct {
    double position[3];
    double uv[2];
} VertexData;

// whole mask points
struct MaskMap {
   cv::Point_<double> point68;
   cv::Point_<double> point69;
   cv::Point_<double> point70;
   cv::Point_<double> point71;
   cv::Point_<double> point72;
   cv::Point_<double> point73;
   cv::Point_<double> point74;
   cv::Point_<double> point75;
   cv::Point_<double> prevPoint36;
   cv::Point_<double> prevPoint45;
   cv::Point_<double> curPoint36;
   cv::Point_<double> curPoint45;
};


struct LandmarkInfo {
    double curDistOf36and45;
    double curAngleOf36and45;
    double angleOfIndexand36;
    double distOfIndexand36;
    double angleChanged;
};

@interface MaskGLView : GLKView

@end

NS_ASSUME_NONNULL_END
