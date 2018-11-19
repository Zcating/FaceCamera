//
//  ImageWarper.cpp
//  FaceCamera
//
//  Created by  zcating on 2018/11/16.
//  Copyright © 2018 zcat. All rights reserved.
//

#include "ImageWarper.hpp"


struct Triangle {
    cv::Point points[3];
};

ImageWarper::ImageWarper(void) {
    backGroundFillAlg = BGNone;
}

ImageWarper::~ImageWarper(void) {
}

cv::Point_<double> ImageWarper::getMLSDelta(int x, int y) {
    static cv::Point_<double> swq, qstar, newP, tmpP;
    double sw;
    
    static std::vector<double> w;
    w.resize(nPoint);
    
    static cv::Point_<double> swp, pstar, curV, curVJ, Pi, PiJ;
    double miu_s;
    
    int i = x;
    int j = y;
    int k;
    
    sw = 0;
    swp.x = swp.y = 0;
    swq.x = swq.y = 0;
    newP.x = newP.y = 0;
    curV.x = i;
    curV.y = j;
    for (k = 0; k < nPoint; k++) {
        
        if ((i==oldDotL[k].x) && j==oldDotL[k].y) {
            break;
        }
        
        w[k] = 1 / ((i-oldDotL[k].x) * (i - oldDotL[k].x) +
                  (j-oldDotL[k].y) * (j - oldDotL[k].y));
        sw = sw + w[k];
        swp = swp + w[k] * oldDotL[k];
        swq = swq + w[k] * newDotL[k];
    }
    if ( k == nPoint ) {
        pstar = (1 / sw) * swp ;
        qstar = 1 / sw * swq;
        
        
        // Calc miu_s
        miu_s = 0;
        for (k = 0; k < nPoint; k++) {
            if (i==oldDotL[k].x && j==oldDotL[k].y)
                continue;
            
            Pi = oldDotL[k] - pstar;
            miu_s += w[k] * Pi.dot(Pi);
        }
        
        curV -= pstar;
        curVJ.x = -curV.y;
        curVJ.y = curV.x;
        
        for (k = 0; k < nPoint; k++) {
            if (i == oldDotL[k].x && j == oldDotL[k].y)
                continue;
            
            Pi = oldDotL[k] - pstar;
            PiJ.x = -Pi.y;
            PiJ.y = Pi.x;
            
            tmpP.x = Pi.dot(curV) * newDotL[k].x - PiJ.dot(curV) * newDotL[k].y;
            tmpP.y = -Pi.dot(curVJ) * newDotL[k].x + PiJ.dot(curVJ) * newDotL[k].y;
            tmpP *= w[k] / miu_s;
            newP += tmpP;
        }
        newP += qstar;
    } else {
        newP = newDotL[k];
    }
    
    newP.x -= i;
    newP.y -= j;
    return newP;
}

