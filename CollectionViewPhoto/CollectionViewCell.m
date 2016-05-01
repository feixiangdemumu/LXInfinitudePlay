//
//  CollectionViewCell.m
//  CollectionViewPhoto
//
//  Created by Mac on 16/4/19.
//  Copyright © 2016年 jyb. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (void)awakeFromNib {
    _imgView.contentMode = UIViewContentModeScaleAspectFill;
    _imgView.clipsToBounds = YES;
}

@end
