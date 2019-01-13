//
//  FCShader.h
//  FaceCamera
//
//  Created by  zcating on 2019/1/11.
//  Copyright © 2019 zcat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FCShaderType) {
    FCShaderTypeVertex,
    FCShaderTypeFragment
};

@interface FCShader : NSObject

- (instancetype)initWithVertexShaderURL:(NSURL *)vertexShaderURL fragmentShaderURL:(NSURL *)fragmentShaderURL;

- (void)use;

@end

NS_ASSUME_NONNULL_END
