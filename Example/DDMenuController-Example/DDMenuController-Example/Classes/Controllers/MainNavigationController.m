//
//  MainNavigationController.m
//  DDMenuController-Example
//
//  Created by Adam Price on 4/13/12.
//  Copyright (c) 2012 Fuzz Productions. All rights reserved.
//

#import "MainNavigationController.h"

@implementation MainNavigationController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self resetNavButtons];
}

#pragma Internal Nav Handling 

- (void)resetNavButtons {
    if (!_rootViewController) return;
    
    UIViewController *topController = nil;
    if ([_rootViewController isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController *navController = (UINavigationController*)_rootViewController;
        if ([[navController viewControllers] count] > 0) {
            topController = [[navController viewControllers] objectAtIndex:0];
        }
        
    } else if ([_rootViewController isKindOfClass:[UITabBarController class]]) {
        
        UITabBarController *tabController = (UITabBarController*)_rootViewController;
        topController = [tabController selectedViewController];
        
    } else {
        
        topController = _rootViewController;
        
    }
	
	[topController setTitle:@"Example"];
    
    if (_menuFlags.canShowLeft) {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_menu_icon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showLeft:)];
        topController.navigationItem.leftBarButtonItem = button;
    } else {
        topController.navigationItem.leftBarButtonItem = nil;
    }
    
    if (_menuFlags.canShowRight) {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_menu_icon.png"] style:UIBarButtonItemStyleBordered  target:self action:@selector(showRight:)];
        topController.navigationItem.rightBarButtonItem = button;
    } else {
        topController.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)setRightViewController:(UIViewController *)rightController {
	[super setRightViewController:rightController];
	
    [self resetNavButtons];
}

- (void)setLeftViewController:(UIViewController *)leftController {
	[super setLeftViewController:leftController];

    [self resetNavButtons];
}

- (void)setRootViewController:(UIViewController *)rootViewController {
	[super setRootViewController:rootViewController];
	
	[self resetNavButtons];
}

@end
