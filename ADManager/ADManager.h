//
//  ADManager.h
//  ADManager
//
//  Created by kimiLin on 2017/7/3.
//  Copyright © 2017年 KimiLin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const KMADManagerDailyDateKey;
extern NSString *const KMADManagerDailyTimeKey;



@class ADManager;

typedef BOOL(^ShowADFilter)(ADManager *manager, BOOL isFirstLaunch, BOOL reachTimeThreshold, BOOL reachMaxSessionTime, BOOL reachMaxDailyTime);

typedef void(^ShowADAction)(ADManager *manager, BOOL isFirstLaunch);

@interface ADManager : NSObject

/// should exclude app active from screen unlock, default YES
@property (nonatomic, assign) BOOL excludeFromScreenLock;

/// time interval in seconds between background and foreground, default to 300s(5 minus)
@property (nonatomic, assign) NSTimeInterval timeThreshold;

/// current session AD show times
@property (nonatomic, assign, readonly) NSUInteger sessionShowTimes;

/// current daily AD show times
@property (nonatomic, assign, readonly) NSUInteger dailyShowTimes;

/// max time of showing AD per session(APP run one time), default to NSUIntegerMax
@property (nonatomic, assign) NSUInteger maxSessionShowTimes;

/// max time of showing AD per day, default to NSUIntegerMax
@property (nonatomic, assign) NSUInteger maxDailyShowTimes;

/// filter to use when invoke - shouldShowAD if exits, default to nil
@property (nonatomic, copy) ShowADFilter showADFilter;

/// block execute when app first time launch / come to foreground and - shouldShowAD return YES
@property (nonatomic, copy) ShowADAction showADAction;

+ (ADManager *)sharedInstace;


@end
