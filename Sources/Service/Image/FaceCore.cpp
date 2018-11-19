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

FaceCore& FaceCore::drawLip() {
    static Scalar testColor(0, 0, 255, 150);
    static Point topLipPoints[12];
    static Point bottomLipPoints[12];
    static int numbers[2] = {12, 12};
    
    // top lip's landmark points
    topLipPoints[0] = landmarksPointConvertToPoint(48);
    topLipPoints[1] = landmarksPointConvertToPoint(49);
    topLipPoints[2] = landmarksPointConvertToPoint(50);
    topLipPoints[3] = landmarksPointConvertToPoint(51);
    topLipPoints[4] = landmarksPointConvertToPoint(52);
    topLipPoints[5] = landmarksPointConvertToPoint(53);
    topLipPoints[6] = landmarksPointConvertToPoint(54);
    topLipPoints[7] = landmarksPointConvertToPoint(64);
    topLipPoints[8] = landmarksPointConvertToPoint(63);
    topLipPoints[9] = landmarksPointConvertToPoint(62);
    topLipPoints[10] = landmarksPointConvertToPoint(61);
    topLipPoints[11] = landmarksPointConvertToPoint(60);
    
    // bot lip's landmark points
    bottomLipPoints[0] = landmarksPointConvertToPoint(48);
    bottomLipPoints[1] = landmarksPointConvertToPoint(59);
    bottomLipPoints[2] = landmarksPointConvertToPoint(58);
    bottomLipPoints[3] = landmarksPointConvertToPoint(57);
    bottomLipPoints[4] = landmarksPointConvertToPoint(56);
    bottomLipPoints[5] = landmarksPointConvertToPoint(55);
    bottomLipPoints[6] = landmarksPointConvertToPoint(54);
    bottomLipPoints[7] = landmarksPointConvertToPoint(64);
    bottomLipPoints[8] = landmarksPointConvertToPoint(65);
    bottomLipPoints[9] = landmarksPointConvertToPoint(66);
    bottomLipPoints[10] = landmarksPointConvertToPoint(67);
    bottomLipPoints[11] = landmarksPointConvertToPoint(60);

    
    const Point *pointTensor[2] = {topLipPoints, bottomLipPoints};
    
    cv::fillPoly(image, pointTensor, numbers, 2, testColor);
    
    return *this;
}


inline cv::Point FaceCore::landmarksPointConvertToPoint(int index) {
    auto landmark = landmarks.part(index);
    return cv::Point(static_cast<int>(landmark.x()), static_cast<int>(landmark.y()));
};


