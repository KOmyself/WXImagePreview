//
//  WXPieProgressView.m
//  WXImagePreview
//
//  Created by wx on 2017/4/25.
//  Copyright © 2017年 wx. All rights reserved.
//

#import "WXPieProgressView.h"

const CGFloat kFrameMargin  = 4.0;

@interface WXPieProgressView()
{
    CGFloat  _curProgress;
}

@end

@implementation WXPieProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        _curProgress = 0.0;
    }
    return self;
}

- (void)updateProgress:(CGFloat)progress
{
    _curProgress = progress;
    [self setNeedsDisplay];
}

#pragma mark draw progress
- (void)drawRect:(CGRect)rect {
    
    [self drawCircle:rect];
    [self drawFillPie:rect margin:kFrameMargin color:HEXRGBACOLOR(0xffffff, 0.6) percentage:_curProgress];
}

- (void)drawFillPie:(CGRect)rect margin:(CGFloat)margin color:(UIColor *)color percentage:(CGFloat)percentage {
    
    CGFloat radius = MIN(CGRectGetHeight(rect), CGRectGetWidth(rect)) * 0.5 - margin - 1;
    CGFloat centerX = CGRectGetWidth(rect) * 0.5;
    CGFloat centerY = CGRectGetHeight(rect) * 0.5;
    
    CGContextRef cgContext = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(cgContext, [color CGColor]);
    CGContextMoveToPoint(cgContext, centerX, centerY);
    CGContextAddArc(cgContext, centerX, centerY, radius, (CGFloat) -M_PI_2, (CGFloat) (-M_PI_2 + M_PI * 2 * percentage), 0);
    CGContextClosePath(cgContext);
    CGContextFillPath(cgContext);
}

- (void)drawCircle:(CGRect)rect
{
    CGFloat radius = rect.size.width / 2.0 - 1;
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path addArcWithCenter:self.center radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    path.lineWidth = 1.5;
    [HEXRGBACOLOR(0xffffff, 0.6) setStroke];
    [path stroke];
}

@end
