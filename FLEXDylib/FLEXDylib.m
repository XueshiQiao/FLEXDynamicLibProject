//
//  FLEXDylib.m
//  FLEXDylib
//
//  Created by Joey on 14-8-9.
//  Copyright (c) 2014年 Joey. All rights reserved.
//

#import "FLEXDylib.h"
#import "FLEXManager.h"
#import <UIKit/UIKit.h>



@implementation FLEXDylib

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appLaunched:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    return self;
}

- (void)appLaunched:(NSNotification *)notification
{
    NSLog(@"======================= libFlex dylib show ========================");
    
    [[FLEXManager sharedManager] showExplorer];
}

@end

static void __attribute__((constructor)) initialize(void)
{
    NSLog(@"======================= libFlex dylib initialize ========================");
    
    static FLEXDylib *entrance;
    entrance = [[FLEXDylib alloc] init];
}