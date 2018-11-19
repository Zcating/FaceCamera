//
//  FCCoreVisualService.m
//  FaceCamera
//
//  Created by  zcating on 2018/11/10.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FCCoreVisualService.h"
#import "FaceCore.hpp"


static inline dlib::rectangle ConvertCVRect(const cv::Rect& rect);
static void DelaunaryTriangles(cv::Mat& image, const dlib::full_object_detection landmarks);


@interface FCCoreVisualService () {
    dlib::shape_predictor shapePredictor;
    fc::FaceCore faceCore;
}


@end

@implementation FCCoreVisualService

- (instancetype)init {
    self = [super init];
    if (self) {
//        self.detector = [LandmarkDetector new];
        [self prepare];
    }
    return self;
}


- (void)prepare {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"shape_predictor_68_face_landmarks" ofType:@"dat"];
    
    dlib::deserialize([path UTF8String]) >> shapePredictor;
}



- (void)runWithSampleBuffer:(CMSampleBufferRef)sampleBuffer inRects:(NSArray<NSValue *> *)faces {
    // get all pixels in the frame.
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // need to lock buffer to access the pixels.
    CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    char *baseBuffer = (char *)CVPixelBufferGetBaseAddress(pixelBuffer);
    
    // get opencv image object
    cv::Mat image((int)height, (int)width, CV_8UC4, baseBuffer, bytesPerRow);
    
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    
    
    for (NSValue *value in faces) {
        CGRect rectValue = value.CGRectValue;
        //
        cv::Rect faceRect(rectValue.origin.x, rectValue.origin.y, rectValue.size.width, rectValue.size.height);

        auto landmarks = shapePredictor(dlib::cv_image<dlib::rgb_alpha_pixel>(image), ConvertCVRect(faceRect));
        
#ifdef FC_DEBUG
        cv::rectangle(image, faceRect.tl(), faceRect.br(), cv::Scalar(0, 0, 255, 255), 2);
        
//        for (auto index = 0; index < landmarks.num_parts(); index++) {
//            auto p = landmarks.part(index);
//            cv::Point point(static_cast<int>(p.x()), static_cast<int>(p.y()));
//            cv::circle(image, point, 2, cv::Scalar(255, 255, 0, 0));
//        }
#endif
        
        faceCore.prepare(image, landmarks, faceRect).drawLip();
    }
    
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    
    width = CVPixelBufferGetWidth(pixelBuffer);
    height = CVPixelBufferGetHeight(pixelBuffer);
    baseBuffer = (char *)CVPixelBufferGetBaseAddress(pixelBuffer);
    
    uint8_t* pixelPtr = (uint8_t *)image.data;
    
    // traslate to sample buffer.
    long size = image.rows * image.cols;
    for (int index = 0; index < size; index++) {
        for (int channel = 0; channel < image.channels(); channel++) {
            baseBuffer[index + channel] = pixelPtr[index + channel];
        }
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
}



//- ()

@end


static inline dlib::rectangle ConvertCVRect(const cv::Rect& rect) {
    auto tl = rect.tl();
    auto br = rect.br();
    
    long left = tl.x;
    long top = tl.y;
    long right = br.x;
    long bottom = br.y;
    
    return dlib::rectangle(left, top, right, bottom);
}






// idw
void WarpingFace(cv::Mat image, dlib::full_object_detection detection)
{
    auto left = detection.part(4);
    auto right = detection.part(12);
    
    
}

static void DelaunaryTriangles(cv::Mat &image, const dlib::full_object_detection landmarks) {
    cv::Scalar color(255, 255, 0, 255);
    cv::Rect rect(0, 0, INT_MAX, INT_MAX);
    cv::Subdiv2D subdiv(rect);
    for (int i = 0; i < landmarks.num_parts(); i++) {
        dlib::point point = landmarks.part(i);
        int x = static_cast<int>(point.x());
        int y = static_cast<int>(point.y());
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
            // 超出边界则不画
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
}

//void gen(cv::Mat image, double ratio) {
//    int i, j;
//    double di, dj;
//    double nx, ny;
//    int nxi, nyi, nxi1, nyi1;
//    double deltaX, deltaY;
//    double w, h;
//    int ni, nj;
//
//    for (i = 0; i < tarH; i += gridSize) {
//        for (j = 0; j < tarW; j += gridSize) {
//            ni = i + gridSize;
//            nj = j + gridSize;
//            w = h = gridSize;
//
//            if (ni >= tarH) {
//                ni = tarH - 1;
//                h = ni - i + 1;
//            }
//
//            if (nj >= tarW) {
//                nj = tarW - 1;
//                w = nj - j + 1;
//            }
//
//            for (di = 0; di < h; di++) {
//                for (dj = 0; dj < w; dj++) {
//                    deltaX = bilinear_interp(di / h, dj / w, rDx(i, j), rDx(i, nj), rDx(ni, j), rDx(ni, nj));
//                    deltaY = bilinear_interp(di / h, dj / w, rDy(i, j), rDy(i, nj), rDy(ni, j), rDy(ni, nj));
//
//                    nx = j + dj + deltaX * transRatio;
//                    ny = i + di + deltaY * transRatio;
//                    if (nx > srcW - 1) nx = srcW - 1;
//                    if (ny > srcH - 1) ny = srcH - 1;
//                    if (nx < 0) nx = 0;
//                    if (ny < 0) ny = 0;
//                    nxi = int(nx);
//                    nyi = int(ny);
//                    nxi1 = ceil(nx);
//                    nyi1 = ceil(ny);
//
//                    if (oriImg.channels() == 1) {
//                        newImg.at<uchar>(i + di, j + dj) = bilinear_interp(
//                                                                           ny - nyi, nx - nxi, oriImg.at<uchar>(nyi, nxi),
//                                                                           oriImg.at<uchar>(nyi, nxi1),
//                                                                           oriImg.at<uchar>(nyi1, nxi),
//                                                                           oriImg.at<uchar>(nyi1, nxi1));
//                    } else {
//                        for (int ll = 0; ll < 3; ll++) {
//                            newImg.at<Vec3b>(i + di, j + dj)[ll] = bilinear_interp(
//                                                                                   ny - nyi, nx - nxi,
//                                                                                   oriImg.at<Vec3b>(nyi, nxi)[ll],
//                                                                                   oriImg.at<Vec3b>(nyi, nxi1)[ll],
//                                                                                   oriImg.at<Vec3b>(nyi1, nxi)[ll],
//                                                                                   oriImg.at<Vec3b>(nyi1, nxi1)[ll]);
//                        }
//                    }
//                }
//            }
//        }
//    }
//}

void OverlayImageOnFace(const cv::Mat &image, const cv::Mat &target, const cv::Rect &rect) {
    cv::Mat resizedTarget;
    cv::resize(target, resizedTarget, rect.size());
    cv::Mat roi(image, rect);
    
    int channels = image.channels();
    
    for (int y = 0; y < roi.rows; ++y) {
        for (int x = 0; x < roi.cols; ++x) {
            // get opacity for the over image.
            double opacity = ((double)resizedTarget.data[y * resizedTarget.step + x * resizedTarget.channels() + 3]) / 255.;
            
            for(int channel = 0; opacity > 0 && channel < channels; ++channel) {
                uchar targetPixel = resizedTarget.data[y * resizedTarget.step + x * channels + channel];
                uchar roiPixel = roi.data[y * roi.step + x * channels + channel];
                roi.data[y * roi.step + channels * x + channel] = static_cast<uchar>(roiPixel * (1. - opacity) + targetPixel * opacity);
            }
        }
    }
}
