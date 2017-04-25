//
//  WXImagePreviewController.h
//  WXImagePreview
//
//  Created by wx on 2017/4/25.
//  Copyright © 2017年 wx. All rights reserved.
//

#import "WXBaseViewController.h"
#import "WXImagePreviewModel.h"
#import "WXCollectionViewCell.h"

typedef NS_ENUM(NSInteger,ImagePreviewType) {
    
    ImagePreviewType_List   = 1, //查看列表
};

@interface WXImagePreviewController : WXBaseViewController

@property (nonatomic,assign) NSUInteger         selIndex;
@property (nonatomic,assign) ImagePreviewType   type;
@property (nonatomic,strong) NSMutableArray     *photosArray;

@property (nonatomic,assign) NSInteger          index;
@property (nonatomic,assign) CGRect             endRect;

@property (nonatomic,assign) CGFloat            curOpacity;

@property (nonatomic,strong) WXCollectionViewCell  *wxCollectionCell;

@end
