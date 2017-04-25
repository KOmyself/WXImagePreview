//
//  WXBaseViewController.m
//  WXImagePreview
//
//  Created by wx on 2017/4/25.
//  Copyright © 2017年 wx. All rights reserved.
//

#import "WXBaseViewController.h"
#import "WXCustomDismissAnimation.h"
#import "WXCustomPresentAnimation.h"

@interface WXBaseViewController ()
{
    WXCustomPresentAnimation    *_presentAnimation;
    WXCustomDismissAnimation    *_dismissAnimation;
}

@end

@implementation WXBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _presentAnimation = [[WXCustomPresentAnimation alloc] init];
    _dismissAnimation = [[WXCustomDismissAnimation alloc] init];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return _presentAnimation;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return _dismissAnimation;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
