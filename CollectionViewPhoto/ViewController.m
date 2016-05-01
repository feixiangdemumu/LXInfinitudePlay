//
//  ViewController.m
//  CollectionViewPhoto
//
//  Created by Mac on 16/4/19.
//  Copyright © 2016年 jyb. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewCell.h"
#import "PhotoViewController.h"
#import "UIImageView+WebCache.h"
#import "FrameModel.h"

@interface ViewController () <UICollectionViewDataSource,UICollectionViewDelegate>
{
    UICollectionView *_collectionView;
    NSArray          *_urlArray;
    NSArray          *_bigUrlArray;
    NSMutableArray   *_frameArray;
    UIView           *_coverView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    
    [self loadSubviews];
}

- (void)initData
{
    _urlArray = @[@"http://b.hiphotos.baidu.com/image/h%3D200/sign=ca449e25cdea15ce5eeee70986013a25/fcfaaf51f3deb48f452b517ef41f3a292cf578d4.jpg",
                  @"http://f.hiphotos.baidu.com/image/h%3D200/sign=658bab6a553d269731d30f5d65fab24f/0dd7912397dda1446853fa12b6b7d0a20cf4863c.jpg",
                  @"http://g.hiphotos.baidu.com/image/h%3D200/sign=b00abd199a510fb367197097e932c893/a8014c086e061d955cbcc4987ff40ad163d9ca9c.jpg",
                  @"http://b.hiphotos.baidu.com/image/h%3D200/sign=beeff5de211f95cab9f595b6f9167fc5/83025aafa40f4bfbd2086ef4074f78f0f63618b1.jpg",
                  @"http://d.hiphotos.baidu.com/image/h%3D200/sign=1acc1ac4524e9258b93481eeac83d1d1/b7fd5266d0160924b8f750bbd00735fae7cd34bb.jpg"];
    
    _bigUrlArray = @[@"http://img.article.pchome.net/00/43/41/54/pic_lib/wm/3.jpg",
                     @"http://f.hiphotos.baidu.com/image/h%3D200/sign=658bab6a553d269731d30f5d65fab24f/0dd7912397dda1446853fa12b6b7d0a20cf4863c.jpg",
                     @"http://img.shu163.com/uploadfiles/wallpaper/2010/6/2010073106154112.jpg",
                     @"http://c.hiphotos.bdimg.com/album/w%3D2048/sign=a3a806ef6609c93d07f209f7ab05fadc/d50735fae6cd7b89f4ee76620e2442a7d8330e54.jpg",
                     @"http://h.hiphotos.baidu.com/image/pic/item/8694a4c27d1ed21b61797af2ae6eddc451da3f70.jpg"];
    
    _frameArray = [NSMutableArray array];
}

- (void)loadSubviews
{
    CGFloat width  = self.view.bounds.size.width;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((width-40)/3, (width-40)/3);
    layout.sectionInset = UIEdgeInsetsMake(20, 20, 0, 20);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    [self.view addSubview:_collectionView];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    // 有时候SD会下载失败，需要添加这个
    [SDWebImageDownloader.sharedDownloader setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:[_urlArray objectAtIndex:indexPath.row]] placeholderImage:[UIImage imageNamed:@"loading.png"]];
    
    FrameModel *frame = [FrameModel getFrameWithView:cell];
    
    [_frameArray addObject:frame];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    CGRect rect = cell.frame;
    
    if (_coverView == nil) {
        _coverView = [[UIView alloc] initWithFrame:cell.bounds];
        _coverView.backgroundColor = [UIColor whiteColor];
    }
    [cell addSubview:_coverView];
    
    PhotoViewController *photoVC = [[PhotoViewController alloc] init];
    photoVC.urlArray = _bigUrlArray;
    photoVC.imgFrame = rect;
    photoVC.index = indexPath.row;
    photoVC.frameArray = [_frameArray copy];
    photoVC.imgData = [self getImageDataWithUrl:[_urlArray objectAtIndex:indexPath.row]];
    [self presentViewController:photoVC animated:NO completion:nil];
    
    photoVC.indexBlock = ^(NSInteger index){
        
        NSIndexPath *indexP = [NSIndexPath indexPathForItem:index inSection:0];
        CollectionViewCell *cel = (CollectionViewCell *)[collectionView cellForItemAtIndexPath:indexP];
        [cel addSubview:_coverView];
    };
    
    [photoVC setCompletedBlock:^(void){
        [_coverView removeFromSuperview];
        _coverView = nil;
    }];
}

- (NSData *)getImageDataWithUrl:(NSString *)url
{
    NSData *imageData = nil;
    BOOL isExit = [[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]];
    if (isExit) {
        NSString *cacheImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:url]];
        if (cacheImageKey.length) {
            NSString *cacheImagePath = [[SDImageCache sharedImageCache] defaultCachePathForKey:cacheImageKey];
            if (cacheImagePath.length) {
                imageData = [NSData dataWithContentsOfFile:cacheImagePath];
            }
        }
    }
    if (!imageData) {
        imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    }
    
    return imageData;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
































