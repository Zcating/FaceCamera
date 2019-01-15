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
        dlib::shape_predictor shapePredictor;
        
        inline dlib::rectangle convertCVRect(const cv::Rect& rect) {
            auto tl = rect.tl();
            auto br = rect.br();
            
            long left = tl.x;
            long top = tl.y;
            long right = br.x;
            long bottom = br.y;
            
            return dlib::rectangle(left, top, right, bottom);
        }
        
    public:
        FaceCore() {};
        ~FaceCore() {};
        
        void prepare(const char *path) {
            dlib::deserialize(path) >> shapePredictor;
        }
        
        void prepare(const std::string& path) {
            dlib::deserialize(path) >> shapePredictor;
        }
 
        std::vector<cv::Point_<double>> landmarks(const cv::Mat &image, const cv::Rect &rect) {
            auto landmarks = shapePredictor(dlib::cv_image<dlib::rgb_alpha_pixel>(image), convertCVRect(rect));
            std::vector<cv::Point_<double>> cvLandmarks(landmarks.num_parts(), cv::Point(0, 0));
            for (auto index = 0; index < landmarks.num_parts(); index++) {
                const auto& landmark = landmarks.part(index);
                auto& point = cvLandmarks[index];
                point.x = static_cast<double>(landmark.x());
                point.y = static_cast<double>(landmark.y());
            }
            return cvLandmarks;
        };
    };
}

#endif /* FaceUtil_hpp */
