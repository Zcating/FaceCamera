//
//  MaskGLView.m
//  FaceCamera
//
//  Created by  zcating on 2018/11/28.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "MaskGLView.h"

using namespace std;

@interface MaskGLView() {
    GLuint _vertexBufferID;
    GLuint _indexBufferID;
    
    MaskMap maskmap;
    
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
}

@property (nonatomic, strong) CAEAGLLayer *eaglLayer;
@property (nonatomic, strong) EAGLContext *glContext;
@property (nonatomic, strong) GLKBaseEffect *baseEffect;



@end


@implementation MaskGLView
//
//// define the face shape vertex bufferfor drawing
//
int numVertices = 76;
int sizeFaceShapeVertices = numVertices * sizeof(VertexData);
double W = 512.0;
double H = 512.0;


double screenWidth = 300.0;
double screenHeight = 300.0;

VertexData faceShapeVertices[76];



GLubyte faceShapeTriangles[] = {
    68,69,0,
    68,0,17,
    68,17,18,
    68,18,19,
    68,19,75,
    75,19,20,
    75,20,21,
    75,21,22,
    75,22,23,
    75,23,24,
    75,24,74,
    74,24,25,
    74,25,26,
    74,26,16,
    74,16,73,
    73,16,15,
    73,15,14,
    73,14,13,
    73,13,72,
    72,13,12,
    72,12,11,
    72,11,10,
    72,10,71,
    71,10,9,
    71,9,8,
    71,8,7,
    71,7,70,
    70,7,6,
    70,6,5,
    70,5,4,
    70,4,69,
    69,4,3,
    69,3,2,
    69,2,1,
    69,1,0,
    
    0,1,36,
    1,36,41,
    1,41,31,
    1,2,31,
    2,48,31,
    2,3,48,
    3,4,48,
    4,5,48,
    5,59,48,
    5,6,59,
    6,58,59,
    6,7,58,
    7,57,58,
    7,8,57,
    8,56,57,
    8,9,56,
    9,10,56,
    10,55,56,
    
    10,11,55,
    11,54,55,
    11,12,54,
    12,13,54,
    13,14,54,
    14,35,54,
    14,46,35,
    14,45,46,
    14,15,45,
    15,26,45,
    15,16,26,
    26,45,25,
    25,24,45,
    24,44,45,
    24,23,44,
    23,43,44,
    23,22,43,
    22,42,43,
    22,27,42,
    22,21,27,
    
    21,39,27,
    21,38,39,
    21,20,38,
    20,37,38,
    20,19,37,
    19,18,37,
    18,36,37,
    18,17,36,
    17,0,36,
    36,37,41,
    37,41,40,
    37,40,38,
    38,40,39,
    39,28,27,
    27,28,42,
    42,43,47,
    43,47,44,
    44,47,46,
    44,46,45,
    46,47,35,
    47,42,35,
    
    42,29,35,
    42,28,29,
    28,29,39,
    39,40,29,
    40,29,31,
    40,41,31,
    31,29,30,
    29,30,35,
    35,30,34,
    34,30,33,
    33,30,32,
    32,30,31,
    31,48,49,
    31,49,32,
    32,49,50,
    32,50,33,
    33,50,51,
    33,51,52,
    33,52,34,
    34,52,35,
    52,35,53,
    35,53,54,
    
    52,53,63,
    52,51,63,
    51,62,63,
    51,62,61,
    51,61,50,
    50,61,49,
    49,48,60,
    48,60,59,
    60,59,49,
    49,59,61,
    61,59,67,
    61,67,62,
    62,67,66,
    62,66,65,
    62,65,63,
    63,65,55,
    63,55,53,
    53,55,64,
    53,64,54,
    54,64,55,
    55,65,56,
    56,65,66,
    56,66,57,
    
    66,57,58,
    66,67,58,
    67,59,58
};

+ (Class)layerClass {
    return [CAEAGLLayer class];
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        [self setupContext];
        [self setupDisplayLink];
    }
    return self;
}

- (void)dealloc {
    self.glContext = nil;
}



// MARK: - Public

- (void)updateLandmarkPoint:(int)index updateWith:(LandmarkInfo)landmarkInfo {
    
    double curDistOfIndexand36 = (landmarkInfo.curDistOf36and45 / prevDistOf36and45) * landmarkInfo.distOfIndexand36;
    double x_offset = curDistOfIndexand36 * cos(landmarkInfo.angleOfIndexand36 + landmarkInfo.angleChanged);
    double y_offset = curDistOfIndexand36 * sin(landmarkInfo.angleOfIndexand36 + landmarkInfo.angleChanged);
    
    auto newPoint = cv::Point_<double>(maskmap.curPoint36.x + x_offset, maskmap.curPoint36.y - y_offset);
    
    VertexData& data = faceShapeVertices[index];
    
    data.position[0] = newPoint.x;
    data.position[1] = newPoint.y;
}

- (void)updateLandmarkPoint:(int)index offset:(const cv::Point &)point {
    cv::Point_<double> newPoint = cv::Point_<double>(maskmap.curPoint36.x + point.x, maskmap.curPoint36.y - point.y);
    
    VertexData& data = faceShapeVertices[index];
    data.position[0] = newPoint.x;
    data.position[1] = newPoint.y;
}

- (void)setupVBOs:(NSString *)imageName withLandmarks:(const std::vector<cv::Point> &)landmarks {

    CGImageRef textureRef = [[UIImage imageNamed:imageName] CGImage];
    GLKTextureInfo* textureInfo = [GLKTextureLoader textureWithCGImage:textureRef options:nil error:NULL];
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = GLKTextureTarget2D;
}

// MARK: - Private
- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = NO;
    _eaglLayer.drawableProperties =
    [NSDictionary dictionaryWithObjectsAndKeys: kEAGLColorFormatRGBA8,
     kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext {
    self.glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    GLKView* view = (GLKView*) self;
    view.context = self.glContext;
    
    if (!self.glContext) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:self.glContext]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.transform.projectionMatrix =
    GLKMatrix4MakeOrtho(0, self.frame.size.width, self.frame.size.height, 0, 0, 1); // which makes top left corner as 0,0 for opengl drawing
    
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

// main render function
- (void)render:(CADisplayLink*)displayLink {
    glClear(GL_COLOR_BUFFER_BIT);
    glBufferData(GL_ARRAY_BUFFER, sizeFaceShapeVertices, NULL, GL_DYNAMIC_DRAW);
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeFaceShapeVertices, faceShapeVertices);
    
    [self.baseEffect prepareToDraw];
    
    glDrawElements(GL_TRIANGLES, sizeof(faceShapeTriangles) /sizeof(faceShapeTriangles[0]), GL_UNSIGNED_BYTE, 0);
    
    [self.glContext presentRenderbuffer:GL_RENDERBUFFER];
}

// drawing runloop
- (void)setupDisplayLink {
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}


@end
