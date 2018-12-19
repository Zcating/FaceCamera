//
//  MaskGLView.m
//  FaceCamera
//
//  Created by  zcating on 2018/11/28.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "MaskGLView.h"

using namespace std;

inline static double Distance(const cv::Point_<double>& point1, const cv::Point_<double>& point2) {
    auto xOffset = point1.x - point2.x;
    auto yOffset = point1.y - point2.y;

    return std::sqrt(xOffset * xOffset + yOffset * yOffset);
}

inline static double Angle(const cv::Point_<double>& point1, const cv::Point_<double>& point2) {
    auto slope = (point1.y - point2.y) / (point1.x - point2.x);
    return std::atan(slope);
}

@interface MaskGLView() {

    //
    GLuint _vertexBufferID;
    GLuint _indexBufferID;
    
    MaskMap _maskMap;
    
    
    float _previousDistOf36and45;
    float _previousAngleOf36and45;
    
    float _previousDistOf68and36;
    float _previousAngleOf68and36;
    
    float _previousDistOf69and36;
    float _previousAngleOf69and36;
    
    
    float _previousDistOf70and36;
    float _previousAngleOf70and36;
    
    float _previousDistOf71and36;
    float _previousAngleOf71and36;
    
    float _previousDistOf72and36;
    float _previousAngleOf72and36;
    
    
    float _previousDistOf73and36;
    float _previousAngleOf73and36;
    
    
    float _previousDistOf74and36;
    float _previousAngleOf74and36;
    
    
    float _previousDistOf75and36;
    float _previousAngleOf75and36;
    
    
//    dispatch_queue_t _concurrentQueue;
}

@property (nonatomic) dispatch_queue_t concurrentQueue;

@property (nonatomic, strong) GLKBaseEffect *baseEffect;

@property (nonatomic) CGSize frameSize;

@property (nonatomic) CGSize imageSize;

@end


@implementation MaskGLView
//
//// define the face shape vertex bufferfor drawing
//
int _numVertices = 76;
int _sizeFaceShapeVertices = _numVertices * sizeof(VertexData);

VertexData _landmarkVertices[76];

GLubyte _delaunayTriangles[] = {
    
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
    
    //
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
    
    //
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
    
    //
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
    
    //
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
    
    //
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
    
    //
    66,57,58,
    66,67,58,
    67,59,58
};


+ (Class)layerClass {
    return [CAEAGLLayer class];
}


- (id)initWithFrame:(CGRect)frame context:(EAGLContext *)context {
    self = [super initWithFrame:frame context:context];
    if (self) {
        self.type = FCResolutionType916;
        [self setupLayer];
        [self setupContext];
        [self setupDisplayLink];
    }
    return self;
}


// MARK: - Private

- (void)setupLayer {
    CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
    eaglLayer.opaque = NO;
    eaglLayer.drawableProperties = @{kEAGLColorFormatRGBA8: kEAGLDrawablePropertyColorFormat};
}

