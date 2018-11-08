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
        facemark = cv::face::FacemarkLBF::create();
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
    bool detectedResult = facemark->fit(image, faceRects, shapes);
    if (detectedResult) {
        printf("%d\n", detectedResult);
        
        for (unsigned long i=0;i<shapes.size();i++) {
            vector<cv::Point2f> shape;
            faceLandmarkResult(shape);
        }
    }
}

fc::FaceLandmarkDetector::Array2D FaceLandmarkDetector::detectLandmark(cv::Mat image, std::vector<cv::Rect> faceRects) {
    cv::Mat grayImage;
    cv::cvtColor(image, grayImage, cv::COLOR_BGRA2GRAY);
    fc::FaceLandmarkDetector::Array2D shapes;
    
    bool detectedResult = facemark->fit(grayImage, faceRects, shapes);
    if (detectedResult) {
        for (unsigned long i=0;i<shapes.size();i++) {
            vector<cv::Point2f> shape;
            for(unsigned long index = 0; index < shape.size(); index++) {
                cv::circle(image, shape[index], 5, cv::Scalar(0,0,255), cv::FILLED);
            }
        }
    }
    return shapes;
}
