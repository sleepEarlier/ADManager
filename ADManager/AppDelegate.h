//
//  AppDelegate.h
//  ADManager
//
//  Created by kimiLin on 2017/7/3.
//  Copyright © 2017年 KimiLin. All rights reserved.
//

#import <UIKit/UIKit.h>
// GTSDK -> delegate
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, weak) id<UITableViewDelegate> delegate;

@end

