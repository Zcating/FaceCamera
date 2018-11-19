//
//  FaceUtil.hpp
//  FaceCamera
//
//  Created by  zcating on 2018/11/12.
//  Copyright © 2018 zcat. All rights reserved.
//

#ifndef FaceUtil_hpp
#define FaceUtil_hpp

#include <opencv2/opencv.hpp>

namespace fc {
    class FaceCore {
    private:
        static cv::Mat white;
        cv::Mat image;
        cv::Rect rect;
        dlib::full_object_detection landmarks;

        inline cv::Point landmarksPointConvertToPoint(int index);
        
    public:
        FaceCore() {
        };
        
        ~FaceCore(){
            
        };
        
        FaceCore& prepare(cv::Mat& image, const dlib::full_object_detection& landmarks, const cv::Rect& rect) {
            this->image = image;
            this->landmarks = landmarks;
            this->rect = rect;
            printf("%d\n", &(this->landmarks));
            printf("%d\n", &(landmarks));
            
            white = cv::Mat(image.cols, image.rows, CV_8UC4 , 4);
            
            return *this;
        };
        
        FaceCore& thinFace(double strenth) {
            
            return *this;
        };
        
        FaceCore& overlayImage(cv::Mat& target) {
            cv::Mat resizedTarget;
            cv::resize(target, resizedTarget, rect.size());
            cv::Mat roi(image, rect);
            
            long channels = image.channels();
            long size = roi.rows * roi.cols;
            
            for (long index = 0; index < size; index++) {
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
        
        FaceCore& delaunaryTriangles() {
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
        
        FaceCore& drawLip();
        
    };
}

#endif /* FaceUtil_hpp */
