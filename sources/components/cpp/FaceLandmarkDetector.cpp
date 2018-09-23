//
//  FaceLandmarkDetector.cpp
//  FaceCamera
//
//  Created by  zcating on 2018/9/18.
//  Copyright © 2018 zcat. All rights reserved.
//

#include "FaceLandmarkDetector.hpp"


using namespace fc;
using namespace std;


FaceLandmarkDetector::FaceLandmarkDetector(std::string dataFileName) {
    dlib::deserialize(dataFileName) >> shapePredictor;
}


void FaceLandmarkDetector::detectLandmark(dlib::cv_image<dlib::rgb_alpha_pixel> image, std::vector<dlib::rectangle> faceRects, std::function<void(dlib::full_object_detection&)> faceLandmarkResult) {
    
    for (auto faceRect : faceRects) {
        dlib::full_object_detection shape = shapePredictor(image, faceRect);
        faceLandmarkResult(shape);
    }
}


void FaceLandmarkDetector::detectLandmark(dlib::cv_image<dlib::rgb_pixel> image, std::vector<dlib::rectangle> faceRects, std::function<void(dlib::full_object_detection&)> faceLandmarkResult) {
    for (auto faceRect : faceRects) {
        dlib::full_object_detection shape = shapePredictor(image, faceRect);
        faceLandmarkResult(shape);
    }
}
