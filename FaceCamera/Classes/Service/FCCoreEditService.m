//
//  FCCoreEditService.m
//  FaceCamera
//
//  Created by  zcating on 2018/12/23.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "FCCoreEditService.h"

#import <Photos/Photos.h>

@implementation FCCoreEditService

-(void)saveImage:(UIImage *)image {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"Save image success");
            // TODO: Maybe add shared function for some social paltform ?
            
        } else {
            NSLog(@"Save image failed: %@", error);
        }
    }];
}

@end
