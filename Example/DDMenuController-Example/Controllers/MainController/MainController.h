//
//  MainController.h
//  DDMenuController-Example
//
//  Created by chen daozhao on 12-11-26.
//  Copyright (c) 2012年 Fuzz Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDMenuController.h"

@interface MainController : UIViewController<DDMenuControllerDelegate>


@property (retain, nonatomic) IBOutlet UIImageView *backImage;
@property (retain, nonatomic) IBOutlet UIScrollView *myView;

//@property (retain, nonatomic) IBOutlet UIImageView *homeTopSVBack;
@property (retain, nonatomic) IBOutlet UIButton *leftMenuBtn;
@property (retain, nonatomic) IBOutlet UIButton *leftPanBtn;
@property (retain, nonatomic) IBOutlet UIButton *leftMenuBtn2;

@property (retain, nonatomic) IBOutlet UIButton *rightMenuBtn;
@property (retain, nonatomic) IBOutlet UIButton *rightMenuBtn2;
@property (retain, nonatomic) IBOutlet UIButton *rightPanBtn;

@end
