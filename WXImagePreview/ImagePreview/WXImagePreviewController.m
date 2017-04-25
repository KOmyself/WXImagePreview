//
//  WXImagePreviewController.m
//  WXImagePreview
//
//  Created by wx on 2017/4/25.
//  Copyright © 2017年 wx. All rights reserved.
//

#import "WXImagePreviewController.h"
#import "WXImagePreview.h"

const static CGFloat ImageMargin    = 10.0;
const static CGFloat SQNavBarHeight = 64.0;

@interface WXImagePreviewController()<UIScrollViewDelegate,WXImagePreviewDelegate,UIActionSheetDelegate>
{
    UIScrollView            *_imageSV;
    UIView                  *_navView;
    UILabel                 *_navTitle;
    NSInteger               _index;
    NSInteger               _preIndex;
    BOOL                    _navHidden;
    BOOL                    _statusBarHiddden;
    CGFloat                 _toolOriginY;
    NSMutableArray          *_photoViewsArray;
    NSMutableArray          *_photosDataArray;
    CGFloat                 _lastOffset;
    UIView                  *_maskView;
    UIImageView             *_picArrow;
    BOOL                    _isAnimation;
    CGPoint                 _startPoint;
}

@end

@implementation WXImagePreviewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _photosDataArray = self.photosArray;
    
    _curOpacity  = 1.0;
    _navHidden   = NO;
    _statusBarHiddden = NO;
    _index       = self.selIndex;
    _toolOriginY = SQFullScreenHeight - (44 + 15 + 25);
    
    [self initImageSV];
    [self initNavV];
    [self updateTitle];
    [self setCurrentIndex:_index];
    [self scrollToIndex:_index];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        _statusBarHiddden = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    });
}

- (void)initNavV
{
    _navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SQFullScreenWidth, SQNavBarHeight)];
    _navView.backgroundColor = [UIColor clearColor];
    _navView.userInteractionEnabled = YES;
    [self.view addSubview:_navView];
    
    _navTitle = [[UILabel alloc] initWithFrame:CGRectMake(55, 10, SQFullScreenWidth - 55 * 2, 20)];
    _navTitle.backgroundColor = [UIColor clearColor];
    _navTitle.font = [UIFont systemFontOfSize:18.0];
    _navTitle.textAlignment = NSTextAlignmentCenter;
    _navTitle.textColor = [UIColor whiteColor];
    [_navView addSubview:_navTitle];
}

- (void)initImageSV
{
    CGRect frame;
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    
    screenFrame.origin.x -= ImageMargin;
    screenFrame.size.width += (2 * ImageMargin);
    frame = CGRectMake(screenFrame.origin.x, 0, screenFrame.size.width, screenFrame.size.height);
    
    _imageSV = [[UIScrollView alloc] initWithFrame:frame];
    _imageSV.backgroundColor = [UIColor clearColor];
    _imageSV.directionalLockEnabled = YES;
    _imageSV.pagingEnabled = YES;
    _imageSV.bounces = YES;
    _imageSV.delegate = self;
    _imageSV.showsVerticalScrollIndicator = NO;
    _imageSV.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_imageSV];
    
    NSInteger photoCount = _photosDataArray.count;
    if (photoCount == 0) {
        photoCount = 1;
    }
    
    [self setImgSVContentSize:photoCount];
    
    _photoViewsArray = [[NSMutableArray alloc] initWithCapacity:photoCount];
    for (int i = 0; i < photoCount; i++)
    {
        [_photoViewsArray addObject:[NSNull null]];
    }
}

- (void)setImgSVContentSize:(NSInteger)pCount
{
    NSInteger photoCount = pCount;
    if (photoCount == 0) {
        photoCount = 1;
    }
    
    CGSize newSize = CGSizeMake(_imageSV.bounds.size.width * photoCount, _imageSV.bounds.size.height);
    [_imageSV setContentSize:newSize];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return _statusBarHiddden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

/**
 *  更新标题
 */
- (void)updateTitle
{
    NSInteger totalCount = _photosDataArray.count;
    if (totalCount == 0) {
        totalCount = 1;
    }
    _navTitle.text = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)_index+1, (unsigned long)totalCount];
}

/**
 *  消失
 */
- (void)dismissView
{
    if (_statusBarHiddden == YES) {
        
        _statusBarHiddden = NO;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)changeNavToolStatus
{
    _navHidden = !_navHidden;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (_navHidden) {
            
            [UIView animateWithDuration:0.3 animations:^{
                
                _navView.frame = CGRectMake(0, -SQNavBarHeight, SQFullScreenWidth, SQNavBarHeight);
                
            }];
            
        }else{
            
            [UIView animateWithDuration:0.3 animations:^{
                
                _navView.frame = CGRectMake(0, 0, SQFullScreenWidth, SQNavBarHeight);
                
            }];
        }
        
    });
}

/**
 *  设置当前页照片视图并销毁前后视图
 *
 *  @param newIndex 当前照片索引
 */
- (void)setCurrentIndex:(NSInteger)newIndex
{
    _index = newIndex;
    
    if (_index < 0 || _index >= _photosDataArray.count)
    {
        return;
    }
    
    [self loadPhoto:_index];
    [self loadPhoto:_index + 1];
    [self loadPhoto:_index - 1];
    [self unloadPhoto:_index + 2];
    [self unloadPhoto:_index - 2];
}

