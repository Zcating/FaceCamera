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

dlib::rectangle convertCVRect(cv::Rect rect);


void FaceLandmarkDetector::use(string dataFileName) {
     dlib::deserialize(dataFileName) >> shapePredictor;
}


dlib::full_object_detection FaceLandmarkDetector::detectLandmark(dlib::cv_image<dlib::rgb_alpha_pixel> image, dlib::rectangle faceRect) {
    
    return shapePredictor(image, faceRect);
}


void FaceLandmarkDetector::detectLandmark(dlib::cv_image<dlib::rgb_pixel> image, std::vector<dlib::rectangle> faceRects, std::function<void(dlib::full_object_detection&)> faceLandmarkResult) {
    for (auto faceRect : faceRects) {
        dlib::full_object_detection shape = shapePredictor(image, faceRect);
        faceLandmarkResult(shape);
    }
}


dlib::full_object_detection FaceLandmarkDetector::detectLandmark(cv::Mat image, cv::Rect faceRect) {
    dlib::cv_image<dlib::rgb_alpha_pixel> dImage(image);
    auto rect = convertCVRect(faceRect);
    dlib::full_object_detection shape = shapePredictor(dImage, rect);
    return shape;
}


dlib::rectangle convertCVRect(cv::Rect rect) {
    auto tl = rect.tl();
    auto br = rect.br();
    
    long left = tl.x;
    long top = tl.y;
    long right = br.x;
    long bottom = br.y;
    
    return dlib::rectangle(left, top, right, bottom);
}
