//
//  PLoadUI.m
//  iosTest
//
//  Created by Ximena on 2018/10/17.
//  Copyright © 2018年 xiaoming. All rights reserved.
//

#import "PLoadUI.h"
//NSString* dot = @"";
int idx = 0;
float const firstMAX = 0.3f;
float testProgress = 0.0f;
//test 控制是否是测试
bool test = true;
@interface PLoadUI()
//进度记录
@property (nonatomic, assign) float m_first;
@property (nonatomic, assign) float m_second;
@property (nonatomic, strong) NSString* m_des;
@property (nonatomic, strong) NSTimer* m_timer;
@property (nonatomic, strong) NSTimer* m_testTimer;
@end
@implementation PLoadUI:UIView


-(id)init{
    self = [super init];
    if(self)
    {
        _m_first = 0.0f;
        _m_second = 0.0f;
        _m_timer = nil;
        _m_testTimer = nil;
        _m_des = @"应用初始化";
        [self initBg];
        [self initPercent];
        [self initDes];
        [self initProgress];
    }
    return self;
}

-(void)initBg{
    NSString *path = [[NSBundle mainBundle] resourcePath];
    NSArray* list = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:nil];
    NSString *from = @"这里设置自定义背景";//[NSString stringWithFormat:@"%@/%@",path,@"logo/bg.png"];
    if(NO == [[NSFileManager defaultManager] fileExistsAtPath:from]){
        for(NSString* file in list){
            if([[file pathExtension] isEqualToString:@"png"]){
                NSLog(@"%@",file);
                //from = [NSString stringWithFormat:@"%@/%@",path,file];;
                break;
            }
        }
    }
    if(NO == [[NSFileManager defaultManager] fileExistsAtPath:from]){
        _imgBg = [[UIImageView alloc] init];
        _imgBg.backgroundColor = [UIColor colorWithRed:44.0f/255.0f green:24.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
    }else{
        UIImage *image = [UIImage imageWithContentsOfFile:from];
        _imgBg = [[UIImageView alloc] initWithImage:image];
    }
    [_imgBg setFrame:[[UIScreen mainScreen] bounds]];
    [self addSubview:_imgBg];
}

-(void)initPercent{
    UIColor* textColor = [UIColor colorWithRed:204.0f/255.0f green:41.0f/255.0f blue:44.0f/255.0f alpha:1.0f];
    UIFont* font = [UIFont fontWithName:@"Arial" size:60];
    CGRect frame = CGRectMake(20, CGRectGetMaxY([[UIScreen mainScreen] bounds])/2 - 75, [[UIScreen mainScreen] bounds].size.width, 60);
    _txtPercent = [self createLableWithFont:font frame:frame color:textColor];
}

-(void)initDes{
    UIColor* textColor = [UIColor colorWithRed:134.0f/255.0f green:134.0f/255.0f blue:134.0f/255.0f alpha:1.0f];
    UIFont* font = [UIFont fontWithName:@"Arial" size:20];
    CGRect frame = CGRectMake(20, CGRectGetMaxY([[UIScreen mainScreen] bounds])/2 + 25, [[UIScreen mainScreen] bounds].size.width, 20);
    _txtDes = [self createLableWithFont:font frame:frame color:textColor];
}

-(UILabel*) createLableWithFont:(UIFont*)font frame:(CGRect)frame color:(UIColor*)color{
    UILabel* label =  [[UILabel alloc] init];
    label.font = font;
    label.textColor = color;
    label.frame = frame;
    label.textAlignment = NSTextAlignmentLeft;
    [self addSubview:label];
    return label;
}

-(void)initProgress{
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    _progressView.progressTintColor = [UIColor redColor];
    _progressView.backgroundColor = [UIColor colorWithRed:134.0f/255.0f green:134.0f/255.0f blue:134.0f/255.0f alpha:1.0f];
    _progressView.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height/2, [[UIScreen mainScreen] bounds].size.width, 16);
    [_progressView setProgress:0.0f animated:true];
    [self addSubview:_progressView];
}
-(void)start{
    _m_timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(checkProgress) userInfo:nil repeats:YES];
    if(test){
        [NSTimer scheduledTimerWithTimeInterval:(arc4random()%100)/100.0f target:self selector:@selector(randomUpdateSecond) userInfo:nil repeats:NO];
    }
}
-(void)checkProgress{
    idx += 1;
    int tmp = (idx/10)%4;
    NSString* dot = @".";
    while (tmp--) {
        dot = [dot stringByAppendingString:@"."];
    }
    if(_progressView.progress>=1.0){
        if(test)
            [PLoadUI hide];
    }else{
        [self firstGrow];
        _txtPercent.text = [NSString stringWithFormat:@"%.1f%@",_progressView.progress*100.0f,@"%" ];
        NSLog(@"percent:%f,%f",_m_first, _m_second);
        if(_progressView.progress<firstMAX){
            _txtDes.text = [NSString stringWithFormat:@"%@%@",_m_des,dot];
        }else{
            if(test)
                [self setDes:@"app，资源加载中"];
            _txtDes.text = [NSString stringWithFormat:@"%@%@",_m_des,dot];
        }
    }
}

-(void)firstGrow{
    if(_m_first<firstMAX&&0.0f==_m_second)
        _m_first += 0.01f;
    _progressView.progress = _m_first+_m_second;
}

- (void)secondProgress:(float)pre{
    _m_second = pre*(1.0f-_m_first);
}

- (void)setDes:(NSString *)des{
    _m_des = des;
}

+(PLoadUI*)instance{
    static PLoadUI* load = nil;
    if(nil == load){
        load = [[PLoadUI alloc] init];
    }
    return load;
}
+(void)hide{
    [[PLoadUI instance] stopTimer];
    [[PLoadUI instance]  removeFromSuperview];
}
-(void)stopTimer{
    if(_m_timer){
        [_m_timer invalidate];
        _m_timer = nil;
    }
    if(_m_testTimer){
        [_m_testTimer invalidate];
        _m_testTimer = nil;
    }
}
-(void)showInParent:(UIView*)view{
    if (self.superview == nil)
    {
        [view addSubview:self];
    }
}

-(void)updateProgress:(float)progress{
    _progressView.progress = progress;
}


#pragma mark 测试部分
-(void)randomUpdateSecond{
    float t = (arc4random()%100)/100.0f;
    _m_testTimer = [NSTimer scheduledTimerWithTimeInterval:t target:self selector:@selector(randomTest) userInfo:nil repeats:YES];
}

-(void)randomTest{
    if(testProgress<=1){
        testProgress += 0.001f+arc4random()%100/9000.0f;
    }
    testProgress=MIN(testProgress,1.0f);
    [self secondProgress:testProgress];
}

@end
