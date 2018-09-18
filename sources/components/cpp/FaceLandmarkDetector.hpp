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

namespace fc {
    
    class FaceLandmarkDetector {
        dlib::shape_predictor shapePredictor;
        FaceLandmarkDetector(){};
    public:
        FaceLandmarkDetector(std::string);
        
        void detectLandmark(dlib::cv_image<dlib::rgb_alpha_pixel> image, std::vector<dlib::rectangle> faceRects, std::function<void(dlib::full_object_detection&)> faceLandmarkCallback);
        
        void detectLandmark(dlib::cv_image<dlib::rgb_pixel> image, std::vector<dlib::rectangle> faceRects, std::function<void(dlib::full_object_detection&)> faceLandmarkCallback);
    };
}

#endif /* FaceDetector_hpp */
