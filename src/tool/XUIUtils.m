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
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:size];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = path.CGPath;
    maskLayer.masksToBounds = NO;
    self.layer.mask = maskLayer;
}
@end
