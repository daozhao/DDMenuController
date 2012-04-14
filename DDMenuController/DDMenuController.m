//
//  DDMenuController.m
//  DDMenuController
//
//  Created by Devin Doty on 11/30/11.
//  Copyright (c) 2011 toaast. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "DDMenuController.h"

#define kMenuFullWidth 320.0f
#define kMenuDisplayedWidth 280.0f
#define kMenuOverlayWidth (self.view.bounds.size.width - kMenuDisplayedWidth)
#define kMenuBounceOffset 10.0f
#define kMenuBounceDuration .3f
#define kMenuSlideDuration .3f


@interface DDMenuController (Internal)
- (void)showShadow:(BOOL)val;
@end

@implementation DDMenuController

@synthesize delegate;

@synthesize leftViewController=_leftViewController;
@synthesize rightViewController=_rightViewController;
@synthesize rootViewController=_rootViewController;

@synthesize tap=_tap;
@synthesize pan=_pan;

@synthesize leftBarButtonItem = _leftBarButtonItem;
@synthesize rightBarButtonItem = _rightBarButtonItem;

- (id)initWithLeftViewController:(UIViewController*)controller 
{
    if ((self = [super init])) 
	{
        _leftViewController = controller;
    }
    return self;
}

- (id)init 
{
    if ((self = [super init])) 
	{
        
    }
    return self;
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}


