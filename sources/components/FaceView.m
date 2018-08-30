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


-(VideoCamera *)camera {
    if (_camera == nil) {
        _camera = [[VideoCamera alloc] initWithParentView:self];
        _camera.delegate = self;
        _camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
        _camera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetHigh;
    }
    return _camera;
}

//-(CALayer *)faceLayer {
//    if (_faceLayer == nil) {
//        _faceLayer =
//    }
//}

-(NSMutableArray<CALayer *> *)faceLayers {
    if (_faceLayers == nil) {
        _faceLayers = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return _faceLayers;
}

-(UIView *)faceContentView {
    if (_faceContentView == nil) {
        _faceContentView = [[UIView alloc] init];
        _faceContentView.backgroundColor = [UIColor clearColor];
        _faceContentView.layer.masksToBounds = YES;
        _faceContentView.layer.borderColor = [UIColor yellowColor].CGColor;
        _faceContentView.layer.borderWidth = 2;
        [self addSubview:_faceContentView];
    }
    return _faceContentView;
}

-(void)start {
    [self.camera start];
}

-(void)processCIImage:(CIImage *)image {
    NSDictionary *featuresParam = @{
                                    CIDetectorSmile: @YES,
                                    CIDetectorEyeBlink: @YES,
                                    CIDetectorImageOrientation: @6
                                    };
    // 获取识别结果
    NSArray *resultArr = [self.detector featuresInImage:image options:featuresParam];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (resultArr.count == 0) {
            self.faceContentView.hidden = YES;
            return;
        }
        self.faceContentView.hidden = NO;
        CGSize imageSize = image.extent.size;
        CGRect previewBox = [self videoPreviewBoxForFrameSize:self.frame.size apertureSize:imageSize];
        
        CGFloat widthScaleBy = previewBox.size.width / imageSize.height;
        CGFloat heightScaleBy = previewBox.size.height / imageSize.width;
        
        for (CIFaceFeature *feature in resultArr) {
            // (Bottom right if mirroring is turned on)
            CGRect faceRect = feature.bounds;
            
            // flip preview width and height
            CGFloat temp = faceRect.size.width;
            faceRect.size.width = faceRect.size.height;
            faceRect.size.height = temp;
            temp = faceRect.origin.x;
            faceRect.origin.x = faceRect.origin.y;
            faceRect.origin.y = temp;
            // scale coordinates so they fit in the preview box, which may be scaled
            faceRect.size.width *= widthScaleBy;
            faceRect.size.height *= heightScaleBy;
            faceRect.origin.x *= widthScaleBy;
            faceRect.origin.y *= heightScaleBy;
            faceRect = CGRectOffset(faceRect, previewBox.origin.x + previewBox.size.width - faceRect.size.width - (faceRect.origin.x * 2), previewBox.origin.y);
            //            faceRect = CGRectOffset(faceRect, previewBox.origin.x, previewBox.origin.y);
            
            self.faceContentView.frame = faceRect;
         
#ifdef FaceCameraDebug
            self.label.text = [NSString stringWithFormat:@"%.2f, %.2f, %.2f, %.2f", faceRect.origin.x, faceRect.origin.y, faceRect.size.width, faceRect.size.height];
#endif

        }
    });
}



/* The intended display orientation of the image. If present, the value
 * of this key is a CFNumberRef with the same value as defined by the
 * TIFF and Exif specifications.  That is:
 *   1  =  0th row is at the top, and 0th column is on the left.
 *   2  =  0th row is at the top, and 0th column is on the right.
 *   3  =  0th row is at the bottom, and 0th column is on the right.
 *   4  =  0th row is at the bottom, and 0th column is on the left.
 *   5  =  0th row is on the left, and 0th column is the top.
 *   6  =  0th row is on the right, and 0th column is the top.
 *   7  =  0th row is on the right, and 0th column is the bottom.
 *   8  =  0th row is on the left, and 0th column is the bottom.
 * If not present, a value of 1 is assumed. */

-(CGRect)videoPreviewBoxForFrameSize:(CGSize)frameSize apertureSize:(CGSize)apertureSize {
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    
    CGSize size = CGSizeZero;
    if (viewRatio > apertureRatio) {
        size.width = frameSize.width;
        size.height = apertureSize.width * (frameSize.width / apertureSize.height);
    } else {
        size.width = apertureSize.height * (frameSize.height / apertureSize.width);
        size.height = frameSize.height;
    }
    
    CGRect videoBox;
    videoBox.size = size;
    if (size.width < frameSize.width) {
        videoBox.origin.x = (frameSize.width - size.width) / 2;
        videoBox.origin.y = (frameSize.height - size.height) / 2;
    } else {
        videoBox.origin.x = (size.width - frameSize.width) / 2;
        videoBox.origin.y = (size.height - frameSize.height) / 2;
    }
    
    return videoBox;
}

@end
