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
#import <QuartzCore/QuartzCore.h>

#define kMenuFullWidth 320.0f
#define kScreenWidth 320.0f
#define kMenuLeftDisplayedWidth 200.0f
#define kMenuRightDisplayedWidth 280.0f
#define kMenuLeftOverlayWidth (320.0f - kMenuLeftDisplayedWidth) 
#define kMenuRightOverlayWidth (320.0f - kMenuRightDisplayedWidth)
#define kMenuBounceOffset 10.0f
#define kMenuBounceDuration .3f
#define kMenuSlideDuration .3f
#define KLeftTransformMakeRotation  -M_PI
#define KRightTransformMakeRotation M_PI


CGFloat const DDMenuControllerDefaultLeftOverlayWidth = kMenuLeftOverlayWidth;
CGFloat const DDMenuControllerDefaultRightOverlayWidth = kMenuRightOverlayWidth;

@implementation DDMenuController

@synthesize delegate;

@synthesize leftViewController=_leftViewController;
@synthesize rightViewController=_rightViewController;
@synthesize rootViewController=_rootViewController;

@synthesize autoLeftButtonImageName;
@synthesize leftButtonViewForPanArray;
@synthesize leftButtonViewForTapArray;
@synthesize leftButtonViewForTransitionArray;

@synthesize autoRightButtonImageName;
@synthesize rightButtonViewForPanArray;
@synthesize rightButtonViewForTapArray;
@synthesize rightButtonViewForTransitionArray;

@synthesize mustinitTouchAction;

@synthesize leftOverlayWidth = _leftOverlayWidth;
@synthesize rightOverlayWidth = _rightOverlayWidth;
@synthesize menuFullWidth = _menuFullWidth;
@synthesize transformRotationStatus = _transformRotationStatus;

@synthesize tap=_tap;
@synthesize pan=_pan;


@synthesize menuFlags = _menuFlags;

- (id)initWithRootViewController:(UIViewController*)controller 
{
    if ((self = [super init])) 
	{
        _rootViewController = controller;
        self.mustinitTouchAction = NO;
    }
    return self;
}