void ImageWarper::calcDelta() {
    cv::Mat_< int > imgLabel = cv::Mat_< int >::zeros(tarH, tarW);
    
    rDx = rDx.zeros(tarH, tarW);
    rDy = rDy.zeros(tarH, tarW);
    for (int i=0;i<this->nPoint;i++){
            //! Ignore points outside the target image
        if (oldDotL[i].x<0)
            oldDotL[i].x = 0;
        if (oldDotL[i].y<0)
            oldDotL[i].y = 0;
        if (oldDotL[i].x >= tarW)
            oldDotL[i].x = tarW - 1;
        if (oldDotL[i].y >= tarH)
            oldDotL[i].y = tarH - 1;
        
        rDx(oldDotL[i]) = newDotL[i].x-oldDotL[i].x;
        rDy(oldDotL[i]) = newDotL[i].y-oldDotL[i].y;
    }
    rDx(0, 0) = rDy(0, 0) = 0;
    rDx(tarH - 1, 0) = rDy(0, tarW - 1) = 0;
    rDy(tarH - 1, 0) = rDy(tarH - 1, tarW - 1) = srcH-tarH;
    rDx(0, tarW - 1) = rDx(tarH - 1, tarW - 1) = srcW-tarW;
    
    
    cv::Rect_<int> boundRect(0, 0, tarW, tarH);
    
    std::vector< cv::Point_<double>> oL1 = oldDotL;
    if (backGroundFillAlg == BGPieceWise) {
        oL1.push_back(cv::Point2d(0, 0));
        oL1.push_back(cv::Point2d(0, tarH - 1));
        oL1.push_back(cv::Point2d(tarW - 1, 0));
        oL1.push_back(cv::Point2d(tarW - 1, tarH - 1));
    }
        // In order preserv the background
//    auto V = delaunayDiv(oL1, boundRect);
    std::vector<Triangle> V;
    //     vector< TriangleInID > Vt;
    // //     vector< Triangle >::iterator it;
    // //     cv::Rect_<int> boundRect(0, 0, tarW, tarH);
    //     Vt = ::delaunayDivInID(oldDotL, boundRect);
    cv::Mat_<uchar> imgTmp = cv::Mat_<uchar>::zeros(tarH, tarW);
    for (auto it = V.begin(); it != V.end(); it++){
        cv::line(imgTmp, it->points[0], it->points[1], 255, 1, CV_AA);
        cv::line(imgTmp, it->points[0], it->points[2], 255, 1, CV_AA);
        cv::line(imgTmp, it->points[2], it->points[1], 255, 1, CV_AA);
        
            // Not interested in points outside the region.
        if (!(it->points[0].inside(boundRect) && it->points[1].inside(boundRect) && it->points[2].inside(boundRect)))
            continue;
        
        cv::fillConvexPoly(imgLabel, it->points, 3, cv::Scalar_<long>(it-V.begin()+1));
    }
    
    
    int i, j;
    
    cv::Point_<int> v1, v2, curV;
    
    for (i = 0; ; i += gridSize) {
        if (i >= tarW && i < tarW+gridSize - 1)
            i= tarW - 1;
        else if (i >= tarW)
            break;
        for (j = 0; ; j += gridSize){
            if (j >= tarH && j < tarH+gridSize - 1)
                j = tarH - 1;
            else if (j>=tarH)
                break;
            int tId = imgLabel(j, i) - 1;
            if (tId<0){
                if (backGroundFillAlg == BGMLS){
                    cv::Point_<double> dV = getMLSDelta(i, j);
                    rDx(j, i) = dV.x;
                    rDy(j, i) = dV.y;
                }
                else{
                    rDx(j, i) = -i;
                    rDy(j, i) = -j;
                }
                continue;
            }
            v1 = V[tId].points[1] - V[tId].points[0];
            v2 = V[tId].points[2] - V[tId].points[0];
            curV.x = i;
            curV.y = j;
            curV -= V[tId].points[0];
            
            double d0, d1, d2;
            d2 = double(v1.x * curV.y - curV.x * v1.y)/(v1.x*v2.y-v2.x*v1.y);
            d1 = double(v2.x * curV.y - curV.x * v2.y)/(v2.x*v1.y-v1.x*v2.y);
                //d1=d2=0;
            d0 = 1-d1-d2;
            rDx(j, i) = d0 * rDx(V[tId].points[0]) + d1 * rDx(V[tId].points[1]) + d2 * rDx(V[tId].points[2]);
            rDy(j, i) = d0 * rDy(V[tId].points[0]) + d1 * rDy(V[tId].points[1]) + d2 * rDy(V[tId].points[2]);
        }
    }
}


std::vector< Triangle> delaunayDiv(const cv::Mat &image, const dlib::full_object_detection& landmarks) {
    cv::Rect imageRect(0, 0, 65536, 65536);
    cv::Subdiv2D subdiv(imageRect);
    cv::Scalar color(255, 255, 0, 255);
    for (int i = 0; i < landmarks.num_parts(); i++) {
        dlib::point point = landmarks.part(i);
        int x = static_cast<int>(point.x());
        int y = static_cast<int>(point.y());
        x = x > 0 ? x : 0;
        y = y > 0 ? y : 0;
        cv::Point p(x, y);
        subdiv.insert(p);
    }
    
    std::vector<Triangle> tv;
    std::vector<cv::Vec6f> triangleList;
    subdiv.getTriangleList(triangleList);
    cv::Point points[3];
    for(auto trianglePos : triangleList) {
        bool generateTri = true;
        Triangle triangle;
        for(int i = 0; i < 3; i++) {
                //
            triangle.points[i] = cv::Point(cvRound(trianglePos[i * 2]), cvRound(trianglePos[i * 2 + 1]));
            
            if(points[i].x > image.cols ||
               points[i].y > image.rows ||
               points[i].x < 0 ||
               points[i].y < 0) {
                generateTri = false;
            }
        }
            // 画三角形
        if (generateTri) {
            tv.push_back(triangle);
        }
    }
    return tv;
}
