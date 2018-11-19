//
//  ImageWarper.hpp
//  FaceCamera
//
//  Created by  zcating on 2018/11/16.
//  Copyright © 2018 zcat. All rights reserved.
//

#ifndef ImageWarper_hpp
#define ImageWarper_hpp

class ImageWarper {
public:
        //! How to deal with the background.
    /*!
     BGNone: No background is reserved.
     BGMLS: Use MLS to deal with the background.
     BGPieceWise: Use the same scheme for the background.
     */
    enum BGFill {
        
        //! No background is reserved.
        BGNone,

        //! Use MLS to deal with the background
        BGMLS,
        
        //! Use the same scheme for the background.
        BGPieceWise
    };
    
    ImageWarper(void);
    ~ImageWarper(void);
    
    void calcDelta();
    BGFill backGroundFillAlg;
private:
    cv::Point_<double> getMLSDelta(int x, int y);
    
    std::vector< cv::Point_< double > > oldDotL, newDotL;
    
    int nPoint;
    
    cv::Mat_<double> rDx, rDy;
    
    int srcW, srcH;
    int tarW, tarH;
    
    //! Parameter for MLS.
    double alpha;
    
    //! Parameter for MLS.
    int gridSize;
};

#endif /* ImageWarper_hpp */
