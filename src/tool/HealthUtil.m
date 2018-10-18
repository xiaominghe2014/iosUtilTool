
#import "HealthUtil.h"
#import <objc/message.h>

@interface HealthUtil(){}
@property (nonatomic,strong) HKHealthStore *healthStore;
@end
@implementation HealthUtil : NSObject



+ (instancetype) instance
{
    static HealthUtil* util = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        util = [[HealthUtil alloc] init];
    });
    util.healthStore = [[HKHealthStore alloc]init];
    return util;
}

//数据类型----具体类型详见 HKQuantityTypeIdentifier.h
-(HKQuantityType*) getHealthType:(HKQuantityTypeIdentifier)identifier{
    HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:identifier];
    return type;
}

//步数
-(HKQuantityType*) stepType{
    return [self getHealthType:HKQuantityTypeIdentifierStepCount];
}

//步行+跑步距离
-(HKQuantityType*) walkType{
    return [self getHealthType:HKQuantityTypeIdentifierDistanceWalkingRunning];
}

//骑车距离
-(HKQuantityType*) cycleType{
    return [self getHealthType:HKQuantityTypeIdentifierDistanceCycling];
}

//爬楼数据
-(HKQuantityType*) climbedType{
    return [self getHealthType:HKQuantityTypeIdentifierFlightsClimbed];
}

//血压
-(HKQuantityType*) bloodPressureType{
    return [self getHealthType:HKCorrelationTypeIdentifierBloodPressure];
}

//心率
-(HKQuantityType*) heartRateType{
    return [self getHealthType:HKQuantityTypeIdentifierHeartRate];
}

//体温
-(HKQuantityType*) bodyTemperatureType{
    return [self getHealthType:HKQuantityTypeIdentifierBodyTemperature];
}

//睡眠分析
-(HKQuantityType*) sleepType{
    return [self getHealthType:HKCategoryTypeIdentifierSleepAnalysis];
}

//例假
-(HKQuantityType*) menstrualType{
    return [self getHealthType:HKCategoryTypeIdentifierMenstrualFlow];
}

//性行为
-(HKQuantityType*) sexualType{
    return [self getHealthType:HKCategoryTypeIdentifierSexualActivity];
}

//排卵测试结果
-(HKQuantityType*) ovulationType{
    return [self getHealthType:HKCategoryTypeIdentifierOvulationTestResult];
}

//宫颈黏液质量
-(HKQuantityType*) cervicalMucusType{
    return [self getHealthType:HKCategoryTypeIdentifierCervicalMucusQuality];
}


- (BOOL) authorizePermission:(PermissonCallBack)cb
{
    if (!NSClassFromString(@"HKHealthStore")||![HKHealthStore isHealthDataAvailable]) {
        NSLog(@"该设备不支持HealthKit");
        return NO;
    }
    self.healthStore = [[HKHealthStore alloc]init];
    
    //读取权限
    NSSet* readPermisson = [NSSet setWithObjects:
                            [self stepType],
                            [self walkType],
                            [self cycleType],
                            [self climbedType],
                            nil];
    //写入权限
    NSSet* writePermisson = [NSSet setWithObjects:
                             [self stepType],
                             [self walkType],
                             [self cycleType],
                             [self climbedType],
                             nil];
    //从健康应用中获取权限
    [self.healthStore requestAuthorizationToShareTypes:writePermisson readTypes:readPermisson completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            cb(success,error);
        });
    }];
    return YES;
}

- (HKSource * _Nonnull)extracted:(HKQuantitySample *)result {
    HKSource *source = nil;
    if ([result respondsToSelector:@selector(sourceRevision)]) {
        source = [[result valueForKey:@"sourceRevision"] valueForKey:@"source"];
    } else {
        //@TODO Update deprecated API call
        //source = result.source;
        source = result.sourceRevision;
    }
    //    Ivar localIvar = class_getInstanceVariable([source class], "_localDevice");
    //    bool local = object_getIvar(source, localIvar);
    return source;
}

//条件
- (NSPredicate*)todayCondition{
    //获取当前时间
    NSDate *now = [NSDate date];
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calender components:unitFlags fromDate:now];
    int hour = (int)[dateComponent hour];
    int minute = (int)[dateComponent minute];
    int second = (int)[dateComponent second];
    NSDate *nowDay = [NSDate dateWithTimeIntervalSinceNow:  - (hour*3600 + minute * 60 + second) ];
    //时间结果与想象中不同是因为它显示的是0区
    NSLog(@"今天%@",nowDay);
    NSDate *nextDay = [NSDate dateWithTimeIntervalSinceNow:  - (hour*3600 + minute * 60 + second)  + 86400];
    NSLog(@"明天%@",nextDay);
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:nowDay endDate:nextDay options:(HKQueryOptionNone)];
    return predicate;
}


//查询
-(void) queryData:(HKQuantityType*) type withCondition:(NSPredicate*) condition andLimit:(NSUInteger)limit onCompleted:(void(^)(NSArray<__kindof HKSample *> *)) cb{
    NSSortDescriptor *start = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    NSSortDescriptor *end = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    HKSampleQuery *sampleQuery = [[HKSampleQuery alloc]initWithSampleType:type predicate:condition limit:limit sortDescriptors:@[start,end] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        cb(results);
    }];
    //执行查询
    [self.healthStore executeQuery:sampleQuery];
}

//今日步数查询
-(void) getTodaySteps:(ReadStepsCallBack)cb
{
    [self queryData:[self stepType]
       withCondition:[self todayCondition]
            andLimit:0
         onCompleted:^(NSArray<__kindof HKSample *> *results) {
             double allStepCounts = 0;
             for (HKQuantitySample *result in results) {
                 HKQuantity *quantity = result.quantity;
                 HKUnit *stepCount = [HKUnit countUnit];
                 double count = [quantity doubleValueForUnit:stepCount];
                 // 区分手机自动计算步数和App写入的步数
                 if ([[self extracted:result].bundleIdentifier rangeOfString:@"com.apple.health"].location !=NSNotFound) {
                     allStepCounts += count;
                 }
                 else {
                     //allStepCounts += count;
                 }
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 cb(allStepCounts);
             });
    }];
}

//保存步数
-(void) saveStepsCount:(double)steps startDate:(NSDate*) start endDate:(NSDate*)end device:(HKDevice*) device callBack:(WriteCallBack) cb
{
    HKQuantity *stepQuantityConsumed = [HKQuantity quantityWithUnit:[HKUnit countUnit] doubleValue:steps];
    HKQuantityType *stepConsumedType = [self stepType];
    HKQuantitySample *stepConsumedSample = [HKQuantitySample quantitySampleWithType:stepConsumedType quantity:stepQuantityConsumed startDate:start endDate:end device:device metadata:nil];
    [self.healthStore saveObject:stepConsumedSample withCompletion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            cb(success,error);
        });
    }];
}


@end
