//
//  PhotoViewController.m
//  CollectionViewPhoto
//
//  Created by Mac on 16/4/19.
//  Copyright © 2016年 jyb. All rights reserved.
//

#import "PhotoViewController.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "FrameModel.h"
#import "MBProgressHUD.h"

#define SCREEN_WIDTH            [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT           [[UIScreen mainScreen] bounds].size.height

@interface PhotoViewController ()<UIScrollViewDelegate>
{
    BOOL            _large;
    UIScrollView    *_zoomingScrollView;
    CGFloat         _contentOffsetX;
    UIScrollView    *scroll;
}

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH+20, SCREEN_HEIGHT)];
    scroll.tag = 55;
    scroll.delegate = self;
    scroll.backgroundColor = [UIColor blackColor];
    scroll.contentSize = CGSizeMake((SCREEN_WIDTH+20)*5, SCREEN_HEIGHT);
    scroll.pagingEnabled = YES;
    [self.view addSubview:scroll];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [scroll setContentOffset:CGPointMake(self.index * (SCREEN_WIDTH+20), 0) animated:NO];
    _contentOffsetX = scroll.contentOffset.x;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    for (int i = 0; i < 5; i ++) {
        
        UIScrollView *scl = [[UIScrollView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH+20)*i, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        scl.tag = 44;
        scl.delegate = self;
        scl.minimumZoomScale = 1.0;
        scl.maximumZoomScale = 2.0;
        scl.decelerationRate = 0.1;
        scl.backgroundColor = [UIColor blackColor];
        [scroll addSubview:scl];
        
        UIImageView *imgView = [[UIImageView alloc] init];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:imgView animated:NO];
        hud.mode = MBProgressHUDModeDeterminate;
        [imgView addSubview:hud];
        
        [SDWebImageDownloader.sharedDownloader setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
        
        [imgView sd_setImageWithURL:[self.urlArray objectAtIndex:i] placeholderImage:nil options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
            hud.progress = (float)receivedSize / (float)expectedSize;
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            [hud hide:NO];
        }];
        
        
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.clipsToBounds = YES;
        imgView.userInteractionEnabled = YES;
        imgView.tag = 666;
        [scl addSubview:imgView];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [imgView addGestureRecognizer:doubleTap];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        singleTap.numberOfTapsRequired = 1;
        [imgView addGestureRecognizer:singleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        if (i != self.index) {
            
            imgView.frame = CGRectMake(0, SCREEN_HEIGHT/4, SCREEN_WIDTH, SCREEN_HEIGHT/2);
            
        }else{
            
            CGRect frame = CGRectMake(0, SCREEN_HEIGHT/4, SCREEN_WIDTH, SCREEN_HEIGHT/2);
            imgView.frame = self.imgFrame;
            [UIView animateWithDuration:0.2 animations:^{
                imgView.frame = frame;
            } completion:^(BOOL finished) {
                
            }];
        }
        
    }
}

- (void)singleTap:(UITapGestureRecognizer *)gesture
{
    UIImageView *imgView = (UIImageView *)gesture.view;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    self.view.backgroundColor = [UIColor clearColor];
    scroll.backgroundColor = [UIColor clearColor];
    [window addSubview:imgView];
    
    [UIView animateWithDuration:0.25 animations:^{
        
        imgView.frame = self.imgFrame;
        
    } completion:^(BOOL finished) {
        
        if (_completedBlock) {
            _completedBlock();
        }
        
        [imgView removeFromSuperview];
    }];
    
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}

- (void)doubleTap:(UITapGestureRecognizer *)gesture
{
    UIScrollView *scl = (UIScrollView *)gesture.view.superview;
    
    if (scl.zoomScale == scl.maximumZoomScale) {
        
        [scl setZoomScale:1.0 animated:YES];
        _large = NO;
        _zoomingScrollView = nil;
        return;
    }
    
    if (_large) {
        
        [scl setZoomScale:1.0 animated:YES];
        _large = NO;
        _zoomingScrollView = nil;
        
    }else{
        
        CGPoint location = [gesture locationInView:gesture.view];
        [scl zoomToRect:CGRectMake(location.x, location.y, 1, 1) animated:YES];
        _large = YES;
        _zoomingScrollView = scl;
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return (UIImageView *)[scrollView viewWithTag:666];
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
    static CGFloat x,y;
    
    UIScrollView *superscl = (UIScrollView *)scrollView.superview;
    
    CGFloat xcenter = scrollView.center.x-superscl.contentOffset.x , ycenter = scrollView.center.y;
    
    if (_zoomingScrollView == nil) {
        x = xcenter;
        y = ycenter;
    }else{
        xcenter = x;
        ycenter = y;
        _zoomingScrollView = nil;
    }
    
    xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : xcenter;
    
    ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : ycenter;
    
    [[scrollView viewWithTag:666] setCenter:CGPointMake(xcenter, ycenter)];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag == 55) {
        
        if (scrollView.contentOffset.x != _contentOffsetX) {
            _contentOffsetX = scrollView.contentOffset.x;
            
            if (_zoomingScrollView) {
                [_zoomingScrollView setZoomScale:1.0 animated:YES];
                _large = NO;
            }
        }
        
        self.index = (NSInteger)(_contentOffsetX / (SCREEN_WIDTH+20));
        
        FrameModel *frame = [self.frameArray objectAtIndex:self.index];
        
        self.imgFrame = CGRectMake(frame.x, frame.y, frame.width, frame.height);
    }
    
    if (_indexBlock) {
        _indexBlock(_index);
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
