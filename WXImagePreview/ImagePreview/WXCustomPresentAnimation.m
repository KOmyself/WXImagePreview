//
//  WXCustomPresentAnimation.m
//  WXImagePreview
//
//  Created by wx on 2017/4/25.
//  Copyright © 2017年 wx. All rights reserved.
//

#import "WXCustomPresentAnimation.h"
#import "WXImagePreviewController.h"
#import "ViewController.h"

@implementation WXCustomPresentAnimation

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return  0.25;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    //目标VC
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];
    toVC.view.frame = finalFrame;
    toVC.view.alpha = 0.0;
    
    //容器View
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toVC.view];
    
    //起始VC
    UIViewController *rootVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *fromVC = nil;
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        
        UINavigationController *nav = ((UITabBarController *)rootVC).selectedViewController;
        fromVC = nav.topViewController;
        
    }else if ([rootVC isKindOfClass:[UINavigationController class]]){
        
        fromVC = ((UINavigationController *)rootVC).topViewController;
        
    }else{
        
        fromVC = rootVC;
    }
    
    //计算相对rect
    UIImageView *picImgView = nil;
    
    WXImagePreviewController *destVC = (WXImagePreviewController *)toVC;
    
    //查看大图对应的小图的位置
    if (destVC.type == ImagePreviewType_List) {
        
        ViewController *originVC = (ViewController *)fromVC;
        
        NSInteger curIndex = destVC.index;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:curIndex inSection:0];
        WXCollectionViewCell *destCell = (WXCollectionViewCell *)[originVC.imgCollectionView cellForItemAtIndexPath:indexPath];
        if (destCell != nil) {
            
            picImgView = [destCell viewWithTag:100];
        }
    }
    
    CGRect newRect = [picImgView convertRect:picImgView.bounds toView:nil];
    
    //创建动画view
    UIView *animateBgView = [[UIView alloc] initWithFrame:finalFrame];
    animateBgView.backgroundColor = HEXRGBCOLOR(0x000000);
    [containerView addSubview:animateBgView];
    
    UIImageView *animateView = [[UIImageView alloc] init];
    animateView.image = picImgView.image;
    animateView.frame = newRect;
    animateView.contentMode = UIViewContentModeScaleAspectFill;
    animateView.clipsToBounds = YES;
    [animateBgView addSubview:animateView];
    
    //计算ImageView大图frame
    CGFloat newWidth = SQFullScreenWidth;
    CGFloat newHeight = newWidth * picImgView.image.size.height / picImgView.image.size.width;
    CGFloat newY = 0;
    if (picImgView.image.size.height / picImgView.image.size.width > SQFullScreenHeight / SQFullScreenWidth){
        
        newY = 0;
        
    }else{
        
        newY = ABS(SQFullScreenHeight - newHeight)/2.0;
    }
    CGRect finalPicRect = CGRectMake(0, newY, newWidth, newHeight);
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration animations:^{
        
        animateView.frame = finalPicRect;
        
    } completion:^(BOOL finished) {
        
        [transitionContext completeTransition:YES];
        [UIView animateWithDuration:duration / 2.0 animations:^{
            
            toVC.view.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            
            [animateBgView removeFromSuperview];
        }];
    }];
}

@end
