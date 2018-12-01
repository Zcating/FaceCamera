//
//  FaceUtil.hpp
//  FaceCamera
//
//  Created by  zcating on 2018/11/12.
//  Copyright © 2018 zcat. All rights reserved.
//

#ifndef FaceUtil_hpp
#define FaceUtil_hpp

#include <opencv2/opencv.hpp>


namespace fc {
    class FaceCore {
    private:
//        static cv::Mat white;
        cv::Mat image;
        cv::Rect rect;
        std::vector<cv::Point> landmarks;

        
    public:
        FaceCore(int width, int height) {
        };
        
        ~FaceCore() {};
        
        
        FaceCore& prepare(const cv::Mat& im3age, const std::vector<cv::Point>& landmarks, const cv::Rect& rect);
        
        FaceCore& thinFace(double strenth);
        
        FaceCore& overlayImage(cv::Mat& target);
        
        FaceCore& delaunaryTriangles();
        
        FaceCore& drawLip();
    };
}

#endif /* FaceUtil_hpp */
