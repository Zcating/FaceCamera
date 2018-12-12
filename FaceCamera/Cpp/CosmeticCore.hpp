//
//  CosmeticCore.hpp
//  FaceCamera
//
//  Created by  zcating on 2018/11/28.
//  Copyright © 2018 zcat. All rights reserved.
//

#ifndef CosmeticCore_hpp
#define CosmeticCore_hpp

#include <dlib/image_processing.h>
#include <dlib/image_io.h>
#include <dlib/opencv.h>

#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#include "Const.h"

namespace fc {
    
    // whole mask points
    struct MaskMap {
        cv::Point point68;
        cv::Point point69;
        cv::Point point70;
        cv::Point point71;
        cv::Point point72;
        cv::Point point73;
        cv::Point point74;
        cv::Point point75;
        cv::Point prevPoint36;
        cv::Point prevPoint45;
        cv::Point curPoint36;
        cv::Point curPoint45;
    };
    
    
    struct LandmarkInfo {
        double distOf36And45;
        double angleOf36And45;
        double angleOfIndexAnd36;
        double distOfIndexAnd36;
        double angleChanged;
    };
    
    
    // vertex data
    struct VertexData {
         std::vector<double> position = std::vector<double>(3, 0);
         std::vector<double> uv = std::vector<double>(2, 0);
    };

    //
    inline static double Distance(const cv::Point_<double>& point1, const cv::Point_<double>& point2) {
        auto xOffset = point1.x - point2.x;
        auto yOffset = point1.y - point2.y;
        
        return sqrt(xOffset * xOffset + yOffset * yOffset);
    }
    
    //
    inline static double angle(const cv::Point_<double>& point1, const cv::Point_<double>& point2) {
        auto slope = (point1.y - point2.y) / (point1.x - point2.x);
        return atan(slope);
    }
    
    class CosmeticCore {
        int numVertices = 76;
        int sizeFaceShapeVertices = numVertices * sizeof(VertexData);
        double W = 512.0;
        double H = 512.0;
        
        
        double screenWidth = 300.0;
        double screenHeight = 300.0;
        
        VertexData faceShapeVertices[76];
        MaskMap maskMap;
        
        double prevDistOf36and45;
        double prevAngleOf36and45;
        
        double prevDistOf68and36;
        double prevAngleOf68and36;
        
        double prevDistOf69and36;
        double prevAngleOf69and36;
        
        
        double prevDistOf70and36;
        double prevAngleOf70and36;
        
        double prevDistOf71and36;
        double prevAngleOf71and36;
        
        double prevDistOf72and36;
        double prevAngleOf72and36;
        
        
        double prevDistOf73and36;
        double prevAngleOf73and36;
        
        
        double prevDistOf74and36;
        double prevAngleOf74and36;
        
        
        double prevDistOf75and36;
        double prevAngleOf75and36;
        
        GLuint vertexBufferId;
        GLuint indexBufferId;
        
        void updateLandmark(int index, const cv::Point_<double>& point) {
            auto newPoint = cv::Point_<double>(maskMap.curPoint36.x + point.x, maskMap.curPoint36.y - point.y);
            
            VertexData& data = faceShapeVertices[index];
                //
            data.position[0] = newPoint.x;
            data.position[1] = newPoint.y;
        }
        
        void updateLandmark(int index, const LandmarkInfo &landmarkInfo) {
            double curdistOfIndexAnd36 = (landmarkInfo.distOf36And45 / prevDistOf36and45) * landmarkInfo.distOfIndexAnd36;
            double x_offset = curdistOfIndexAnd36 * cos(landmarkInfo.angleOfIndexAnd36 + landmarkInfo.angleChanged);
            double y_offset = curdistOfIndexAnd36 * sin(landmarkInfo.angleOfIndexAnd36 + landmarkInfo.angleChanged);
            
            auto newPoint = cv::Point_<double>(maskMap.curPoint36.x + x_offset, maskMap.curPoint36.y - y_offset);
            
            VertexData& data = faceShapeVertices[index];
            
            data.position[0] = newPoint.x;
            data.position[1] = newPoint.y;
        }
    public:
        CosmeticCore() {}
        ~CosmeticCore() {}
        
