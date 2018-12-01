//
//  ScissorViewController.m
//  FaceCamera
//
//  Created by  zcating on 2018/11/7.
//  Copyright © 2018 zcat. All rights reserved.
//

#import "ScissorViewController.h"

@interface ScissorViewController ()

@end

@implementation ScissorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    self.view.layer.cornerRadius = 5;
}


- (IBAction)changeRatio_4To3:(id)sender {
    if (self.block != nil) {
        self.block(4 / 3.0);
    }
}

- (IBAction)changeRatio_16To9:(id)sender {
    if (self.block != nil) {
        self.block(16 / 9.0);
    }
}

- (IBAction)changeRatio_1To1:(id)sender {
    if (self.block != nil) {
        self.block(1.0);
    }
}

- (IBAction)changeRatio_Round:(id)sender {
    if (self.block != nil) {
        self.block(1);
    }
}


@end
