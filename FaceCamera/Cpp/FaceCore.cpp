//
//  FaceUtil.cpp
//  FaceCamera
//
//  Created by  zcating on 2018/11/12.
//  Copyright © 2018 zcat. All rights reserved.
//

#include "FaceCore.hpp"

using namespace fc;
using namespace cv;


FaceCore& FaceCore::prepare(const cv::Mat& image, const std::vector<Point>& landmarks, const cv::Rect& rect) {
    this->image = image;
    this->landmarks = landmarks;
    this->rect = rect;
    
    return *this;
}


FaceCore& FaceCore::delaunaryTriangles() {
    cv::Rect imageRect(0, 0, 65536, 65536);
    cv::Subdiv2D subdiv(imageRect);
    cv::Scalar color(255, 255, 0, 255);
    for (auto landmark : this->landmarks) {
        subdiv.insert(landmark);
    }
    
    std::vector<cv::Vec6f> triangleList;
    subdiv.getTriangleList(triangleList);
    cv::Point points[3];
    for(auto triangle : triangleList) {
        
        bool needToDraw = true;
        for(int i = 0; i < 3; i++) {
                //
            points[i] = cv::Point(cvRound(triangle[i * 2]), cvRound(triangle[i * 2 + 1]));
            
            if(points[i].x > image.cols ||
               points[i].y > image.rows ||
               points[i].x < 0 ||
               points[i].y < 0) {
                needToDraw = false;
            }
        }
            // 画三角形
        if (needToDraw) {
            cv::line(image, points[0], points[1], color, 1);
            cv::line(image, points[1], points[2], color, 1);
            cv::line(image, points[2], points[0], color, 1);
        }
    }
    return *this;
};

FaceCore& FaceCore::overlayImage(cv::Mat& target) {
    cv::Mat resizedTarget;
    cv::resize(target, resizedTarget, rect.size());
    cv::Mat roi(image, rect);
    
    long channels = image.channels();
    long size = roi.rows * roi.cols;
    
    for (long index = 0; index < size; index += 4) {
        // get opacity for the over image.
        double opacity = ((double)resizedTarget.data[index + 3]) / 255.;
        
        for(int channel = 0; opacity > 0 && channel < channels; channel++) {
            uchar targetPixel = resizedTarget.data[index + channel];
            uchar roiPixel = roi.data[index + channel];
            roi.data[index + channel] = static_cast<uchar>(roiPixel * (1. - opacity) + targetPixel * opacity);
        }
    }
    return *this;
};

FaceCore& FaceCore::drawLip() {
    static Scalar testColor(255, 0, 0, 255);
    static Scalar tagColor(0, 255, 0, 255);
    static std::vector<Point> topLipPoints(12, Point(0, 0));
    static std::vector<Point> bottomLipPoints(12, Point(0, 0));
    

    topLipPoints[0] = landmarks[48];
    topLipPoints[1] = landmarks[49];
    topLipPoints[2] = landmarks[50];
    topLipPoints[3] = landmarks[51];
    topLipPoints[4] = landmarks[52];
    topLipPoints[5] = landmarks[53];
    topLipPoints[6] = landmarks[54];
    topLipPoints[7] = landmarks[64];
    topLipPoints[8] = landmarks[63];
    topLipPoints[9] = landmarks[62];
    topLipPoints[10] = landmarks[61];
    topLipPoints[11] = landmarks[60];

    // bot lip's landmark points
    bottomLipPoints[0] = landmarks[48];
    bottomLipPoints[1] = landmarks[59];
    bottomLipPoints[2] = landmarks[58];
    bottomLipPoints[3] = landmarks[57];
    bottomLipPoints[4] = landmarks[56];
    bottomLipPoints[5] = landmarks[55];
    bottomLipPoints[6] = landmarks[54];
    bottomLipPoints[7] = landmarks[64];
    bottomLipPoints[8] = landmarks[65];
    bottomLipPoints[9] = landmarks[66];
    bottomLipPoints[10] = landmarks[67];
    bottomLipPoints[11] = landmarks[60];
    
    return *this;
}



