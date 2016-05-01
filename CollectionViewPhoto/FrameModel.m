//
//  FrameModel.m
//  CollectionViewPhoto
//
//  Created by Mac on 16/4/19.
//  Copyright © 2016年 jyb. All rights reserved.
//

#import "FrameModel.h"

@implementation FrameModel

+ (FrameModel *)getFrameWithView:(UIView *)view
{
    FrameModel *frame = [[FrameModel alloc] init];
    frame.x = view.frame.origin.x;
    frame.y = view.frame.origin.y;
    frame.width = view.frame.size.width;
    frame.height = view.frame.size.height;
    
    return frame;
}

@end
