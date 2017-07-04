//
//  ADManager.m
//  ADManager
//
//  Created by kimiLin on 2017/7/3.
//  Copyright © 2017年 KimiLin. All rights reserved.
//

#import "ADManager.h"

NSString *const KMADManagerTimeThresholdLastDateKey = @"KMADManagerTimeThresholdLastTimeKey";
NSString *const KMADManagerTimeThresholdCurrentDateKey = @"KMADManagerTimeThresholdCurrentTimeKey";
NSString *const KMADManagerDailyDateKey = @"KMADManagerDailyDateKey";
NSString *const KMADManagerDailyTimeKey = @"KMADManagerDailyTimeKey";

@interface ADManager ()
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, assign) NSUInteger sessionShowTimes;
@end

@implementation ADManager

+ (instancetype)sharedInstace
{
    static ADManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ADManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setDefaultData];
        [self userDefaultInit];
        [self addNotifications];
    }
    return self;
}

- (void)userDefaultInit {
    self.sessionShowTimes = 0;
    NSUserDefaults *dfs = [NSUserDefaults standardUserDefaults];
    [dfs removeObjectForKey:KMADManagerTimeThresholdLastDateKey];
    [dfs removeObjectForKey:KMADManagerTimeThresholdCurrentDateKey];
    [dfs synchronize];
    [self updateDailyDateAndTimeIfNeed];
}

- (void)updateDailyDateAndTimeIfNeed {
    NSUserDefaults *dfs = [NSUserDefaults standardUserDefaults];
    NSDate *lastDate = [dfs objectForKey:KMADManagerDailyDateKey];
    NSDate *now = [NSDate date];
    if (lastDate) {
        NSInteger lastYear = [self.calendar component:NSCalendarUnitYear fromDate:lastDate];
        NSInteger lastMonth = [self.calendar component:NSCalendarUnitMonth fromDate:lastDate];
        NSInteger lastDay = [self.calendar component:NSCalendarUnitDay fromDate:lastDate];
        NSInteger curYear = [self.calendar component:NSCalendarUnitYear fromDate:now];
        NSInteger curMonth = [self.calendar component:NSCalendarUnitMonth fromDate:now];
        NSInteger curDay = [self.calendar component:NSCalendarUnitDay fromDate:now];
        BOOL isSameDay = lastYear == curYear && lastMonth == curMonth && lastDay == curDay;
        if (!isSameDay) {
            [dfs setObject:@0 forKey:KMADManagerDailyTimeKey];
        }
    }
    [dfs setObject:now forKey:KMADManagerDailyDateKey];
    [dfs synchronize];
}

- (void)setDefaultData {
    self.excludeFromScreenLock = YES;
    self.timeThreshold = 5 * 60;
    self.maxSessionShowTimes = NSUIntegerMax;
    self.maxDailyShowTimes = NSUIntegerMax;
}

- (void)addNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onDidFinishLaunch:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    [center addObserver:self selector:@selector(onDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center addObserver:self selector:@selector(onWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)onDidFinishLaunch:(NSNotification *)noti {
    if ( [self shouldShowAD:YES] && self.showADAction) {
        [self hasShow];
        self.showADAction(self, YES);
    }
}

- (void)onDidEnterBackground:(NSNotification *)noti {
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    CGFloat screenBrightness = [[UIScreen mainScreen] brightness];
    BOOL isLockScreen = (state == UIApplicationStateInactive) || (state == UIApplicationStateBackground && screenBrightness <= 0.0);
    if (isLockScreen && self.excludeFromScreenLock) {
        return;
    }
    
    NSDate *now = [NSDate date];
    NSUserDefaults *dfs = [NSUserDefaults standardUserDefaults];
    [dfs setObject:now forKey:KMADManagerTimeThresholdLastDateKey];
    [dfs synchronize];
}

- (void)onWillEnterForeground:(NSNotification *)noti {
    NSUserDefaults *dfs = [NSUserDefaults standardUserDefaults];
    NSDate *last = [dfs objectForKey:KMADManagerTimeThresholdLastDateKey];
    if (last) {
        NSDate *now = [NSDate date];
        [dfs setObject:now forKey:KMADManagerTimeThresholdCurrentDateKey];
        if ([self shouldShowAD:NO] && self.showADAction) {
            [self hasShow];
            self.showADAction(self, NO);
        }
    }
    [dfs removeObjectForKey:KMADManagerTimeThresholdLastDateKey];
    [dfs removeObjectForKey:KMADManagerTimeThresholdCurrentDateKey];
    [dfs synchronize];
}

- (BOOL)shouldShowAD:(BOOL)isFirstLaunch {
    NSUserDefaults *dfs = [NSUserDefaults standardUserDefaults];
    NSDate *last = [dfs objectForKey:KMADManagerTimeThresholdLastDateKey];
    NSDate *now = [dfs objectForKey:KMADManagerTimeThresholdCurrentDateKey];
    NSNumber *dailyTime = [dfs objectForKey:KMADManagerDailyTimeKey];
    NSTimeInterval time = [now timeIntervalSinceDate:last];
#ifdef DEBUG
    NSLog(@"ADManager: time gap:%@",@(time));
#endif
    BOOL reachThreshold = time >= self.timeThreshold;
    BOOL reachSessionLimit = self.sessionShowTimes >= self.maxSessionShowTimes;
    BOOL reachDailyLimit = dailyTime.integerValue >= self.maxDailyShowTimes;
    if (self.showADFilter) {
        return self.showADFilter(self, isFirstLaunch, reachThreshold, reachSessionLimit, reachDailyLimit);
    }
    else {
        if (isFirstLaunch) {
            return !reachDailyLimit && !reachSessionLimit;
        } else {
            return reachThreshold && !reachDailyLimit && !reachSessionLimit;
        }
    }
}

- (void)hasShow {
    self.sessionShowTimes++;
    [self updateDailyDateAndTimeIfNeed];
    NSUserDefaults *dfs = [NSUserDefaults standardUserDefaults];
    NSNumber *dailyShowTimes = [dfs objectForKey:KMADManagerDailyTimeKey];
    dailyShowTimes = @(dailyShowTimes.integerValue + 1);
    [dfs setObject:dailyShowTimes forKey:KMADManagerDailyTimeKey];
    [dfs synchronize];
#ifdef DEBUG
    NSLog(@"ADManager: session show times:%@, sessionLimit:%@",@(self.sessionShowTimes), @(self.maxSessionShowTimes));
    NSLog(@"ADManager: daily show times:%@, dailyLimit:%@",dailyShowTimes, @(self.maxDailyShowTimes));
#endif
}

- (NSUInteger)dailyShowTimes {
    NSUserDefaults *dfs = [NSUserDefaults standardUserDefaults];
    NSNumber *dailyShowTimes = [dfs objectForKey:KMADManagerDailyTimeKey];
    return dailyShowTimes.unsignedIntegerValue;
}

- (NSCalendar *)calendar {
    if (!_calendar) {
        _calendar = [NSCalendar currentCalendar];
        _calendar.timeZone = [NSTimeZone systemTimeZone];
    }
    return _calendar;
}

@end
