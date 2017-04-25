//
//  ViewController.m
//  WXImagePreview
//
//  Created by wx on 2017/4/25.
//  Copyright © 2017年 wx. All rights reserved.
//

#import "ViewController.h"
#import "WXCollectionViewCell.h"
#import "WXImagePreviewModel.h"
#import "WXImagePreviewController.h"

static NSString  *ImageCellIdentifier = @"ImageCellIdentifier";

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
{    
    NSArray              *_imgArray;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"大图预览";
    
    _imgArray = @[@"wx_pic_1",@"wx_pic_2",@"wx_pic_3",@"wx_pic_4",@"wx_pic_0"];
    
    [self createCollectionView];
}


/**
 创建UICollectionView
 */
- (void)createCollectionView
{
    CGFloat imgWH = ([UIScreen mainScreen].bounds.size.width - 1 * 4)/4.0;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 1.0;
    layout.minimumInteritemSpacing = 1.0;
    layout.itemSize = CGSizeMake(imgWH, imgWH);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    _imgCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) collectionViewLayout:layout];
    _imgCollectionView.backgroundColor = [UIColor whiteColor];
    _imgCollectionView.dataSource = self;
    _imgCollectionView.delegate = self;
    [self.view addSubview:_imgCollectionView];
    
    [_imgCollectionView registerClass:[WXCollectionViewCell class]
           forCellWithReuseIdentifier:ImageCellIdentifier];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _imgArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WXCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ImageCellIdentifier forIndexPath:indexPath];
    
    cell.imgView.image = [UIImage imageNamed:_imgArray[indexPath.row]];

    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        
    for (NSString *picUrl in _imgArray) {
        
        WXImagePreviewModel *aModel = [[WXImagePreviewModel alloc] init];
        aModel.picUrl = picUrl;
        [tempArray addObject:aModel];
    }
    
    WXImagePreviewController *imgPreview = [[WXImagePreviewController alloc] init];
    imgPreview.selIndex = indexPath.row;
    imgPreview.type = ImagePreviewType_List;
    imgPreview.photosArray = tempArray;
    imgPreview.wxCollectionCell = (WXCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

    imgPreview.modalPresentationStyle = UIModalPresentationCustom;
    imgPreview.transitioningDelegate = self;
    imgPreview.modalPresentationCapturesStatusBarAppearance = YES;
    
    [self presentViewController:imgPreview animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
