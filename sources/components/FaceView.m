//
//  FaceView.m
//  BikaCamera
//
//  Created by  zcating on 2018/8/26.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FaceView.h"

@implementation FaceView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CIContext *content = [CIContext contextWithOptions:nil];
        
        // 配置识别质量
        NSDictionary *param = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
        
        // 创建人脸识别器
        self.detector = [CIDetector detectorOfType:CIDetectorTypeFace context:content options:param];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
}


@end