- (void)setupContext {
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

- (void)setupDisplayLink {
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)render:(CADisplayLink*)displayLink {
    glClear(GL_COLOR_BUFFER_BIT);
    glBufferData(GL_ARRAY_BUFFER, _sizeFaceShapeVertices, NULL, GL_DYNAMIC_DRAW);
    glBufferSubData(GL_ARRAY_BUFFER, 0, _sizeFaceShapeVertices, _landmarkVertices);
    glDrawElements(GL_TRIANGLES, sizeof(_delaunayTriangles) / sizeof(_delaunayTriangles[0]), GL_UNSIGNED_BYTE, 0);

    [self.baseEffect prepareToDraw];
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

-(void) initReferenceMaskData {
    VertexData& data = _landmarkVertices[68];
    _maskMap.point68 = cv::Point_<double>(data.position[0],data.position[1]);
    
    VertexData& data21 = _landmarkVertices[69];
    _maskMap.point69 = cv::Point_<double>(data21.position[0],data21.position[1]);
    
    VertexData& data22 = _landmarkVertices[70];
    _maskMap.point70 = cv::Point_<double>(data22.position[0],data22.position[1]);
    
    VertexData& data23 = _landmarkVertices[71];
    _maskMap.point71 = cv::Point_<double>(data23.position[0],data23.position[1]);
    
    VertexData& data24 = _landmarkVertices[72];
    _maskMap.point72 = cv::Point_<double>(data24.position[0],data24.position[1]);
    
    VertexData& data25 = _landmarkVertices[73];
    _maskMap.point73 = cv::Point_<double>(data25.position[0],data25.position[1]);
    
    
    VertexData& data26 = _landmarkVertices[74];
    _maskMap.point74 = cv::Point_<double>(data26.position[0],data26.position[1]);
    
    
    VertexData& data27 = _landmarkVertices[75];
    _maskMap.point75 = cv::Point_<double>(data27.position[0],data27.position[1]);
    
    
    VertexData& data4 = _landmarkVertices[36];
    _maskMap.prevPoint36 = cv::Point_<double>(data4.position[0],data4.position[1]);
    
    
    VertexData& data5 = _landmarkVertices[45];
    _maskMap.prevPoint45 = cv::Point_<double>(data5.position[0],data5.position[1]);
    
    
    _previousDistOf36and45 = Distance(_maskMap.prevPoint45, _maskMap.prevPoint36);
    _previousAngleOf36and45 = Angle(_maskMap.prevPoint45, _maskMap.prevPoint36);
    
    _previousDistOf68and36 = Distance(_maskMap.point68, _maskMap.prevPoint36);
    _previousAngleOf68and36 = Angle(_maskMap.point68, _maskMap.prevPoint36);
    
    _previousDistOf72and36 = Distance(_maskMap.point72, _maskMap.prevPoint36);
    _previousAngleOf72and36 = Angle(_maskMap.point72, _maskMap.prevPoint36);
    
    _previousDistOf74and36 = Distance(_maskMap.point74, _maskMap.prevPoint36);
    _previousAngleOf74and36 = Angle(_maskMap.point74, _maskMap.prevPoint36);
    
    
    _previousDistOf70and36 = Distance(_maskMap.point70, _maskMap.prevPoint36);
    _previousAngleOf70and36 = Angle(_maskMap.point70, _maskMap.prevPoint36);
    
    
    _previousDistOf69and36 = Distance(_maskMap.point69, _maskMap.prevPoint36);
    _previousAngleOf69and36 = Angle(_maskMap.point69, _maskMap.prevPoint36);
    
    
    _previousDistOf71and36 = Distance(_maskMap.point71, _maskMap.prevPoint36);
    _previousAngleOf71and36 = Angle(_maskMap.point71, _maskMap.prevPoint36);
    
    
    
    _previousDistOf73and36 = Distance(_maskMap.point73, _maskMap.prevPoint36);
    _previousAngleOf73and36 = Angle(_maskMap.point73, _maskMap.prevPoint36);
    
    
    _previousDistOf75and36 = Distance(_maskMap.point75, _maskMap.prevPoint36);
    _previousAngleOf75and36 = Angle(_maskMap.point75, _maskMap.prevPoint36);

}


-(void)calculateMaskRect {
    
    float curDistOf36And45 = Distance(_maskMap.curPoint45, _maskMap.curPoint36);
    float curAngleOf36And45 = Angle(_maskMap.curPoint45, _maskMap.curPoint36);
    
    float angleDif =  _previousAngleOf36and45 - curAngleOf36And45;
    
    
    LandmarkInfo landmarkInfo;
    
    landmarkInfo.angleChanged = angleDif;
    landmarkInfo.curAngleOf36And45 = curAngleOf36And45;
    landmarkInfo.curDistOf36And45 = curDistOf36And45;
    
    // 68
    landmarkInfo.angleOfIndexAnd36 = M_PI - _previousAngleOf68and36;
    landmarkInfo.distOfIndexAnd36 = _previousDistOf68and36;
    [self updateLandmarkPoint:68 UpdateWith:landmarkInfo];

    // 69
    landmarkInfo.angleOfIndexAnd36 = M_PI + abs( _previousAngleOf69and36);
    landmarkInfo.distOfIndexAnd36 = _previousDistOf69and36;
    [self updateLandmarkPoint:69 UpdateWith:landmarkInfo];
    
    // 72
    landmarkInfo.angleOfIndexAnd36 = (M_PI * 2) - abs( _previousAngleOf72and36);
    landmarkInfo.distOfIndexAnd36 = _previousDistOf72and36;
    [self updateLandmarkPoint:72 UpdateWith:landmarkInfo];
    
    
    // 74
    landmarkInfo.angleOfIndexAnd36 = -_previousAngleOf74and36 ;
    landmarkInfo.distOfIndexAnd36 = _previousDistOf74and36;
    [self updateLandmarkPoint:74 UpdateWith:landmarkInfo];
    
    // 70
    landmarkInfo.angleOfIndexAnd36 = M_PI + abs( _previousAngleOf70and36);
    landmarkInfo.distOfIndexAnd36 = _previousDistOf70and36;
    [self updateLandmarkPoint:70 UpdateWith:landmarkInfo];

    
    
    // 71
    landmarkInfo.angleOfIndexAnd36 = (M_PI * 2) - abs( _previousAngleOf71and36);
    landmarkInfo.distOfIndexAnd36 = _previousDistOf71and36;
    [self updateLandmarkPoint:71 UpdateWith:landmarkInfo];
    
    // 73
    landmarkInfo.angleOfIndexAnd36 = (M_PI * 2) - abs( _previousAngleOf73and36);
    landmarkInfo.distOfIndexAnd36 = _previousDistOf73and36;
    [self updateLandmarkPoint:73 UpdateWith:landmarkInfo];
    
    // 75
    landmarkInfo.angleOfIndexAnd36 =  -_previousAngleOf75and36;
    landmarkInfo.distOfIndexAnd36 = _previousDistOf75and36;
    [self updateLandmarkPoint:75 UpdateWith:landmarkInfo];
    
}

-(void)updateLandmarkPoint:(int)index UpdateWith:(LandmarkInfo) landmarkInfo {
    
    float distOfIndexAnd36 = (landmarkInfo.curDistOf36And45 / _previousDistOf36and45) * landmarkInfo.distOfIndexAnd36;
    float xOffset = distOfIndexAnd36 * std::cos(landmarkInfo.angleOfIndexAnd36 + landmarkInfo.angleChanged);
    float yOffset = distOfIndexAnd36 * std::sin(landmarkInfo.angleOfIndexAnd36 + landmarkInfo.angleChanged);
    
    cv::Point_<double> newPoint(_maskMap.curPoint36.x + xOffset, _maskMap.curPoint36.y - yOffset);
    
    VertexData& data = _landmarkVertices[index];

    data.position[0] = newPoint.x;
    data.position[1] = newPoint.y;
}



// MARK: - Public


- (void)updateLandmarks:(const std::vector<cv::Point_<double>> &)shape faceIndex:(long)faceIndex {

    CGSize imageSize = self.imageSize;
    CGSize frameSize = self.frameSize;
//    CGRect rect = [[UIScreen mainScreen] bounds];
    for (int i = 0; i < shape.size(); i++) {
        const auto& point = shape[i];
        float x = ((float)point.x * frameSize.width) / imageSize.width;
        float y = ((float)point.y * frameSize.height) / imageSize.height;
        
        VertexData& data = _landmarkVertices[i];
        data.position[0] = x;
        data.position[1] = y;
    }

    VertexData& data6 = _landmarkVertices[36];
    _maskMap.curPoint36 = cv::Point_<double>(data6.position[0],data6.position[1]);
    
    
    VertexData& data3 = _landmarkVertices[45];
    _maskMap.curPoint45 = cv::Point_<double>(data3.position[0],data3.position[1]);
    
    [self calculateMaskRect];
}


- (void)setupVBOs:(NSString *)imageName withLandmarkArray:(NSArray *)landmarkArray {
    UIImage *image = [UIImage imageNamed:imageName];
    
    for(int i = 0; i < landmarkArray.count; ++i) {
        NSDictionary *landmark = [landmarkArray objectAtIndex:i];
        VertexData& data = _landmarkVertices[i];

        int x = [landmark[@"x"] intValue];
        int y = [landmark[@"y"] intValue];
        data.position[0] = x;
        data.position[1] = y;
        data.position[2] = 0;
        data.uv[0] = x / image.size.width;
        data.uv[1] = y / image.size.height;
    }
    [self initReferenceMaskData];
    
    glGenBuffers(1, &_vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER, _sizeFaceShapeVertices, NULL, GL_DYNAMIC_DRAW);
    glBufferSubData(GL_ARRAY_BUFFER, 0, _sizeFaceShapeVertices, _landmarkVertices);
    
    glGenBuffers(1, &_indexBufferID);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBufferID);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(_delaunayTriangles), NULL, GL_STATIC_DRAW);
    glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, 0, sizeof(_delaunayTriangles), _delaunayTriangles);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(VertexData), (GLvoid*) offsetof(VertexData, position));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(VertexData), (GLvoid*) offsetof(VertexData, uv));
    
    CGImageRef texRef = [image CGImage];
    GLKTextureInfo* textureInfo =[GLKTextureLoader textureWithCGImage:texRef options:nil error:NULL];
    
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = GLKTextureTarget2D;
}