- (void)loadPhoto:(NSInteger)index
{
    if (index < 0 || index >= _photosDataArray.count)
    {
        return;
    }
    
    id currentPhotoView = [_photoViewsArray objectAtIndex:index];
    if (NO == [currentPhotoView isKindOfClass:[WXImagePreview class]])
    {
        CGRect frame = [self frameForPageAtIndex:index];
        
        WXImagePreviewModel *model = [_photosDataArray objectAtIndex:index];
        
        //UIImage *image = nil;
        UIImage *image = [UIImage imageNamed:model.picUrl];
        
        WXImagePreview *imagePreview = [[WXImagePreview alloc] initWithFrame:frame];
        imagePreview.delegate = self;
        [imagePreview updateWithImage:image imageUrl:nil];
        imagePreview.tag = 1000 + index;
        [_imageSV addSubview:imagePreview];
        
        [_photoViewsArray replaceObjectAtIndex:index withObject:imagePreview];
    }
}

- (void)unloadPhoto:(NSInteger)index
{
    if (index < 0 || index >= _photosDataArray.count)
    {
        return;
    }
    
    id currentPhotoView = [_photoViewsArray objectAtIndex:index];
    if ([currentPhotoView isKindOfClass:[WXImagePreview class]])
    {
        [currentPhotoView removeFromSuperview];
        [_photoViewsArray replaceObjectAtIndex:index withObject:[NSNull null]];
    }
}

- (void)resetPhotoArray
{
    for (int i = 0; i < _photoViewsArray.count; ++i) {
        
        id currentPhotoView = [_photoViewsArray objectAtIndex:i];
        if ([currentPhotoView isKindOfClass:[WXImagePreview class]])
        {
            [currentPhotoView removeFromSuperview];
            [_photoViewsArray replaceObjectAtIndex:i withObject:[NSNull null]];
        }
    }
    
    NSInteger photoCount = _photosDataArray.count;
    if (photoCount == 0) {
        photoCount = 1;
    }
    
    [self setImgSVContentSize:photoCount];
    
    [_photoViewsArray removeAllObjects];
    _photoViewsArray = [NSMutableArray arrayWithCapacity:photoCount];
    for (int i = 0; i < photoCount; i++)
    {
        [_photoViewsArray addObject:[NSNull null]];
    }
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index
{
    CGRect bounds = [_imageSV bounds];
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * ImageMargin);
    pageFrame.origin.x = (bounds.size.width * index) + ImageMargin;
    
    return pageFrame;
}

- (void)scrollToIndex:(NSInteger)index
{
    CGRect frame = _imageSV.frame;
    
    frame.origin.x = frame.size.width * index;
    frame.origin.y = 0;
    
    [_imageSV scrollRectToVisible:frame animated:NO];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    CGFloat curOffset = scrollView.contentOffset.x;
    float fractionalPage = curOffset / pageWidth;
    NSInteger page = floor(fractionalPage);
    if (page != _index && fabs(curOffset - _lastOffset) > 200.0)
    {
        [self setCurrentIndex:page];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_index >= 0)
    {
        [self updateTitle];
        _lastOffset = scrollView.contentOffset.x;
    }
    
    if (_index != _preIndex)
    {
        WXImagePreview *imagePreview = (WXImagePreview *)[_imageSV viewWithTag:1000 + _preIndex];
        [imagePreview resetZoomScale];
        
        _preIndex = _index;
    }
}

- (void)imagePreviewClick:(WXImagePreview *)imagePreview
{
    WXImagePreview *curPreview = _photoViewsArray[_index];
    self.endRect = curPreview.finalPicRect;
    
    [self dismissView];
}

- (void)imagePreviewLongPress:(WXImagePreview *)imagePreview
{
    [self showAlertView];
}

- (void)imagePreviewDoubleClick:(WXImagePreview *)imagePreview
{
    
}

- (void)imagePreviewPanBeganChange:(WXImagePreview *)imagePreview
{
    //手势拖动时，隐藏toolview
    if (_navHidden == NO) {
        
        //[self changeNavToolStatus];
    }
    
    if (_statusBarHiddden == YES) {
        
        _statusBarHiddden = NO;
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)imagePreviewPanChangeBgOpacity:(CGFloat)opacity
{
    self.curOpacity = opacity;
    
    self.view.backgroundColor = HEXRGBACOLOR(0x000000, self.curOpacity);
}

- (void)imagePreviewPanDown:(WXImagePreview *)imagePreview endRect:(CGRect)endRect isDisMiss:(BOOL)disMiss
{
    self.endRect = endRect;
    
    if (disMiss) {
        
        [self dismissView];
        
    }else{
        
        if (_statusBarHiddden == NO) {
            
            _statusBarHiddden = YES;
            [self setNeedsStatusBarAppearanceUpdate];
        }
    }
}

#pragma mark - 保存图片

- (void)showAlertView
{
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"取消", nil)
                                          destructiveButtonTitle:NSLocalizedString(@"保存到相册" , nil)
                                               otherButtonTitles:nil, nil];
    
    sheet.actionSheetStyle = UIBarStyleBlackTranslucent;
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        WXImagePreview *imgPreview = _photoViewsArray[_index];
        [self loadImageFinished:imgPreview.imageView.image];
    }
}

- (void)loadImageFinished:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error == nil) {
        
    }
    
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
}

@end
