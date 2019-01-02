//
//  MaskGLView.m
//  FaceCamera
//
//  Created by  zcating on 2018/11/28.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "MaskGLView.h"
#import "FCMask.h"

const static NSUInteger MAX_FACES_NUMBER = 5;

using namespace std;

@interface MaskGLView() {
    CGSize _screenSize;
}

@property (nonatomic, strong) UIImage *textureImage;

@property (nonatomic, strong) NSArray *landmarks;

//@property (nonatomic, strong) FCMask *mask;

@property (nonatomic, strong) NSMutableArray<FCMask *> *masks;

@end


@implementation MaskGLView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}


- (id)initWithFrame:(CGRect)frame context:(EAGLContext *)context {
    self = [super initWithFrame:frame context:context];
    if (self) {
        [self initLayer];
        [self initContext];
        [self initDisplayLink];
    }
    return self;
}


// MARK: - PRIVATE

- (void)initLayer {
    CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
    eaglLayer.opaque = NO;
    eaglLayer.drawableProperties = @{
        kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8,
        kEAGLDrawablePropertyRetainedBacking: @(YES),
    };
}

- (void)initContext {
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

- (void)initDisplayLink {
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)render:(CADisplayLink*)displayLink {
    glClear(GL_COLOR_BUFFER_BIT);

    [self.masks enumerateObjectsUsingBlock:^(FCMask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.enable) {
            [obj draw];
        }
    }];
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}


// MARK: - PUBLIC

- (void)prepare {
    for (NSUInteger index = 0; index < MAX_FACES_NUMBER; index++) {
        self.masks[index].enable = NO;
    }
}

//  If it detected n faces, the 'faceIndex' would be in the range of [0, n - 1).
- (void)updateLandmarks:(const std::vector<cv::Point_<double>> &)landmarks faceIndex:(long)faceIndex {
    // So, here is in a loop of faces, the 'faceIndex' will add one in each loop.
    if (faceIndex > MAX_FACES_NUMBER) {
        return;
    }
    self.masks[faceIndex].enable = YES;
    [self.masks[faceIndex] updateLandmarks:landmarks];
}


- (void)setupImage:(NSString *)imageName landmarks:(NSArray *)landmarks {
    [self.masks enumerateObjectsUsingBlock:^(FCMask * _Nonnull mask, NSUInteger idx, BOOL * _Nonnull stop) {
        [mask setupImage:[UIImage imageNamed:imageName] landmarks:landmarks];
    }];
}



// MARK: - GETTER & SETTER

-(NSMutableArray<FCMask *> *)masks {
    if (_masks == nil) {
        _masks = [NSMutableArray arrayWithCapacity:MAX_FACES_NUMBER];
        for(int i = 0; i < MAX_FACES_NUMBER; i++) {
            FCMask *mask = [[FCMask alloc] init];
            [_masks addObject:mask];
        }
    }
    return _masks;
}

//-(FCMask *)mask {
//    if (_mask == nil) {
//        _mask = [[FCMask alloc] init];
//
////        [_mask setupImage:self.textureImage landmarks:self.landmarks];
//    }
//    return _mask;
//}

@end