#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    [self setRootViewController:_rootViewController]; // reset root
    
    if (!_tap) 
	{
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        tap.delegate = (id<UIGestureRecognizerDelegate>)self;
        [self.view addGestureRecognizer:tap];
        [tap setEnabled:NO];
        _tap = tap;
    }
    
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    _tap = nil;
    _pan = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
{
    return [_rootViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration 
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

    if (_rootViewController) 
	{
        [_rootViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
        UIView *view = _rootViewController.view;
        if (_menuFlags.showingRightView) 
		{
            view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        } 
		else if (_menuFlags.showingLeftView) 
		{
            view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        } 
		else 
		{
            view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        }
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    if (_rootViewController) 
	{
        [_rootViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];

        CGRect frame = self.view.bounds;
        if (_menuFlags.showingLeftView) 
		{
            frame.origin.x = frame.size.width - kMenuOverlayWidth;
        } else if (_menuFlags.showingRightView) 
		{
            frame.origin.x = -(frame.size.width - kMenuOverlayWidth);
        }
        _rootViewController.view.frame = frame;
        _rootViewController.view.autoresizingMask = self.view.autoresizingMask;
        
        [self showShadow:(_rootViewController.view.layer.shadowOpacity!=0.0f)];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration 
{
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

    if (_rootViewController) 
        [_rootViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];    
}


#pragma mark - GestureRecognizers

- (void)pan:(UIPanGestureRecognizer*)gesture 
{

    if (gesture.state == UIGestureRecognizerStateBegan) 
	{
        [self showShadow:YES];
        _panOriginX = self.view.frame.origin.x;        
        _panVelocity = CGPointMake(0.0f, 0.0f);
        
        if([gesture velocityInView:self.view].x > 0) 
            _panDirection = DDMenuPanDirectionRight;
		else
            _panDirection = DDMenuPanDirectionLeft;
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged) 
	{
        
        CGPoint velocity = [gesture velocityInView:self.view];
        if((velocity.x*_panVelocity.x + velocity.y*_panVelocity.y) < 0) 
		{
            _panDirection = (_panDirection == DDMenuPanDirectionRight) ? DDMenuPanDirectionLeft : DDMenuPanDirectionRight;
        }
        
        _panVelocity = velocity;        
        CGPoint translation = [gesture translationInView:self.view];
        CGRect frame = _rootViewController.view.frame;
        frame.origin.x = _panOriginX + translation.x;
        
        if (frame.origin.x > 0.0f && !_menuFlags.showingLeftView) 
		{
            
            if(_menuFlags.showingRightView) 
			{
                _menuFlags.showingRightView = NO;
                [self.rightViewController.view removeFromSuperview];
            }
            
            if (_menuFlags.canShowLeft) 
			{
                
                _menuFlags.showingLeftView = YES;
                CGRect frame = self.view.bounds;
				frame.size.width = kMenuFullWidth;
                self.leftViewController.view.frame = frame;
                [self.view insertSubview:self.leftViewController.view atIndex:0];
                
            } 
			else 
			{
                frame.origin.x = 0.0f; // ignore right view if it's not set
            }
            
        } 
		else if (frame.origin.x < 0.0f && !_menuFlags.showingRightView) 
		{
            
            if(_menuFlags.showingLeftView) 
			{
                _menuFlags.showingLeftView = NO;
                [self.leftViewController.view removeFromSuperview];
            }
            
            if (_menuFlags.canShowRight) 
			{
                
                _menuFlags.showingRightView = YES;
                CGRect frame = self.view.bounds;
				frame.origin.x += frame.size.width - kMenuFullWidth;
				frame.size.width = kMenuFullWidth;
                self.rightViewController.view.frame = frame;
                [self.view insertSubview:self.rightViewController.view atIndex:0];
     
            } else 
			{
                frame.origin.x = 0.0f; // ignore left view if it's not set
            }
            
        }
        
        _rootViewController.view.frame = frame;

    } 
	else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) 
	{
        
        //  Finishing moving to left, right or root view with current pan velocity
        [self.view setUserInteractionEnabled:NO];
        
        DDMenuPanCompletion completion = DDMenuPanCompletionRoot; // by default animate back to the root
        
        if (_panDirection == DDMenuPanDirectionRight && _menuFlags.showingLeftView) 
            completion = DDMenuPanCompletionLeft;
        else if (_panDirection == DDMenuPanDirectionLeft && _menuFlags.showingRightView) 
            completion = DDMenuPanCompletionRight;
        
        CGPoint velocity = [gesture velocityInView:self.view];    
        if (velocity.x < 0.0f)
            velocity.x *= -1.0f;
		
        BOOL bounce = (velocity.x > 800);
        CGFloat originX = _rootViewController.view.frame.origin.x;
        CGFloat width = _rootViewController.view.frame.size.width;
        CGFloat span = (width - kMenuOverlayWidth);
        CGFloat duration = kMenuSlideDuration; // default duration with 0 velocity
        
        
        if (bounce) 
            duration = (span / velocity.x); // bouncing we'll use the current velocity to determine duration
        else
            duration = ((span - originX) / span) * duration; // user just moved a little, use the defult duration, otherwise it would be too slow
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:
		^
		{
            if (completion == DDMenuPanCompletionLeft) 
			{
                [self showLeftController:NO];
            } 
			else if (completion == DDMenuPanCompletionRight) 
			{
                [self showRightController:NO];
            } 
			else 
			{
                [self showRootController:NO];
            }
            [_rootViewController.view.layer removeAllAnimations];
            [self.view setUserInteractionEnabled:YES];
        }];
        
        CGPoint pos = _rootViewController.view.layer.position;
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        
        NSMutableArray *keyTimes = [[NSMutableArray alloc] initWithCapacity:bounce ? 3 : 2];
        NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:bounce ? 3 : 2];
        NSMutableArray *timingFunctions = [[NSMutableArray alloc] initWithCapacity:bounce ? 3 : 2];
        
        [values addObject:[NSValue valueWithCGPoint:pos]];
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        [keyTimes addObject:[NSNumber numberWithFloat:0.0f]];
        if (bounce) 
		{
            duration += kMenuBounceDuration;
            [keyTimes addObject:[NSNumber numberWithFloat:1.0f - ( kMenuBounceDuration / duration)]];
            if (completion == DDMenuPanCompletionLeft) 
			{
                
                [values addObject:[NSValue valueWithCGPoint:CGPointMake(((width/2) + span) + kMenuBounceOffset, pos.y)]];
                
            } 
			else if (completion == DDMenuPanCompletionRight) 
			{
                
                [values addObject:[NSValue valueWithCGPoint:CGPointMake(-((width/2) - (kMenuOverlayWidth-kMenuBounceOffset)), pos.y)]];
                
            } 
			else 
			{
                
                // depending on which way we're panning add a bounce offset
                if (_panDirection == DDMenuPanDirectionLeft) {
                    [values addObject:[NSValue valueWithCGPoint:CGPointMake((width/2) - kMenuBounceOffset, pos.y)]];
                } 
				else 
				{
                    [values addObject:[NSValue valueWithCGPoint:CGPointMake((width/2) + kMenuBounceOffset, pos.y)]];
                }
                
            }
            
            [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            
        }
        if (completion == DDMenuPanCompletionLeft) 
            [values addObject:[NSValue valueWithCGPoint:CGPointMake((width/2) + span, pos.y)]];
		else if (completion == DDMenuPanCompletionRight)
            [values addObject:[NSValue valueWithCGPoint:CGPointMake(-((width/2) - kMenuOverlayWidth), pos.y)]];
		else 
            [values addObject:[NSValue valueWithCGPoint:CGPointMake(width/2, pos.y)]];
        
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [keyTimes addObject:[NSNumber numberWithFloat:1.0f]];
        
        animation.timingFunctions = timingFunctions;
        animation.keyTimes = keyTimes;
        //animation.calculationMode = @"cubic";
        animation.values = values;
        animation.duration = duration;   
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [_rootViewController.view.layer addAnimation:animation forKey:nil];
        [CATransaction commit];   
    }    
}

- (void)tap:(UITapGestureRecognizer*)gesture 
{
    [gesture setEnabled:NO];
    [self showRootController:YES];
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer 
{
    // Check for horizontal pan gesture
    if (gestureRecognizer == _pan) 
	{

        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)gestureRecognizer;
        CGPoint translation = [panGesture translationInView:self.view];

        if ([panGesture velocityInView:self.view].x < 600 && sqrt(translation.x * translation.x) / sqrt(translation.y * translation.y) > 1) 
            return YES;
        
        return NO;
    }
    
    if (gestureRecognizer == _tap) 
	{
        
        if (_rootViewController && (_menuFlags.showingRightView || _menuFlags.showingLeftView)) 
            return CGRectContainsPoint(_rootViewController.view.frame, [gestureRecognizer locationInView:self.view]);
        
        return NO;
    }

    return YES;
   
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer 
	shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer 
{
    if (gestureRecognizer==_tap) 
        return YES;
    return NO;
}

- (void)showShadow:(BOOL)val 
{
    if (!_rootViewController) return;
    
    _rootViewController.view.layer.shadowOpacity = val ? 0.8f : 0.0f;
    if (val) 
	{
        _rootViewController.view.layer.cornerRadius = 4.0f;
        _rootViewController.view.layer.shadowOffset = CGSizeZero;
        _rootViewController.view.layer.shadowRadius = 4.0f;
        _rootViewController.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
    }
    
}

- (void)showRootController:(BOOL)animated 
{
    [_tap setEnabled:NO];
    _rootViewController.view.userInteractionEnabled = YES;

    CGRect frame = _rootViewController.view.frame;
    frame.origin.x = 0.0f;

    BOOL _enabled = [UIView areAnimationsEnabled];
    if (!animated) 
        [UIView setAnimationsEnabled:NO];
    
    [UIView animateWithDuration:.3 animations:
	^
	{
        
        _rootViewController.view.frame = frame;
        
    } 
					 completion:
	 ^(BOOL finished) 
	{
        
        if (_leftViewController && _leftViewController.view.superview) 
            [_leftViewController.view removeFromSuperview];
        
        if (_rightViewController && _rightViewController.view.superview) 
            [_rightViewController.view removeFromSuperview];
        
        _menuFlags.showingLeftView = NO;
        _menuFlags.showingRightView = NO;

        [self showShadow:NO];
        
    }];
    
    if (!animated)
        [UIView setAnimationsEnabled:_enabled];    
}

- (void)showLeftController:(BOOL)animated 
{
    if (!_menuFlags.canShowLeft) return;
    
    if (_rightViewController && _rightViewController.view.superview)
	{
        [_rightViewController.view removeFromSuperview];
        _menuFlags.showingRightView = NO;
    }
    
    if (_menuFlags.respondsToWillShowViewController)
        [self.delegate menuController:self willShowViewController:self.leftViewController];
	
    _menuFlags.showingLeftView = YES;
    [self showShadow:YES];

    UIView *view = self.leftViewController.view;
	CGRect frame = self.view.bounds;
	frame.size.width = kMenuFullWidth;
    view.frame = frame;
    [self.view insertSubview:view atIndex:0];
    [self.leftViewController viewWillAppear:animated];
    
    frame = _rootViewController.view.frame;
    frame.origin.x = CGRectGetMaxX(view.frame) - (kMenuFullWidth - kMenuDisplayedWidth);
    
    BOOL _enabled = [UIView areAnimationsEnabled];
    if (!animated)
        [UIView setAnimationsEnabled:NO];
    
    _rootViewController.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:.3 animations:
	^
	{
        _rootViewController.view.frame = frame;
    } 
					 completion:
	 ^(BOOL finished) 
	{
        [_tap setEnabled:YES];
    }];
    
    if (!animated) 
	{
        [UIView setAnimationsEnabled:_enabled];
    }
}

- (void)showRightController:(BOOL)animated 
{
    if (!_menuFlags.canShowRight) return;
    
    if (_leftViewController && _leftViewController.view.superview) 
	{
        [_leftViewController.view removeFromSuperview];
        _menuFlags.showingLeftView = NO;
    }
    
    if (_menuFlags.respondsToWillShowViewController) 
        [self.delegate menuController:self willShowViewController:self.rightViewController];

	_menuFlags.showingRightView = YES;
    [self showShadow:YES];

    UIView *view = self.rightViewController.view;
    CGRect frame = self.view.bounds;
	frame.origin.x += frame.size.width - kMenuFullWidth;
	frame.size.width = kMenuFullWidth;
    view.frame = frame;
    [self.view insertSubview:view atIndex:0];
    
    frame = _rootViewController.view.frame;
    frame.origin.x = -(frame.size.width - kMenuOverlayWidth);
    
    BOOL _enabled = [UIView areAnimationsEnabled];
    if (!animated) 
        [UIView setAnimationsEnabled:NO];
    
    _rootViewController.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:.3 animations:
	^
	{
        _rootViewController.view.frame = frame;
    } 
					 completion:
	 ^(BOOL finished) 
	{
        [_tap setEnabled:YES];
    }];
    
    if (!animated) 
	{
        [UIView setAnimationsEnabled:_enabled];
    }
}


#pragma mark Setters

- (void)setDelegate:(id<DDMenuControllerDelegate>)val 
{
    delegate = val;
    _menuFlags.respondsToWillShowViewController = [(id)self.delegate respondsToSelector:@selector(menuController:willShowViewController:)];    
}

- (void)setRightViewController:(UIViewController *)rightController 
{
    _rightViewController = rightController;
    _menuFlags.canShowRight = (_rightViewController!=nil);
	[self refreshNavButtons];
}

- (void)setLeftViewController:(UIViewController *)leftController 
{
    _leftViewController = leftController;
    _menuFlags.canShowLeft = (_leftViewController!=nil);
	[self refreshNavButtons];
}

- (void)setRootViewController:(UIViewController *)rootViewController 
{
    UIViewController *tempRoot = _rootViewController;
    _rootViewController = rootViewController;
    
    if (_rootViewController) 
	{
        if (tempRoot) 
		{
            [tempRoot.view removeFromSuperview];
            tempRoot = nil;
        }
        
        UIView *view = _rootViewController.view;
        view.frame = self.view.bounds;
        [self.view addSubview:view];

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        pan.delegate = (id<UIGestureRecognizerDelegate>)self;
        [view addGestureRecognizer:pan];
        _pan = pan;
        
    } 
	else
	{
        if (tempRoot) 
		{
            [tempRoot.view removeFromSuperview];
            tempRoot = nil;
        }
    }
	[self refreshNavButtons];
}

- (void)setRootController:(UIViewController *)controller animated:(BOOL)animated 
{
    if (!controller) 
	{
        [self setRootViewController:controller];
        return;
    }
    
    if (_menuFlags.showingLeftView) 
	{
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        // slide out then come back with the new root
        __block DDMenuController *selfRef = self;
        __block UIViewController *rootRef = _rootViewController;
        CGRect frame = rootRef.view.frame;
        frame.origin.x = rootRef.view.bounds.size.width;
        
        [UIView animateWithDuration:.1 animations:
		^
		{
            
            rootRef.view.frame = frame;
            
        } 
						 completion:
		 ^(BOOL finished) 
		{
            
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];

            [selfRef setRootViewController:controller];
            _rootViewController.view.frame = frame;
            [selfRef showRootController:animated];
            
        }];
    } 
	else 
	{
        // just add the root and move to it if it's not center
        [self setRootViewController:controller];
        [self showRootController:animated];
    }
}


#pragma mark - Root Controller Navigation

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated 
{
    NSAssert((_rootViewController!=nil), @"no root controller set");
    
    UINavigationController *navController = nil;
    
    if ([_rootViewController isKindOfClass:[UINavigationController class]]) 
	{
        navController = (UINavigationController*)_rootViewController;
    } 
	else if ([_rootViewController isKindOfClass:[UITabBarController class]]) 
	{
        _topViewController = [(UITabBarController*)_rootViewController selectedViewController];
        if ([_topViewController isKindOfClass:[UINavigationController class]]) 
		{
            navController = (UINavigationController*)_topViewController;
        }
    } 
    
    if (navController == nil) 
	{
        NSLog(@"root controller is not a navigation controller.");
        return;
    }
	
	if (_menuFlags.showingRightView) 
	{
		CGAffineTransform currentTransform = self.view.transform;
		
        [navController pushViewController:viewController animated:NO];
		        
        [UIView animateWithDuration:0.25f animations:
		 ^
		 {			 
			 if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) 
				 self.view.transform = CGAffineTransformConcat(currentTransform, CGAffineTransformMakeTranslation(0, kMenuDisplayedWidth));
			 else 
				 self.view.transform = CGAffineTransformConcat(currentTransform, CGAffineTransformMakeTranslation(kMenuDisplayedWidth, 0));
		 } 
						 completion:
		 ^(BOOL finished) 
		 {
			 [self showRootController:NO];
			 self.view.transform = CGAffineTransformIdentity;
		 }];
    } 
	else 
	{
        [navController pushViewController:viewController animated:animated];
    }
}

