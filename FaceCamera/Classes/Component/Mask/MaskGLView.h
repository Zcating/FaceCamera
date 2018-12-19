//
//  MaskGLView.h
//  FaceCamera
//
//  Created by  zcating on 2018/11/28.
//  Copyright © 2018 zcat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

struct LandmarkInfo {
    float curDistOf36And45;
    float curAngleOf36And45;
    float angleOfIndexAnd36;
    float distOfIndexAnd36;
    float angleChanged;
};

struct VertexData{
    float position[3];
    float uv[2];
};


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
        //    struct CGPoint point68;
        //    struct CGPoint point69;
        //    struct CGPoint point70;
        //    struct CGPoint point71;
        //    struct CGPoint point72;
        //    struct CGPoint point73;
        //    struct CGPoint point74;
        //    struct CGPoint point75;
        //    struct CGPoint prevPoint36;
        //    struct CGPoint prevPoint45;
        //    struct CGPoint curPoint36;
        //    struct CGPoint curPoint45;
        //

};

@interface MaskGLView : GLKView {
    CGFloat _ratio;
}

@property (nonatomic) FCResolutionType type;


- (void)updateLandmarks:(const std::vector<cv::Point_<double>> &)shape faceIndex:(long)faceIndex;


- (void)setupVBOs:(NSString *)imageName withLandmarkArray:(NSArray *)landmaskArray;

@end
