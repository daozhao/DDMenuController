//
//  MainController.m
//  DDMenuController-Example
//
//  Created by chen daozhao on 12-11-26.
//  Copyright (c) 2012年 Fuzz Productions. All rights reserved.
//

#import "MainController.h"

@interface MainController ()

@end

@implementation MainController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"main";
    self.myView.contentSize = CGSizeMake(640, 920);
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSArray *)getLeftButtonViewForPanArray{
    return [NSArray arrayWithObjects:self.leftPanBtn, nil];
}

- (NSArray *)getLeftButtonViewForTapArray{
    return [NSArray arrayWithObjects:self.leftMenuBtn,self.leftMenuBtn2,self.leftPanBtn, nil];
    //return [NSArray arrayWithObjects:self.leftMenuBtn, nil];
    //return [NSArray arrayWithObjects:self.leftPanBtn, nil];
    //return [NSArray arrayWithObjects:self.leftPanBtn,self.leftMenuBtn, nil];
}
- (NSArray *)getLeftButtonViewForTransitionArray{
    //return nil;
    return [NSArray arrayWithObjects:self.leftMenuBtn,self.leftMenuBtn2, nil];
}

- (NSArray *)getRightButtonViewForTapArray{
    return [NSArray arrayWithObjects:self.rightMenuBtn,self.rightMenuBtn2, nil];
}
- (NSArray *)getRightButtonViewForPanArray{
    return [NSArray arrayWithObjects:self.rightPanBtn, nil];
}
- (NSArray *)getRightButtonViewForTransitionArray{
    return [NSArray arrayWithObjects:self.rightMenuBtn,self.rightMenuBtn2, nil];
    //return [NSArray arrayWithObjects:self.rightMenuBtn, nil];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ( UIDeviceOrientationPortraitUpsideDown == toInterfaceOrientation )
    {
        return NO;
    }
    return YES;
}



@end
