//
//  test.cpp
//  FaceCamera
//
//  Created by  zcating on 2018/11/19.
//  Copyright © 2018 zcat. All rights reserved.
//

#include "test.hpp"

using cv::Vec3b;

ImgWarp_MLS::ImgWarp_MLS()
{
    gridSize = 5;
}

//
inline double BilinearInterpolation(double x, double y, double v11, double v12, double v21, double v22) {
    return (v11 * (1 - y) + v12 * y) * (1 - x) + (v21 * (1 - y) + v22 * y) * x;
}


Mat ImgWarp_MLS::setAllAndGenerate(const Mat & oriImg,
                                   const vector< Point_<int> > &qsrc,
                                   const vector< Point_<int> > &qdst,
                                   const int outW, const int outH,
                                   const double transRatio) {
    // 多余
    setSize(oriImg.cols, oriImg.rows);
    // 输出图片大小，多余
    setTargetSize(outW, outH);
    //
    setSrcPoints(qsrc);
    setDstPoints(qdst);
    calcDelta();
    return genNewImg(oriImg, transRatio);
}


Mat ImgWarp_MLS::genNewImg(const Mat & oriImg, double transRatio) {
    int i,j;
    double di, dj;
    double nx, ny;
    int nxi, nyi, nxi1, nyi1;
    double deltaX, deltaY;
    double w, h;
    int ni, nj;
    
    Mat newImg(tarH, tarW, oriImg.type());
    for (i = 0; i < tarH; i += gridSize) {
        for (j = 0; j < tarW; j += gridSize) {
            ni = i + gridSize;
            nj = j + gridSize;
            w = h = gridSize;
            if (ni>=tarH) {
                ni = tarH - 1;
                h = ni-i + 1;
            }
            if (nj>=tarW) {
                nj = tarW-1;
                w = nj-j+1;
            }
            for (di=0; di < h; di++) {
                for (dj=0; dj < w; dj++) {
                    deltaX = BilinearInterpolation(di/h, dj/w, rDx(i,j), rDx(i, nj), rDx(ni, j), rDx(ni, nj));
                    deltaY = BilinearInterpolation(di/h, dj/w, rDy(i,j), rDy(i, nj), rDy(ni, j), rDy(ni, nj));
                    
                    nx = j + dj + deltaX * transRatio;
                    ny = i + di + deltaY * transRatio;
                    
                    if (nx>srcW-1) {
                        nx = srcW-1;
                    }
                    if (ny>srcH-1) {
                        ny = srcH-1;
                    }
                    if (nx<0) {
                        nx = 0;
                    }
                    if (ny<0) {
                        ny = 0;
                    }
                    nxi = int(nx);
                    nyi = int(ny);
                    nxi1 = ceil(nx);
                    nyi1 = ceil(ny);
                    
                    if (oriImg.channels() == 1) {
                        newImg.at<uchar>(i+di, j+dj) = BilinearInterpolation(ny-nyi, nx-nxi, oriImg.at<uchar>(nyi, nxi), oriImg.at<uchar>(nyi, nxi1), oriImg.at<uchar>(nyi1, nxi), oriImg.at<uchar>(nyi1, nxi1));
                    } else {
                        for (int ll = 0; ll < 3; ll++) {
                            newImg.at<Vec3b>(i+di, j+dj)[ll] = BilinearInterpolation(ny - nyi, nx - nxi, oriImg.at<Vec3b>(nyi, nxi)[ll], oriImg.at<Vec3b>(nyi, nxi1)[ll], oriImg.at<Vec3b>(nyi1, nxi)[ll], oriImg.at<Vec3b>(nyi1, nxi1)[ll]);
                        }
                    }
                }
            }
        }
    }
    return newImg;
}

    // Set source points and prepare transformation matrices
void ImgWarp_MLS::setSrcPoints(const vector< Point_< int > > &qsrc) {
    nPoint = static_cast<int>(qsrc.size());
    
    newDotL.clear();
    newDotL.reserve(nPoint);
    
    
    for (size_t i = 0; i<qsrc.size(); i++) {
        newDotL.push_back(qsrc[i]);
    }
        //std::copy(qsrc.begin(), qsrc.end(), newDotL.begin());
    
}

void ImgWarp_MLS::setDstPoints(const vector< Point_< int > > &qdst) {
    nPoint = static_cast<int>(qdst.size());
        //oldDotL = Mat(nPoint, 2, CV_32FC1);
    oldDotL.clear();
    oldDotL.reserve(nPoint);
    
    for (size_t i = 0; i<qdst.size(); i++) {
        oldDotL.push_back(qdst[i]);
    }
        //std::copy(qdst.begin(), qdst.end(), oldDotL.begin());
}
