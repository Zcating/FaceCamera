//
//  FaceLandmarkDetector.hpp
//  FaceCamera
//
//  Created by  zcating on 2018/9/18.
//  Copyright © 2018 zcat. All rights reserved.
//

#ifndef FaceDetector_hpp
#define FaceDetector_hpp

#include <vector>
#include <string>
#import <dlib/image_processing.h>
#import <dlib/image_io.h>

#import <opencv2/face.hpp>

namespace fc {
    
    class FaceLandmarkDetector {
        dlib::shape_predictor shapePredictor;
        cv::Ptr<cv::face::Facemark> facemark;
        
    public:
        enum DetectorModel {
            DlibModel,
            OpencvModel,
        };
        
        FaceLandmarkDetector(){};
        
        void use(DetectorModel, std::string);
        
        void detectLandmark(dlib::cv_image<dlib::rgb_alpha_pixel> image, std::vector<dlib::rectangle> faceRects, std::function<void(dlib::full_object_detection&)> faceLandmarkCallback);
        
        void detectLandmark(dlib::cv_image<dlib::rgb_pixel> image, std::vector<dlib::rectangle> faceRects, std::function<void(dlib::full_object_detection&)> faceLandmarkCallback);
        
        
        void detectLandmark(cv::Mat image, std::vector<cv::Rect> faceRects, std::function<void(std::vector<cv::Point2f>)> faceLandmarkResult);
    };
}

#endif /* FaceDetector_hpp */
