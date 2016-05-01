//
//  FrameModel.h
//  CollectionViewPhoto
//
//  Created by Mac on 16/4/19.
//  Copyright © 2016年 jyb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class FrameModel;
@interface FrameModel : NSObject

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

+ (FrameModel *)getFrameWithView:(UIView *)view;

@end