- (id)init 
{
    if ((self = [super init])) 
	{
        self.mustinitTouchAction = NO;
        
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
	
	// Set Defaults
	[self setLeftOverlayWidth:DDMenuControllerDefaultLeftOverlayWidth];
	[self setRightOverlayWidth:DDMenuControllerDefaultRightOverlayWidth];
	[self setMenuFullWidth:kMenuFullWidth];
	
    [self setRootViewController:_rootViewController]; // reset root
    
    if (!_tap) 
	{
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        tap.delegate = (id<UIGestureRecognizerDelegate>)self;
        [self.view addGestureRecognizer:tap];
        [tap setEnabled:NO];
        _tap = tap;
    }
    
    self.mustinitTouchAction = NO;
    [self performSelectorOnMainThread:@selector(initTouchAction) withObject:nil waitUntilDone:NO];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [_tap release];
    _tap = nil;
    
    [_pan release];
    _pan = nil;
    
    self.autoLeftButtonImageName = nil;
    self.leftButtonViewForPanArray = nil;
    self.leftButtonViewForTapArray = nil;
    self.leftButtonViewForTransitionArray = nil;
    
    self.autoRightButtonImageName = nil;
    self.rightButtonViewForPanArray = nil;
    self.rightButtonViewForTapArray = nil;
    self.rightButtonViewForTransitionArray = nil;
    
    [_leftViewController release];
    [_rightViewController release];
    [_rootViewController release];
}

-(void) initTouchAction {
    
    UIViewController<DDMenuControllerDelegate> *topViewController;
    topViewController = (UIViewController<DDMenuControllerDelegate>*) self.topViewController;
    if ( nil == topViewController ){
        return;
    }
    
    if ( nil == self.leftButtonViewForTapArray
        &&  [topViewController respondsToSelector:@selector(getLeftButtonViewForTapArray)] ) {
        self.leftButtonViewForTapArray = [topViewController getLeftButtonViewForTapArray];
    }
    if ( nil == self.leftButtonViewForPanArray
        && [topViewController respondsToSelector:@selector(getLeftButtonViewForPanArray)]) {
        self.leftButtonViewForPanArray = [topViewController getLeftButtonViewForPanArray];
    }
    if ( nil == self.leftButtonViewForTransitionArray
        && [topViewController respondsToSelector:@selector(getLeftButtonViewForTransitionArray)]){
        self.leftButtonViewForTransitionArray = [topViewController getLeftButtonViewForTransitionArray];
    }
    if ( nil == self.rightButtonViewForTapArray
        &&  [topViewController respondsToSelector:@selector(getRightButtonViewForTapArray)] ) {
        self.rightButtonViewForTapArray = [topViewController getRightButtonViewForTapArray];
    }
    if ( nil == self.rightButtonViewForPanArray
        && [topViewController respondsToSelector:@selector(getRightButtonViewForPanArray)]) {
        self.rightButtonViewForPanArray = [topViewController getRightButtonViewForPanArray];
    }
    if ( nil == self.rightButtonViewForTransitionArray
        && [topViewController respondsToSelector:@selector(getRightButtonViewForTransitionArray)]){
        self.rightButtonViewForTransitionArray = [topViewController getRightButtonViewForTransitionArray];
    }
    
    [self addGesture:[UITapGestureRecognizer class]
       withViewArray:self.leftButtonViewForTapArray action:@selector(leftButtonViewTap:)];
    [self addGesture:[UIPanGestureRecognizer class]
       withViewArray:self.leftButtonViewForPanArray action:@selector(leftPan:)];
    
    [self addGesture:[UITapGestureRecognizer class]
       withViewArray:self.rightButtonViewForTapArray action:@selector(rightButtonViewTap:)];
    [self addGesture:[UIPanGestureRecognizer class]
       withViewArray:self.rightButtonViewForPanArray action:@selector(rightPan:)];
}

-(void) addGesture:(Class) className withViewArray:(NSArray *) viewArray action:(SEL) action {
    if ( viewArray && [viewArray count]>0 ){
        for (UIView *item in viewArray) {
            id gesture = [[className alloc] initWithTarget:self action:action];
            [gesture setDelegate:self];
            [item addGestureRecognizer:gesture];
            [gesture release];
        }
    }
}

- (void)leftButtonViewTap:(UITapGestureRecognizer*)gesture {
    [self showLeftController:YES];
}

- (void)rightButtonViewTap:(UITapGestureRecognizer*)gesture {
    [self showRightController:YES];
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
            frame.origin.x = frame.size.width - self.leftOverlayWidth;
        } else if (_menuFlags.showingRightView) 
		{
            frame.origin.x = -(frame.size.width - self.rightOverlayWidth);
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

- (void)leftPan:(UIPanGestureRecognizer*)gesture {
    [self pan:gesture leftOrRight:DDMenuPanDirectionLeft];
}

- (void)rightPan:(UIPanGestureRecognizer*)gesture
{
    [self pan:gesture leftOrRight:DDMenuPanDirectionRight];
}

- (void)pan:(UIPanGestureRecognizer*)gesture
{
    [self pan:gesture leftOrRight:DDMenuPanDirectionLeftRight];
}

- (void)pan:(UIPanGestureRecognizer*)gesture leftOrRight:(DDMenuPanDirection) leftOrRight
{
    if (gesture.state == UIGestureRecognizerStateBegan) 
	{
        [self showShadow:YES];
        _panOriginX = _rootViewController.view.frame.origin.x;
        _panVelocity = CGPointMake(0.0f, 0.0f);
        
        if([gesture velocityInView:self.view].x > 0) {
            _panDirection = DDMenuPanDirectionRight;
        } else {
            _panDirection = DDMenuPanDirectionLeft;
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged) 
	{
        CGPoint velocity = [gesture velocityInView:self.view];
        if((velocity.x*_panVelocity.x + velocity.y*_panVelocity.y) < 0) {
            _panDirection = (_panDirection == DDMenuPanDirectionRight) ? DDMenuPanDirectionLeft : DDMenuPanDirectionRight;
        }
        
        _panVelocity = velocity;
		//_panDirection = _menuFlags.showingLeftView ? DDMenuPanDirectionLeft : DDMenuPanDirectionRight;
		
        CGPoint translation = [gesture translationInView:self.view];
        
        if ( DDMenuPanDirectionLeft == leftOrRight && translation.x < 0 ) {
            return;
        }
        if ( DDMenuPanDirectionRight == leftOrRight && translation.x > 0 ) {
            return;
        }
		
        CGRect frame = CGRectMake(_panOriginX + translation.x, _rootViewController.view.frame.origin.y, _rootViewController.view.bounds.size.width, _rootViewController.view.bounds.size.height);
        
        _rootViewController.view.frame = frame;
        
        if ( frame.origin.x > 0.0f ){
            for (UIView *view in self.leftButtonViewForTransitionArray) {
                view.transform = CGAffineTransformMakeRotation(KLeftTransformMakeRotation * (frame.origin.x /( kScreenWidth - self.leftOverlayWidth)));
            }
            self.transformRotationStatus = KLeftTransformMakeRotation * (frame.origin.x /( kScreenWidth - self.leftOverlayWidth));
        } else if ( frame.origin.x < 0.0f) {
            for (UIView *view in self.rightButtonViewForTransitionArray) {
                view.transform = CGAffineTransformMakeRotation(KRightTransformMakeRotation * (frame.origin.x /( kScreenWidth - self.rightOverlayWidth)));
            }
            self.transformRotationStatus = KRightTransformMakeRotation * (frame.origin.x /( kScreenWidth - self.rightOverlayWidth));
        }
        
        if (frame.origin.x > 0.0f && !_menuFlags.showingLeftView) {
            if(_menuFlags.showingRightView) {
                _menuFlags.showingRightView = NO;
                [self.rightViewController.view removeFromSuperview];
            }
            
            if (_menuFlags.canShowLeft) {
                _menuFlags.showingLeftView = YES;
                CGRect frame = self.view.bounds;
				frame.size.width = kMenuFullWidth;
                self.leftViewController.view.frame = frame;
                [self.view insertSubview:self.leftViewController.view atIndex:0];
            } else {
                frame.origin.x = 0.0f; // ignore right view if it's not set
            }
        } else if (frame.origin.x < 0.0f && !_menuFlags.showingRightView) {
            if(_menuFlags.showingLeftView) {
                _menuFlags.showingLeftView = NO;
                [self.leftViewController.view removeFromSuperview];
            }
            
            if (_menuFlags.canShowRight) {
                _menuFlags.showingRightView = YES;
                CGRect frame = self.view.bounds;
				frame.origin.x += frame.size.width - kMenuFullWidth;
				frame.size.width = kMenuFullWidth;
                self.rightViewController.view.frame = frame;
                [self.view insertSubview:self.rightViewController.view atIndex:0];
            } else {
                frame.origin.x = 0.0f; // ignore left view if it's not set
            }
            
        }
		
        /*
		CGFloat percentOpen = (_panOriginX + translation.x) / kMenuLeftDisplayedWidth;
		// Damping factor on alpha transform
		CGFloat percentAlpha = (percentOpen / 1.2);
		self.leftViewController.view.alpha = MIN(1, percentAlpha);
         */
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
//        else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateRecognized || gesture.state == UIGestureRecognizerStateFailed) {
        
        //  Finishing moving to left, right or root view with current pan velocity
        [self.view setUserInteractionEnabled:NO];
        
        DDMenuPanCompletion completion = DDMenuPanCompletionRoot; // by default animate back to the root
        
        if (_panDirection == DDMenuPanDirectionRight && _menuFlags.showingLeftView) {
            completion = DDMenuPanCompletionLeft;
        } else if (_panDirection == DDMenuPanDirectionLeft && _menuFlags.showingRightView) {
            completion = DDMenuPanCompletionRight;
        }
        
        CGPoint velocity = [gesture velocityInView:self.view];    
        if (velocity.x < 0.0f) {
            velocity.x *= -1.0f;
        }
        BOOL bounce = (velocity.x > 800);
        CGFloat originX = _rootViewController.view.frame.origin.x;
        CGFloat width = _rootViewController.view.frame.size.width;
        CGFloat span = (width - self.leftOverlayWidth);
        CGFloat duration = kMenuSlideDuration; // default duration with 0 velocity
        
        
        if (bounce) {
            duration = (span / velocity.x); // bouncing we'll use the current velocity to determine duration
        } else {
            duration = ((span - originX) / span) * duration; // user just moved a little, use the defult duration, otherwise it would be too slow
        }
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            if (completion == DDMenuPanCompletionLeft) {
                [self showLeftController:NO];
            } else if (completion == DDMenuPanCompletionRight) {
                [self showRightController:NO];
            } else {
                [self showRootController:NO];
            }
            [_rootViewController.view.layer removeAllAnimations];
            
            for (UIView *view in self.leftButtonViewForTransitionArray) {
                [view.layer removeAllAnimations];
            }
            for (UIView *view in self.rightButtonViewForTransitionArray) {
                [view.layer removeAllAnimations];
            }
            [self.view setUserInteractionEnabled:YES];
        }];
        
        CGPoint pos = _rootViewController.view.layer.position;
        //CGAffineTransform transform = self.transformStatus;
        
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        CAKeyframeAnimation *animationTransform = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
        
        NSMutableArray *keyTimes = [[NSMutableArray alloc] initWithCapacity:bounce ? 3 : 2];
        NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:bounce ? 3 : 2];
        NSMutableArray *valuesTransform = [[NSMutableArray alloc] initWithCapacity:bounce ? 3 : 2];
        NSMutableArray *timingFunctions = [[NSMutableArray alloc] initWithCapacity:bounce ? 3 : 2];
        
        [values addObject:[NSValue valueWithCGPoint:pos]];
        [valuesTransform addObject:[NSNumber numberWithFloat:self.transformRotationStatus]];
        
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        [keyTimes addObject:[NSNumber numberWithFloat:0.0f]];
        if (bounce) {
            duration += kMenuBounceDuration;
            [keyTimes addObject:[NSNumber numberWithFloat:1.0f - ( kMenuBounceDuration / duration)]];
            if (completion == DDMenuPanCompletionLeft) {
                [values addObject:[NSValue valueWithCGPoint:CGPointMake(((width/2) + span) + kMenuBounceOffset, pos.y)]];
                [valuesTransform addObject:[NSNumber numberWithFloat:(KLeftTransformMakeRotation-self.transformRotationStatus)/2]];
         //[valuesTransform addObject:[NSValue valueWithCGAffineTransform:CGAffineTransformMakeRotation(KLeftTransformMakeRotation/2)]];
            } else if (completion == DDMenuPanCompletionRight) {
                [values addObject:[NSValue valueWithCGPoint:CGPointMake(-((width/2) - (self.rightOverlayWidth-kMenuBounceOffset)), pos.y)]];
                [valuesTransform addObject:[NSNumber numberWithFloat:(KRightTransformMakeRotation-self.transformRotationStatus)/2]];
                //[valuesTransform addObject:[NSValue valueWithCGAffineTransform:CGAffineTransformMakeRotation(KRightTransformMakeRotation/2)]];
            } else {
                // depending on which way we're panning add a bounce offset
                if (_panDirection == DDMenuPanDirectionLeft) {
                    [values addObject:[NSValue valueWithCGPoint:CGPointMake((width/2) - kMenuBounceOffset, pos.y)]];
                } else {
                    [values addObject:[NSValue valueWithCGPoint:CGPointMake((width/2) + kMenuBounceOffset, pos.y)]];
                }
            }
            [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        }
        if (completion == DDMenuPanCompletionLeft) {
            [values addObject:[NSValue valueWithCGPoint:CGPointMake((width/2) + span, pos.y)]];
            [valuesTransform addObject:[NSNumber numberWithFloat:KLeftTransformMakeRotation]];
            //[valuesTransform addObject:[NSValue valueWithCGAffineTransform:CGAffineTransformMakeRotation(KLeftTransformMakeRotation)]];
        } else if (completion == DDMenuPanCompletionRight) {
            [values addObject:[NSValue valueWithCGPoint:CGPointMake(-((width/2) - self.rightOverlayWidth), pos.y)]];
            [valuesTransform addObject:[NSNumber numberWithFloat: - KRightTransformMakeRotation]];
            //[valuesTransform addObject:[NSValue valueWithCGAffineTransform:CGAffineTransformMakeRotation(KRightTransformMakeRotation)]];
        } else {
            [valuesTransform addObject:[NSNumber numberWithFloat:0]];
            //[valuesTransform addObject:[NSValue valueWithCGAffineTransform:CGAffineTransformMakeRotation(0)]];
            [values addObject:[NSValue valueWithCGPoint:CGPointMake(width/2, pos.y)]];
        }
        
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
        
        animationTransform.timingFunctions = timingFunctions;
        animationTransform.keyTimes = keyTimes;
        animationTransform.values = valuesTransform;
        animationTransform.duration = duration;
        animationTransform.removedOnCompletion = NO;
        animationTransform.fillMode = kCAFillModeForwards;
        
        if (completion == DDMenuPanCompletionLeft) {
            for (UIView *view in self.leftButtonViewForTransitionArray) {
                [view.layer addAnimation:animationTransform forKey:nil];
            }
        } else if (completion == DDMenuPanCompletionRight) {
            for (UIView *view in self.rightButtonViewForTransitionArray) {
                [view.layer addAnimation:animationTransform forKey:nil];
            }
        } else {
            
        }
        
        [CATransaction commit];
        [timingFunctions release];
        [keyTimes release];
        [values release];
        
		//[self showRootController:YES];
		//[self.view setUserInteractionEnabled:YES];
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
		
		if (_menuFlags.showingLeftView) {
			// Alpha start
			//self.leftViewController.view.alpha = 0.2f;
		}
        for (UIView *view in self.leftButtonViewForTransitionArray) {
            view.transform = CGAffineTransformMakeRotation(0.0);
        }
        for (UIView *view in self.rightButtonViewForTransitionArray) {
            view.transform = CGAffineTransformMakeRotation(0.0);
        }
        
        _rootViewController.view.frame = frame;
        
    } 
					 completion:
	 ^(BOOL finished) 
	{
        if (_leftViewController && _leftViewController.view.superview) {
            [_leftViewController.view removeFromSuperview];
        }
        
        if (_rightViewController && _rightViewController.view.superview) {
            [_rightViewController.view removeFromSuperview];
        }
        
        _menuFlags.showingLeftView = NO;
        _menuFlags.showingRightView = NO;
        /*
        if (_leftViewController && _leftViewController.view.superview)
            [_leftViewController.view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3f];
        
        if (_rightViewController && _rightViewController.view.superview) 
            [_rightViewController.view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3f];
        
        _menuFlags.showingLeftView = NO;
        _menuFlags.showingRightView = NO;
         */

        [self showShadow:NO];
        
        if ( self.mustinitTouchAction ) {
            self.mustinitTouchAction = NO;
            [self performSelectorOnMainThread:@selector(initTouchAction) withObject:nil waitUntilDone:NO];
        }
        
    }];
    
    if (!animated)
        [UIView setAnimationsEnabled:_enabled];    
	
	//[_pan setEnabled:NO];
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
	//frame.size.width =  kScreenWidth - self.leftOverlayWidth;
    frame.size.width =  self.menuFullWidth;
    view.frame = frame;
    [self.view insertSubview:view atIndex:0];
    [self.leftViewController viewWillAppear:animated];
    
    frame = _rootViewController.view.frame;
    //frame.origin.x = kScreenWidth - self.leftOverlayWidth;
    frame.origin.x = CGRectGetMaxX(view.frame) - self.leftOverlayWidth;
    
    BOOL _enabled = [UIView areAnimationsEnabled];
    if (!animated)
        [UIView setAnimationsEnabled:NO];
    
	// Add alpha fade here
	//self.leftViewController.view.alpha = 0.2;
    _rootViewController.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:.3 animations:
	^
	{
		//self.leftViewController.view.alpha = 1.0;
        _rootViewController.view.frame = frame;
        for (UIView *view in self.leftButtonViewForTransitionArray) {
            view.transform = CGAffineTransformMakeRotation(KLeftTransformMakeRotation);
        }
    }
					 completion:
	 ^(BOOL finished) 
	{
		//[_pan setEnabled:YES];
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
	frame.origin.x += frame.size.width - self.menuFullWidth;
	frame.size.width = self.menuFullWidth;
    view.frame = frame;
    [self.view insertSubview:view atIndex:0];
    
    frame = _rootViewController.view.frame;
    frame.origin.x = -(frame.size.width - self.rightOverlayWidth);
    
    BOOL _enabled = [UIView areAnimationsEnabled];
    if (!animated) 
        [UIView setAnimationsEnabled:NO];
    
    _rootViewController.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:.3 animations:
	^
	{
        _rootViewController.view.frame = frame;
        for (UIView *view in self.rightButtonViewForTransitionArray) {
            view.transform = CGAffineTransformMakeRotation(KRightTransformMakeRotation);
        }
    }
					 completion:
	 ^(BOOL finished) 
	{
		//[_pan setEnabled:YES];
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
    [self setRightViewController:rightController autoButtonIamgeName:nil];
}
- (void)setRightViewController:(UIViewController *)rightController autoButtonIamgeName:(NSString *) name
{
    if ( _rightViewController != rightController ){
        [_rightViewController release];
        _rightViewController = [rightController retain];
    }
    
    self.autoRightButtonImageName = name;
    _menuFlags.canShowRight = (_rightViewController!=nil);
	[self refreshNavButtons];
}

- (void)setLeftViewController:(UIViewController *)leftController
{
    [self setLeftViewController:leftController autoButtonIamgeName:nil];
}
- (void)setLeftViewController:(UIViewController *)leftController autoButtonIamgeName:(NSString *) name
{
    if ( _leftViewController != leftController ){
        [_leftViewController release];
        _leftViewController = [leftController retain];
    }
    
    self.autoLeftButtonImageName = name;
    _menuFlags.canShowLeft = (_leftViewController!=nil);
	[self refreshNavButtons];
}

- (void)setRootViewController:(UIViewController *)rootController
{
    if ( _rootViewController != rootController )
    {
        if (_rootViewController) {
            [_rootViewController.view removeFromSuperview];
            [_rootViewController release];
        }
        _rootViewController = [rootController retain];
    }
    if (_rootViewController && _rootViewController.view.superview != self.view ) {
        UIView *view = _rootViewController.view;
        view.frame = self.view.bounds;
        [self.view addSubview:view];
        
        [_pan release];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        pan.delegate = (id<UIGestureRecognizerDelegate>)self;
        [view addGestureRecognizer:pan];
        _pan = [pan retain];
        [pan release];
        
        self.leftButtonViewForTapArray = nil;
        self.leftButtonViewForPanArray = nil;
        self.leftButtonViewForTransitionArray = nil;
        self.rightButtonViewForTapArray = nil;
        self.rightButtonViewForPanArray = nil;
        self.rightButtonViewForTransitionArray = nil;
        
        mustinitTouchAction = YES;
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
				self.view.transform = CGAffineTransformConcat(currentTransform, CGAffineTransformMakeTranslation(0, self.rightOverlayWidth));
			 else
                 self.view.transform = CGAffineTransformConcat(currentTransform, CGAffineTransformMakeTranslation(kMenuRightDisplayedWidth, 0));
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
    UIViewController *topController = self.topViewController;
    
    if ( !topController ) {
        return;
    }
    
	//页面菜单
    if (_menuFlags.canShowLeft && self.autoLeftButtonImageName) {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:self.autoLeftButtonImageName] style:UIBarButtonItemStyleBordered target:self action:@selector(showLeft:)];
        topController.navigationItem.leftBarButtonItem = button;
        [button release];
    } else {
        topController.navigationItem.leftBarButtonItem = nil;
    }
    
    if (_menuFlags.canShowRight && self.autoRightButtonImageName) {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:self.autoRightButtonImageName] style:UIBarButtonItemStyleBordered  target:self action:@selector(showRight:)];
        topController.navigationItem.rightBarButtonItem = button;
        [button release];
    } else {
        topController.navigationItem.rightBarButtonItem = nil;
    }
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
