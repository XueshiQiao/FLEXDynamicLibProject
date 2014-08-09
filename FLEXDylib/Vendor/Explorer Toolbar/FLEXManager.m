//
//  FLEXManager.m
//  Flipboard
//
//  Created by Ryan Olson on 4/4/14.
//  Copyright (c) 2014 Flipboard. All rights reserved.
//

#import "FLEXManager.h"
#import "FLEXExplorerViewController.h"
#import "FLEXWindow.h"
#import "FLEXGlobalsTableViewControllerEntry.h"
#import "FLEXObjectExplorerFactory.h"
#import "FLEXObjectExplorerViewController.h"

@interface FLEXManager () <FLEXWindowEventDelegate, FLEXExplorerViewControllerDelegate>

@property (nonatomic, strong) FLEXWindow *explorerWindow;
@property (nonatomic, strong) FLEXExplorerViewController *explorerViewController;

@property (nonatomic, readonly, strong) NSMutableArray *userGlobalEntries;

@end

@implementation FLEXManager

+ (instancetype)sharedManager
{
    static FLEXManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[[self class] alloc] init];
    });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _userGlobalEntries = [[NSMutableArray alloc] init];
    }
    return self;
}

- (FLEXWindow *)explorerWindow
{
    NSAssert([NSThread isMainThread], @"You must use %@ from the main thread only.", NSStringFromClass([self class]));
    
    if (!_explorerWindow) {
        _explorerWindow = [[FLEXWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _explorerWindow.eventDelegate = self;

        _explorerWindow.rootViewController = self.explorerViewController;
        [_explorerWindow addSubview:self.explorerViewController.view];
    }
    
    return _explorerWindow;
}

- (FLEXExplorerViewController *)explorerViewController
{
    if (!_explorerViewController) {
        _explorerViewController = [[FLEXExplorerViewController alloc] init];
        _explorerViewController.delegate = self;
    }

    return _explorerViewController;
}

- (void)showExplorer
{
    self.explorerWindow.hidden = NO;
}

- (void)hideExplorer
{
    self.explorerWindow.hidden = YES;
}

- (BOOL)isHidden
{
    return self.explorerWindow.isHidden;
}


#pragma mark - FLEXWindowEventDelegate

- (BOOL)shouldHandleTouchAtPoint:(CGPoint)pointInWindow
{
    // Ask the explorer view controller
    return [self.explorerViewController shouldReceiveTouchAtWindowPoint:pointInWindow];
}


#pragma mark - FLEXExplorerViewControllerDelegate

- (void)explorerViewControllerDidFinish:(FLEXExplorerViewController *)explorerViewController
{
    [self hideExplorer];
}


#pragma mark - Extensions

- (void)registerGlobalEntryWithName:(NSString *)entryName objectFutureBlock:(id (^)(void))objectFutureBlock
{
    NSParameterAssert(entryName);
    NSParameterAssert(objectFutureBlock);
    NSAssert([NSThread isMainThread], @"This method must be called from the main thread.");

    entryName = entryName.copy;
    FLEXGlobalsTableViewControllerEntry *entry = [FLEXGlobalsTableViewControllerEntry entryWithNameFuture:^NSString *{
        return entryName;
    } viewControllerFuture:^UIViewController *{
        return [FLEXObjectExplorerFactory explorerViewControllerForObject:objectFutureBlock()];
    }];

    [self.userGlobalEntries addObject:entry];
}

@end
