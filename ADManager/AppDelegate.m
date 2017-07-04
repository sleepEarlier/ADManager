//
//  AppDelegate.m
//  ADManager
//
//  Created by kimiLin on 2017/7/3.
//  Copyright © 2017年 KimiLin. All rights reserved.
//

#import "AppDelegate.h"
#import "ADManager.h"

@interface ADHelper : NSObject

@property (nonatomic, strong) UIWindow *ADWindow;

+ (void)showADWithImage:(UIImage *)image;

@end

@implementation ADHelper

+ (ADHelper *)sharedInstace
{
    static ADHelper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ADHelper alloc] init];
    });
    return instance;
}

+ (void)showADWithImage:(UIImage *)image {
    [[self sharedInstace] showADWithImage:image];
}

- (void)showADWithImage:(UIImage *)image {
    UIWindow *window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    window.backgroundColor = [UIColor whiteColor];
    window.alpha = 0.;
    window.rootViewController = [UIViewController new];
    UIImageView *imv = [[UIImageView alloc]initWithFrame:window.bounds];
    imv.contentMode = UIViewContentModeScaleAspectFill;
    imv.image = image;
    [window addSubview:imv];
    
    window.windowLevel = UIWindowLevelStatusBar + 1;
    window.hidden = NO;
    self.ADWindow = window;
    
    [UIView animateWithDuration:0.3 animations:^{
        window.alpha =  1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:3.0 options:0 animations:^{
            window.alpha = 0;
        } completion:^(BOOL finished) {
            window.hidden = YES;
            self.ADWindow = nil;
        }];
    }];
}

@end

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    ADManager *mag = [ADManager sharedInstace];
    mag.maxDailyShowTimes = 5;
    mag.maxSessionShowTimes = 3;
    mag.excludeFromScreenLock = NO;
    mag.timeThreshold = 0.5;
    mag.showADAction = ^(ADManager *manager, BOOL isFirstLaunch) {
        NSString *imageName = [NSString stringWithFormat:@"ad%@.jpg",@(manager.dailyShowTimes)];
        NSLog(@"isFirstLaunch:%@",@(isFirstLaunch));
        UIImage *image = [UIImage imageNamed:imageName];
        NSLog(@"%@,%@",imageName, image);
        if (image) {
            [ADHelper showADWithImage:image];
        }
    };
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
    
    
}




- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
