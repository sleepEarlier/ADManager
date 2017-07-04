# ADManager
Some Apps would display an AD when App launch or App enter foreground.
This is a simple tool help to control when and how much times the AD should be displayed.

### Controls
* **excludeFromScreenLock**, should exclude the situation that app enter foreground by unlock screen. YES by default.
* **timeThreshold**, time interval in seconds between background and foreground, default to 300s(5 minus)
* **maxSessionShowTimes**, max time of showing AD per session(APP run one time), default to NSUIntegerMax.
* **maxDailyShowTimes**, max time of showing AD per day, default to NSUIntegerMax.
* **showADFilter**, if exists, the return value of this block will determinte the AD should be displayed or not
* **showADAction**, block to execute when an AD should be displayed.


### example code
```
KMADManager *mag = [KMADManager sharedInstace];

mag.maxDailyShowTimes = 5;
mag.maxSessionShowTimes = 3;
mag.excludeFromScreenLock = NO;
mag.timeThreshold = 3 * 60; // 3 minus
mag.showADAction = ^(KMADManager *manager, BOOL isFirstLaunch) {
    // here, code to show your AD
    // e.g.
    NSString *imageName = [NSString stringWithFormat:@"ad%@.jpg",@(manager.dailyShowTimes)];
    UIImage *image = [UIImage imageNamed:imageName];
    if (image) {
        [ADHelper showADWithImage:image];
    }
};
```
