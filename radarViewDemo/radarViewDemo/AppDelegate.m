//
//  AppDelegate.m
//  radarViewDemo
//
//  Created by MeetYou on 2024/5/8.
//

#import "AppDelegate.h"
#import "ViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    ViewController *vc = [ViewController new];
    self.window.rootViewController = vc;
    return YES;
}
@end
