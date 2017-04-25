//
//  WXImagePreview.m
//  WXImagePreview
//
//  Created by wx on 2017/4/25.
//  Copyright © 2017年 wx. All rights reserved.
//

#import "WXImagePreview.h"
//#import "UIImageView+WebCache.h"
#import "WXPieProgressView.h"

const CGFloat MaxScale     = 4.0;
const CGFloat DoubleScale  = 2.5;
const CGFloat BufferHeight = 2.0;

@interface WXImagePreview()<UIGestureRecognizerDelegate,UIScrollViewDelegate>
{
    UIView             *_pieBgView;
    WXPieProgressView  *_pieProgressView;
    CGPoint             _startPoint;
    CGPoint             _scrollOffset;
}

@end

@implementation WXImagePreview

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imagePreviewClicked)];
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imagePreviewDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        
        //[singleTap requireGestureRecognizerToFail:doubleTap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(imagePreviewPan:)];
        pan.delegate = self;
        [self addGestureRecognizer:pan];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imagePreviewLongPressed:)];
        [self addGestureRecognizer:longPress];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.scrollView.delegate = self;
        self.scrollView.minimumZoomScale = 1.0;
        self.scrollView.maximumZoomScale = MaxScale;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        [self addSubview:self.scrollView];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self.scrollView addSubview:self.imageView];
    }
    
    return self;
}

- (void)createPieView
{
    if (_pieBgView == nil) {
        
        _pieBgView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - 70)/2.0, (self.frame.size.height - 70)/2.0, 70, 70)];
        _pieBgView.backgroundColor = [UIColor clearColor];
        [self addSubview:_pieBgView];
    }
    
    if (_pieProgressView == nil) {
        
        _pieProgressView = [[WXPieProgressView alloc] initWithFrame:CGRectMake(0, 0, _pieBgView.bounds.size.width, _pieBgView.bounds.size.height)];
        _pieProgressView.backgroundColor = [UIColor clearColor];
        [_pieBgView addSubview:_pieProgressView];
    }
}

- (void)updateWithImage:(UIImage *)image imageUrl:(NSString *)imageUrl
{
    if (imageUrl != nil && imageUrl.length > 0)
    {
        [self createPieView];
        
        [_pieProgressView updateProgress:0.05];
        
        /*[self.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:image options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *targetURL) {
            
            if (expectedSize > 0) {
                
                CGFloat revSize = (CGFloat)receivedSize;
                CGFloat tolSize = (CGFloat)expectedSize;
                
                CGFloat p = revSize / tolSize;
                
                if (p >= 1) {
                    
                    p = 1;
                    
                }else if (p < 0.05){
                    
                    p = 0.05;
                }
                [_pieProgressView updateProgress:p];
            }
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            [_pieProgressView updateProgress:1.0];
            [self removePieProgressView];
            
            if (image != nil)
            {
                [self resetImgViewFrame:image];
            }
            
        }];*/
    }
    else
    {
        self.imageView.image = image;
        
        [self resetImgViewFrame:image];
    }
}

- (void)resetImgViewFrame:(UIImage *)image
{
    if (image.size.height / image.size.width > self.frame.size.height / self.frame.size.width)
    {
        CGFloat newHeight = (SQFullScreenWidth / image.size.width) * image.size.height;
        _imageView.frame = CGRectMake(0, 0, SQFullScreenWidth, newHeight);
        _scrollView.contentSize = CGSizeMake(SQFullScreenWidth, newHeight + BufferHeight);
        
    }else{
        
        CGFloat newWidth = SQFullScreenWidth;
        CGFloat newHeight = newWidth * image.size.height / image.size.width;
        _imageView.frame = CGRectMake(0, 0, newWidth, newHeight);
        _imageView.center = _scrollView.center;
        _scrollView.contentSize = CGSizeMake(SQFullScreenWidth, SQFullScreenHeight);
    }
    
    _finalPicRect = _imageView.frame;
}

- (void)removePieProgressView
{
    if (_pieProgressView) {
        
        [_pieProgressView removeFromSuperview];
        _pieProgressView = nil;
    }
    
    if (_pieBgView) {
        
        [_pieBgView removeFromSuperview];
        _pieBgView = nil;
    }
}

- (void)resetZoomScale
{
    self.scrollView.zoomScale = 1.0;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    CGFloat zs = scrollView.zoomScale;
    zs = MAX(zs, 1.0);
    zs = MIN(zs, MaxScale);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    scrollView.zoomScale = zs;
    [UIView commitAnimations];
}

