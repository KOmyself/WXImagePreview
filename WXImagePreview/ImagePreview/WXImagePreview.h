//
//  WXImagePreview.h
//  WXImagePreview
//
//  Created by wx on 2017/4/25.
//  Copyright © 2017年 wx. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WXImagePreview;

@protocol WXImagePreviewDelegate <NSObject>

- (void)imagePreviewClick:(WXImagePreview *)imagePreview;
- (void)imagePreviewDoubleClick:(WXImagePreview *)imagePreview;
- (void)imagePreviewLongPress:(WXImagePreview *)imagePreview;
- (void)imagePreviewPanBeganChange:(WXImagePreview *)imagePreview;
- (void)imagePreviewPanChangeBgOpacity:(CGFloat)opacity;
- (void)imagePreviewPanDown:(WXImagePreview *)imagePreview endRect:(CGRect)endRect isDisMiss:(BOOL)disMiss;

@end

@interface WXImagePreview : UIView

@property (nonatomic,weak) id<WXImagePreviewDelegate>   delegate;

@property (nonatomic,strong) UIScrollView           *scrollView;
@property (nonatomic,strong) UIImageView            *imageView;
@property (nonatomic,assign) CGRect                 finalPicRect;

/**
 *  先显示image，如果imageUrl不为空则再通过imageUrl加载
 *
 *  @param image            图片（UIImage *）
 *  @param imageUrl         图片url（NSString *）
 */
- (void)updateWithImage:(UIImage *)image imageUrl:(NSString *)imageUrl;

- (void)resetZoomScale;

- (void)removePieProgressView;

@end
