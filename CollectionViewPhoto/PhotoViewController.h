//
//  PhotoViewController.h
//  CollectionViewPhoto
//
//  Created by Mac on 16/4/19.
//  Copyright © 2016年 jyb. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CurrentIndexBlock)(NSInteger);
typedef void(^AnimationCompleted)(void);

@interface PhotoViewController : UIViewController

@property (nonatomic, assign) CGRect imgFrame;
@property (nonatomic ,strong) NSData *imgData;
@property (nonatomic, strong) NSArray *frameArray;
@property (nonatomic, strong) NSArray *urlArray;
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, copy) CurrentIndexBlock indexBlock;
@property (nonatomic, copy) AnimationCompleted completedBlock;

@end
