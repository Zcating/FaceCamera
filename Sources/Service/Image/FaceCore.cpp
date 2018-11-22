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


static inline void HSVToRGB(double *hsv, uchar& red, uchar& green, uchar& blue);

static inline void RGBAToHSV(double red, double green, double blue, double* hsv);

FaceCore& FaceCore::prepare(const cv::Mat& image, const std::vector<Point>& landmarks, const cv::Rect& rect) {
    this->image = image;
    this->landmarks = landmarks;
    this->rect = rect;
//    printf("%d\n", &(this->landmarks));
//    printf("%d\n", &(landmarks));
    
//    white = cv::Mat(image.cols, image.rows, CV_8UC4 , 4);
    
    return *this;
}

FaceCore& FaceCore::thinFace(double strenth) {
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
    
    for (long index = 0; index < size; index+=4) {
            // get opacity for the over image.
        double opacity = ((double)resizedTarget.data[index + 3]) / 255.;
        
        for(int channel = 0; opacity > 0 && channel < channels; ++channel) {
            uchar targetPixel = resizedTarget.data[index + channel];
            uchar roiPixel = roi.data[index + channel];
            roi.data[index + channel] = static_cast<uchar>(roiPixel * (1. - opacity) + targetPixel * opacity);
        }
    }
    return *this;
};

FaceCore& FaceCore::drawLip() {
    static Scalar testColor(255, 0, 0, 255);
//    static double targetHSV[3];
//    RGBAToHSV(255, 20, 10, targetHSV);
    static std::vector<Point> topLipPoints(12, Point(0, 0));
    static std::vector<Point> bottomLipPoints(12, Point(0, 0));
    static std::vector<std::vector<Point>> contours(1, std::vector<Point>());
    
//    cv::Mat copy;
//    image.copyTo(copy);
    // top lip's landmark points
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

    
    cv::convexHull(Mat(topLipPoints), contours[0]);
    cv::drawContours(image, contours, -1, Scalar(255, 0, 255, 255), -1);
    
    cv::convexHull(Mat(bottomLipPoints), contours[0]);
    cv::drawContours(image, contours, -1, Scalar(255, 0, 255, 255), -1);
    
    
    
//    const Point *pointTensor[2] = {topLipPoints, bottomLipPoints};
    
//    cv::fillPoly(copy, pointTensor, numbers, 2, testColor);
    
//    long size = image.rows * image.cols;
//
//    const uchar *copyData = copy.data;
//    uchar *imageData = image.data;
    
//    for (int index = 0; index < size; index += 4) {
//         if (copyData[index] == 255 &&
//          copyData[index + 1] == 0 &&
//          copyData[index + 2] == 0 &&
//          copyData[index + 3] == 255) {
//             double hsv[3];
//             RGBAToHSV(imageData[index + 2], imageData[index + 1], imageData[index], hsv);
//             hsv[0] = targetHSV[0];
//             hsv[1] += std::abs((targetHSV[1] - hsv[1]) / 5.0);
//
//             HSVToRGB(hsv, imageData[index + 2], imageData[index + 1], imageData[index]);
//             printf("fuck\n");
//         }
//    }
    
    return *this;
}


// https://zh.wikipedia.org/wiki/HSL%E5%92%8CHSV%E8%89%B2%E5%BD%A9%E7%A9%BA%E9%97%B4
static inline void RGBAToHSV(double red, double green, double blue, double* hsv) {
    double redMinusGreen = red - green;
    double redMinusBlue = red - blue;
    double greenMinusBlue = green - blue;
    double sqrtTarget = redMinusGreen * redMinusGreen + redMinusBlue * greenMinusBlue;
    
    double result = std::acos(0.5 * (redMinusGreen + redMinusBlue) / std::sqrt(sqrtTarget));
    
    double maxRGB = std::max(std::max(red, green), blue);
    double minRGB = std::min(std::min(red, green), blue);
    
    hsv[0] = green >= blue ? result : 2*M_PI - result;
    hsv[1] = (maxRGB - minRGB) / maxRGB;
    hsv[2] = maxRGB / 255;
}


// https://zh.wikipedia.org/wiki/HSL%E5%92%8CHSV%E8%89%B2%E5%BD%A9%E7%A9%BA%E9%97%B4
static inline void HSVToRGB(double* hsv, uchar& red, uchar& green, uchar& blue) {
    int hDiv60 = (int)(hsv[0] * 3 / M_PI);
    int hi = hDiv60 % 6;
    int f = hDiv60 - hi;
    
    double s = hsv[1];
    double v = hsv[2];
    int p = v * (1 - s);
    switch (hi) {
        case 0: {
            int t = hsv[2] * (1 - (1 - f) * hsv[1]);
            red = v;
            green = t;
            blue = p;
            break;
        }
        case 1: {
            int q = hsv[2] * (1 - f * hsv[1]);
            red = q;
            green = v;
            blue = p;
            break;
        }
        case 2: {
            int t = hsv[2] * (1 - (1 - f) * hsv[1]);
            red = p;
            green = v;
            blue = t;
            break;
        }
        case 3: {
            int q = hsv[2] * (1 - f * hsv[1]);
            red = p;
            green = q;
            blue = v;
            break;
        }
        case 4: {
            int t = hsv[2] * (1 - (1 - f) * hsv[1]);
            red = t;
            green = p;
            blue = v;
            break;
        }
        case 5: {
            int q = hsv[2] * (1 - f * hsv[1]);
            red = v;
            green = p;
            blue = q;
            break;
        }
        default:
            break;
    }
    
}
