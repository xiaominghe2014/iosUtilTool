//
//  XUIUtils.m
//  iosTest
//
//  Created by Ximena on 2019/4/28.
//  Copyright © 2019 xiaoming. All rights reserved.
//

#import "XUIUtils.h"

@implementation UIImage (extension)

+ (UIImage *)imageFromColor:(UIColor *)color{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

-(void) setSudoku:(UIEdgeInsets)capInsets{
    [self resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch];
}


@end


@implementation UIImageView (extension)

- (void)setCorner:(CGFloat)radian WithCorners:(UIRectCorner)corners{
    CGSize size = CGSizeMake(radian, radian);
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                               byRoundingCorners:corners
                                                     cornerRadii:size];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = path.CGPath;
    maskLayer.masksToBounds = NO;
    self.layer.mask = maskLayer;
}
@end

@implementation UIView (extension)

- (void)loveHeart{
    CGRect rect = self.bounds;
    CGFloat width = 0;
    CGFloat radius = rect.size.width/4;
    CGPoint center1 = CGPointMake(radius, radius);
    CGPoint center2 = CGPointMake(3*radius, radius);
    CGPoint bottom = CGPointMake(2*radius, rect.size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center1
                                                        radius:radius
                                                    startAngle:0
                                                      endAngle:3*M_PI_4
                                                     clockwise:NO];
    [path addLineToPoint:bottom];
    [path addArcWithCenter:center2
                    radius:radius
                startAngle:M_PI_4
                  endAngle:M_PI
                 clockwise:NO];
    [path setLineCapStyle:kCGLineCapRound];
    [path setLineWidth:width];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = path.CGPath;
    maskLayer.masksToBounds = NO;
    self.layer.mask = maskLayer;
}

@end
