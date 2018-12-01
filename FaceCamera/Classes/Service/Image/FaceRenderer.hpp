//
//  FaceRenderer.hpp
//  FaceCamera
//
//  Created by  zcating on 2018/11/19.
//  Copyright © 2018 zcat. All rights reserved.
//

#ifndef FaceRenderer_hpp
#define FaceRenderer_hpp


#include <OpenGLES/ES3/gl.h>
#include <OpenGLES/ES3/glext.h>
#include "Shader.hpp"
#include "Texture.hpp"

namespace fc {
    
    class FaceRenderer {
        Shader shader;
        
    public:
        FaceRenderer(const Shader& shader, int width, int height) : shader(shader) {
            glClearColor( 1.0f, 1.0f, 1.0f, 0.0f );
            glViewport(0, 0, width, height);
        };
        ~FaceRenderer(){};
        
        void render(const cv::Mat& image, const std::vector<cv::Point>& landmarks) {

            Texture texture(image);
            glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

            shader.use();
            
            mouth(landmarks);
        };
        
        void mouth(const std::vector<cv::Point>& landmarks) {

            // RGBA
            float color[4] = {1.0, 1.0, 1.0, 1.0};
            
            float topLipPoly[] = {
                static_cast<float>(landmarks[48].x), static_cast<float>(landmarks[48].y), 0,
                static_cast<float>(landmarks[49].x), static_cast<float>(landmarks[49].y), 0,
                static_cast<float>(landmarks[50].x), static_cast<float>(landmarks[50].y), 0,
                static_cast<float>(landmarks[51].x), static_cast<float>(landmarks[51].y), 0,
                static_cast<float>(landmarks[52].x), static_cast<float>(landmarks[52].y), 0,
                static_cast<float>(landmarks[53].x), static_cast<float>(landmarks[53].y), 0,
                static_cast<float>(landmarks[54].x), static_cast<float>(landmarks[54].y), 0,
                static_cast<float>(landmarks[64].x), static_cast<float>(landmarks[64].y), 0,
                static_cast<float>(landmarks[63].x), static_cast<float>(landmarks[63].y), 0,
                static_cast<float>(landmarks[62].x), static_cast<float>(landmarks[62].y), 0,
                static_cast<float>(landmarks[61].x), static_cast<float>(landmarks[61].y), 0,
                static_cast<float>(landmarks[60].x), static_cast<float>(landmarks[60].y), 0
            };
            
            float botLipPoly[] = {
                static_cast<float>(landmarks[48].x), static_cast<float>(landmarks[48].y), 0,
                static_cast<float>(landmarks[59].x), static_cast<float>(landmarks[49].y), 0,
                static_cast<float>(landmarks[58].x), static_cast<float>(landmarks[50].y), 0,
                static_cast<float>(landmarks[57].x), static_cast<float>(landmarks[51].y), 0,
                static_cast<float>(landmarks[56].x), static_cast<float>(landmarks[52].y), 0,
                static_cast<float>(landmarks[55].x), static_cast<float>(landmarks[53].y), 0,
                static_cast<float>(landmarks[54].x), static_cast<float>(landmarks[54].y), 0,
                static_cast<float>(landmarks[64].x), static_cast<float>(landmarks[64].y), 0,
                static_cast<float>(landmarks[65].x), static_cast<float>(landmarks[63].y), 0,
                static_cast<float>(landmarks[66].x), static_cast<float>(landmarks[62].y), 0,
                static_cast<float>(landmarks[67].x), static_cast<float>(landmarks[61].y), 0,
                static_cast<float>(landmarks[60].x), static_cast<float>(landmarks[60].y), 0
            };
            
            
            GLuint topLipPolyBuffer;
            glGenBuffers(1, &topLipPolyBuffer);
            glBindBuffer(GL_ARRAY_BUFFER, topLipPolyBuffer);
            glBufferData(GL_ARRAY_BUFFER, sizeof(topLipPoly), topLipPoly, GL_STATIC_DRAW);
            
//            glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, 0);
//            glEnableVertexAttribArray(_positionSlot);
            
        };
    };
}

#endif /* FaceRenderer_hpp */
