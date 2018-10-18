//
//  PLoadUI.h
//  iosTest
//
//  Created by Ximena on 2018/10/17.
//  Copyright © 2018年 xiaoming. All rights reserved.
//
//简单的加载进度示例
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLoadUI : UIView{
    UILabel* _txtPercent;
    UILabel* _txtDes;
    UIImageView* _imgBg;
    UIProgressView* _progressView;
}

+(PLoadUI*)instance;
+(void)hide;
-(void)updateProgress:(float)progress;
-(void)showInParent:(UIView* _Nonnull) parent;
-(id)init;
-(void)secondProgress:(float)pre;
-(void)setDes:(NSString*)des;
//test
-(void)start;
@end

NS_ASSUME_NONNULL_END
