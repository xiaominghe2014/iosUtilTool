//
//  XUIUtils.h
//  iosTest
//
//  Created by Ximena on 2019/4/28.
//  Copyright © 2019 xiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface UIImage (extension)

/**
 @brief 颜色转图片
 */
+(UIImage*) imageFromColor:(UIColor*) color;

/**
 @brief 九宫格属性
 */
-(void) setSudoku:(UIEdgeInsets)capInsets;

@end

@interface UIImageView (extension)

/**
 @brief 设置圆角
 @param  radian 弧度
 @param  corners 圆角方向
 */
-(void) setCorner:(CGFloat) radian WithCorners:(UIRectCorner) corners;

@end

NS_ASSUME_NONNULL_END