- (void)imagePreviewDoubleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (self.scrollView.zoomScale > 1.0)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        self.scrollView.zoomScale = 1.0;
        [UIView commitAnimations];
    }
    else
    {
        CGPoint loc = [gestureRecognizer locationInView:self.scrollView];
        float newScale = DoubleScale;
        
        CGRect zoomRect;
        zoomRect.size.height = self.scrollView.frame.size.height / newScale;
        zoomRect.size.width  = self.scrollView.frame.size.width  / newScale;
        zoomRect.origin.x = loc.x - (zoomRect.size.width  / 2.0);
        zoomRect.origin.y = loc.y - (zoomRect.size.height / 2.0);
        
        [self.scrollView zoomToRect:zoomRect animated:YES];
        
        if ([self.delegate respondsToSelector:@selector(imagePreviewDoubleClick:)]) {
            
            [self.delegate imagePreviewDoubleClick:self];
        }
    }
}

- (void)imagePreviewClicked
{
    if ([self.delegate respondsToSelector:@selector(imagePreviewClick:)])
    {
        [self.delegate imagePreviewClick:self];
    }
}

- (void)imagePreviewLongPressed:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        if ([self.delegate respondsToSelector:@selector(imagePreviewLongPress:)])
        {
            [self.delegate imagePreviewLongPress:self];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
    CGPoint p = [pan translationInView:self.superview];
    
    if (p.x > 0 || p.x < 0) {
        
        return NO;
    }
    
    return YES;
}

- (void)imagePreviewPan:(UIPanGestureRecognizer *)gesture
{
    CGFloat curOpacity = 1.0;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        _startPoint = self.imageView.center;
        
        if ([self.delegate respondsToSelector:@selector(imagePreviewPanBeganChange:)]) {
            
            [self.delegate imagePreviewPanBeganChange:self];
        }
        
    }else if (gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint p = [gesture translationInView:self.imageView];
        
        if (p.y > 0) {
            
            curOpacity = 1.0 - p.y / SQFullScreenHeight;
            self.imageView.bounds = CGRectMake(0, 0, _finalPicRect.size.width - ABS(p.x)/3.0, _finalPicRect.size.height - p.y/3.0);
        }
        
        self.imageView.center = CGPointMake(_startPoint.x + p.x, _startPoint.y + p.y);
        
        if ([self.delegate respondsToSelector:@selector(imagePreviewPanChangeBgOpacity:)]) {
            
            [self.delegate imagePreviewPanChangeBgOpacity:curOpacity];
        }
        
    }
    else if (gesture.state == UIGestureRecognizerStateEnded){
        
        CGPoint p = [gesture translationInView:self.superview];
        
        if (p.y > SQFullScreenHeight * 0.1) {
            
            if ([self.delegate respondsToSelector:@selector(imagePreviewPanDown:endRect:isDisMiss:)]) {
                
                [self.delegate imagePreviewPanDown:self endRect:self.imageView.frame isDisMiss:YES];
            }
            
        }else{
            
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                
                self.imageView.bounds = CGRectMake(0, 0, _finalPicRect.size.width, _finalPicRect.size.height);
                self.imageView.center = CGPointMake(_startPoint.x, _startPoint.y);
                
                if ([self.delegate respondsToSelector:@selector(imagePreviewPanChangeBgOpacity:)]) {
                    
                    [self.delegate imagePreviewPanChangeBgOpacity:1.0];
                }
                
            } completion:^(BOOL finished) {
                
                if ([self.delegate respondsToSelector:@selector(imagePreviewPanDown:endRect:isDisMiss:)]) {
                    
                    [self.delegate imagePreviewPanDown:self endRect:_finalPicRect isDisMiss:NO];
                }
                
            }];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _scrollOffset = scrollView.contentOffset;
    
    CGFloat curOpacity = 1.0;
    
    if (_scrollOffset.y < 0) {
        
        curOpacity = 1.0 - ABS(_scrollOffset.y) / SQFullScreenHeight;
    }
    
    if ([self.delegate respondsToSelector:@selector(imagePreviewPanChangeBgOpacity:)]) {
        
        [self.delegate imagePreviewPanChangeBgOpacity:curOpacity];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGRect endRect = CGRectMake(_scrollOffset.x, ABS(_scrollOffset.y),_finalPicRect.size.width,_finalPicRect.size.height);
    
    if (_scrollOffset.y < -SQFullScreenHeight * 0.1) {
        
        if ([self.delegate respondsToSelector:@selector(imagePreviewPanDown:endRect:isDisMiss:)]) {
            
            [self.delegate imagePreviewPanDown:self endRect:endRect isDisMiss:YES];
        }
    }
}


@end
