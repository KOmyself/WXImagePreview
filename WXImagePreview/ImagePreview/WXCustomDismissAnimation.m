//
//  WXCustomDismissAnimation.m
//  WXImagePreview
//
//  Created by wx on 2017/4/25.
//  Copyright © 2017年 wx. All rights reserved.
//

#import "WXCustomDismissAnimation.h"
#import "WXImagePreviewController.h"
#import "ViewController.h"

@implementation WXCustomDismissAnimation

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.25;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    //目标VC
    UIViewController *rootVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *toVC = nil;
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        
        UINavigationController *nav = ((UITabBarController *)rootVC).selectedViewController;
        toVC = nav.topViewController;
        
    }else if ([rootVC isKindOfClass:[UINavigationController class]]){
        
        toVC = ((UINavigationController *)rootVC).topViewController;
        
    }else{
        
        toVC = rootVC;
    }
    
    //容器View
    UIView *containerView = [transitionContext containerView];
    
    //起始VC
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    fromVC.view.alpha = 0.0;
    
    //计算相对rect
    UIImageView *picImgView = [[UIImageView alloc] init];
    CGRect  endRect = CGRectZero;
    CGFloat  curOpacity = 1.0;
    
    WXImagePreviewController *originVC = (WXImagePreviewController *)fromVC;
    endRect = originVC.endRect;
    curOpacity = originVC.curOpacity;
    
    //查找当前大图对应位置的小图
    if (originVC.type == ImagePreviewType_List) {
        
        ViewController *destVC = (ViewController *)toVC;
        
        NSInteger curIndex = originVC.index;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:curIndex inSection:0];
        WXCollectionViewCell *destCell = (WXCollectionViewCell *)[destVC.imgCollectionView cellForItemAtIndexPath:indexPath];
        if (destCell != nil) {
            
            picImgView = [destCell viewWithTag:100];
        }
    }
    
    CGRect newRect = [picImgView convertRect:picImgView.bounds toView:nil];
    
    //创建动画view
    UIView *animateBgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    animateBgView.backgroundColor = HEXRGBACOLOR(0x000000, curOpacity);
    [containerView addSubview:animateBgView];
    
    UIImageView *animateView = [[UIImageView alloc] initWithFrame:endRect];
    animateView.image = picImgView.image;
    animateView.contentMode = UIViewContentModeScaleAspectFill;
    animateView.clipsToBounds = YES;
    [animateBgView addSubview:animateView];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration animations:^{
        
        animateView.frame = newRect;
        animateBgView.backgroundColor = HEXRGBACOLOR(0x000000, 0.0);
        
    } completion:^(BOOL finished) {
        
        [transitionContext completeTransition:YES];
        [animateBgView removeFromSuperview];
    }];
}

@end