// MARK: - GETTER & SETTER

-(GLKBaseEffect *)baseEffect {
    if (_baseEffect == nil) {
        _baseEffect = [[GLKBaseEffect alloc] init];
        _baseEffect.transform.projectionMatrix = GLKMatrix4MakeOrtho(0, self.frame.size.width, self.frame.size.height, 0, 0, 1);
    }
    return _baseEffect;
}

-(void)setType:(FCResolutionType)type {
    _type = type;
    CGSize frameSize = [UIScreen mainScreen].bounds.size;
    CGSize imageSize = CGSizeMake(720, 1280);
    if (type == FCResolutionType11) {
        frameSize.height = frameSize.width;
        imageSize.height = imageSize.width;
    } else if (type == FCResolutionType34) {
        frameSize.height = frameSize.width * 3 / 4.0;
        imageSize.height = imageSize.width * 3 / 4.0;
    }
    self.frameSize = frameSize;
    self.imageSize = imageSize;
}

//-(dispatch_queue_t)concurrentQueue {
//    if (_concurrentQueue == 0) {
//        _concurrentQueue = dispatch_queue_create("mask.concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
//    }
//    return _concurrentQueue;
//}
//
//-(CGFloat)ratio {
//    __block CGFloat theRatio;
//    dispatch_sync(self.concurrentQueue, ^{
//        theRatio = self->_ratio;
//    });
//    return theRatio;
//}
//
//
//-(void)setRatio:(CGFloat)ratio {
//    dispatch_barrier_sync(self.concurrentQueue, ^{
//        self->_ratio = ratio;
//    });
//}
//

@end



