//
//  ImageProcession.hpp
//  FaceCamera
//
//  Created by  zcating on 2018/12/21.
//  Copyright © 2018 zcat. All rights reserved.
//

#ifndef ImageProcession_h
#define ImageProcession_h

namespace fc {
    static void OverlayImage(cv::Mat& image, cv::Mat& mask) {
        cv::Rect rect(0, 0, image.cols, image.rows);
        cv::Mat resizedMask;
        cv::resize(mask, resizedMask, rect.size());

        long channels = image.channels();
        long size = image.rows * image.cols;

        for (long index = 0; index < size; index += 4) {
            // get opacity for the over image.
            double opacity = ((double)resizedMask.data[index + 3]) / 255.;
            
            for(int channel = 0; opacity > 0 && channel < channels; channel++) {
                uchar targetPixel = resizedMask.data[index + channel];
                uchar roiPixel = image.data[index + channel];
                image.data[index + channel] = static_cast<uchar>(roiPixel * (1. - opacity) + targetPixel * opacity);
            }
        }
    }
}

#endif /* ImageProcession_h */