        void calculateMaskRect() {
            double distOf36And45 = Distance(maskMap.curPoint45, maskMap.curPoint36);
            double angleOf36And45 = Distance(maskMap.curPoint45, maskMap.curPoint36);
            
            double angleDif =  prevAngleOf36and45 - angleOf36And45;
            
            LandmarkInfo landmarkInfo;
            
            landmarkInfo.angleChanged = angleDif;
            landmarkInfo.angleOf36And45 = angleOf36And45;
            landmarkInfo.distOf36And45 = distOf36And45;
            
            // 68
            landmarkInfo.angleOfIndexAnd36 = M_PI - prevAngleOf68and36;
            landmarkInfo.distOfIndexAnd36 = prevDistOf68and36;
            updateLandmark(68, landmarkInfo);
            
            // 69
            landmarkInfo.angleOfIndexAnd36 = M_PI + abs(prevAngleOf69and36);
            landmarkInfo.distOfIndexAnd36 = prevDistOf69and36;
            updateLandmark(69, landmarkInfo);
            
            // 70
            landmarkInfo.angleOfIndexAnd36 = M_PI + abs(prevAngleOf70and36);
            landmarkInfo.distOfIndexAnd36 = prevDistOf70and36;
            updateLandmark(70, landmarkInfo);
            
            // 71
            landmarkInfo.angleOfIndexAnd36 = (M_PI * 2) - abs(prevAngleOf71and36);
            landmarkInfo.distOfIndexAnd36 = prevDistOf71and36;
            updateLandmark(71, landmarkInfo);
            
            // 72
            landmarkInfo.angleOfIndexAnd36 = (M_PI * 2) - abs(prevAngleOf72and36);
            landmarkInfo.distOfIndexAnd36 = prevDistOf72and36;
            updateLandmark(72, landmarkInfo);
            
            // 73
            landmarkInfo.angleOfIndexAnd36 = (M_PI * 2) - abs(prevAngleOf73and36);
            landmarkInfo.distOfIndexAnd36 = prevDistOf73and36;
            updateLandmark(73, landmarkInfo);
            
            // 74
            landmarkInfo.angleOfIndexAnd36 = -prevAngleOf74and36 ;
            landmarkInfo.distOfIndexAnd36 = prevDistOf74and36;
            updateLandmark(74, landmarkInfo);
            
            // 75
            landmarkInfo.angleOfIndexAnd36 =  -prevAngleOf75and36;
            landmarkInfo.distOfIndexAnd36 = prevDistOf75and36;
            updateLandmark(75, landmarkInfo);
        }

        
        void update(const std::vector<cv::Point_<double>>& landmarks) {
            for(auto i = 0; i < landmarks.size(); ++i) {
                
                const cv::Point &landmark = landmarks[i];
                
                VertexData& data = faceShapeVertices[i];
                data.position[0] = (landmark.x * screenWidth)/W;
                data.position[1] = (landmark.y * screenHeight)/H;
                data.position[2] = 0;
                data.uv[0] = landmark.x / W;
                data.uv[1] = landmark.y / H;
            }
            
            glGenBuffers(1, &vertexBufferId);
            glBindBuffer(GL_ARRAY_BUFFER, vertexBufferId);
            glBufferData(GL_ARRAY_BUFFER, sizeFaceShapeVertices, NULL, GL_DYNAMIC_DRAW);
            glBufferSubData(GL_ARRAY_BUFFER, 0, sizeFaceShapeVertices, faceShapeVertices);
            
            glGenBuffers(1, &indexBufferId);
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferId);
            glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(DelaunayTriangles), NULL, GL_STATIC_DRAW);
            glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, 0, sizeof(DelaunayTriangles), DelaunayTriangles);
            

            glEnableVertexAttribArray(0);
            glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, sizeof(VertexData), (GLvoid*) offsetof(VertexData, position));
            
            glEnableVertexAttribArray(3);
            glVertexAttribPointer(3, 2, GL_FLOAT, GL_FALSE, sizeof(VertexData), (GLvoid*) offsetof(VertexData, uv));
        };
    };
}
#endif /* CosmeticCore_hpp */
