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


void FaceLandmarkDetector::use(DetectorModel model, std::string dataFileName) {
    if (model == DlibModel) {
        dlib::deserialize(dataFileName) >> shapePredictor;
    } else {
        facemark = cv::face::createFacemarkKazemi();
        facemark->loadModel(dataFileName);
    }
    
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

void FaceLandmarkDetector::detectLandmark(cv::Mat image, std::vector<cv::Rect> faceRects, std::function<void(vector<cv::Point2f>)> faceLandmarkResult) {

    vector<vector<cv::Point2f>> shapes;
    if (facemark->fit(image, faceRects, shapes)) {
        for (unsigned long i=0;i<shapes.size();i++) {
            vector<cv::Point2f> shape;
            faceLandmarkResult(shape);
        }
    }
}