#pragma Internal Nav Handling 

- (void)refreshNavButtons
{
	if (!_rootViewController) return;
	
	if (_menuFlags.canShowLeft) 
	{
		if (!_leftBarButtonItem) 
		{
			_leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_menu_icon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showLeft:)];
		}
		self.topViewController.navigationItem.leftBarButtonItem = _leftBarButtonItem;
    } else
        self.topViewController.navigationItem.leftBarButtonItem = nil;
		
	if (_menuFlags.canShowRight) 
	{
		if (!_rightBarButtonItem) 
		{
			_rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_menu_icon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showRight:)];
		}
		self.topViewController.navigationItem.rightBarButtonItem = _rightBarButtonItem;
	}
	else
		self.topViewController.navigationItem.rightBarButtonItem = nil;
}

#pragma mark -
#pragma mark Overridden Getters

- (UIViewController *)topViewController
{
	_topViewController = nil;
    if ([_rootViewController isKindOfClass:[UINavigationController class]]) 
	{
        UINavigationController *navController = (UINavigationController*)_rootViewController;
        if ([[navController viewControllers] count] > 0) 
		{
            _topViewController = [[navController viewControllers] objectAtIndex:0];
        }
    } else if ([_rootViewController isKindOfClass:[UITabBarController class]]) 
	{
        UITabBarController *tabController = (UITabBarController*)_rootViewController;
        _topViewController = [tabController selectedViewController];
    } else 
	{
        _topViewController = _rootViewController;
    }
	return _topViewController;
}

#pragma mark - Actions 

- (void)showLeft:(id)sender 
{
    [self showLeftController:YES];
}

- (void)showRight:(id)sender 
{
    [self showRightController:YES];
}

@end
