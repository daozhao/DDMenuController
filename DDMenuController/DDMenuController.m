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

#define kMenuLeftDisplayedWidth 200.0f
#define kMenuRightDisplayedWidth 280.0f

#define kMenuBounceOffset 10.0f
#define kMenuBounceDuration .3f
#define kMenuSlideDuration .3f

#define KLeftTransformMakeRotation  M_PI
#define KRightTransformMakeRotation -M_PI


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

@synthesize transformRotationStatus = _transformRotationStatus;

@synthesize tap=_tap;
@synthesize pan=_pan;

@synthesize canShowLeft;
@synthesize canShowRight;
@synthesize autoShowLeftOnIpadAtLandscape;


@synthesize menuFlags = _menuFlags;


- (Boolean) canShowLeft
{
    return self.menuFlags.canShowLeft;
}

- (void) setCanShowLeft:(Boolean)isShow
{
    _menuFlags.canShowLeft = isShow;
    [self refreshNavButtons];
}

- (Boolean) canShowRight
{
    return self.menuFlags.canShowRight;
}

- (void) setCanShowRight:(Boolean)isShow
{
    _menuFlags.canShowRight = isShow;
    [self refreshNavButtons];
}

- (id)initWithRootViewController:(UIViewController*)controller 
{
    if ((self = [super init])) 
	{
        _rootViewController = controller;
        self.mustinitTouchAction = NO;
        self.autoShowLeftOnIpadAtLandscape = YES;
    }
    return self;
}

- (id)init 
{
    if ((self = [super init])) 
	{
//        self.mustinitTouchAction = NO;
//        self.autoShowLeftOnIpadAtLandscape = YES;
        
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
    
    self.mustinitTouchAction = NO;
    [self performSelectorOnMainThread:@selector(initTouchAction) withObject:nil waitUntilDone:NO];
//    NSLog(@"is ipad:%d",ISIPAD);
    
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

-(void)setRootViewFrame
{
    CGRect frame = self.view.bounds;
    _rootViewController.view.frame = frame;
    _rootViewController.view.autoresizingMask = self.view.autoresizingMask;
    
    if ( self.autoShowLeftOnIpadAtLandscape && SELF_VIEWCONTROLER_IS_IPAD_LANDSCAPE ){
        _rootViewController.view.frame= CGRectMake(frame.origin.x + kMenuLeftDisplayedWidth, frame.origin.y,frame.size.width - kMenuLeftDisplayedWidth,frame.size.height );
        
    }
    
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    if (_rootViewController) 
	{
        [_rootViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];

        [self setRootViewFrame];
//        CGRect frame = self.view.bounds;
//        _rootViewController.view.frame = frame;
//        _rootViewController.view.autoresizingMask = self.view.autoresizingMask;
        
        if (_menuFlags.showingLeftView)
		{
//            frame.origin.x = kMenuLeftDisplayedWidth; // frame.size.width - self.leftOverlayWidth;
            [self showLeftController:NO];
            
        } else if (_menuFlags.showingRightView) {
            
//            frame.origin.x = - kMenuRightDisplayedWidth; // -(frame.size.width - self.rightOverlayWidth);
            [self showRightController:NO];
        } else if (self.autoShowLeftOnIpadAtLandscape && SELF_VIEWCONTROLER_IS_IPAD_LANDSCAPE ){
            [self showLeftController:NO];
        }
        
        
        [self showShadow:(_rootViewController.view.layer.shadowOpacity!=0.0f)];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration 
{
//    NSLog(@"is ipad:%d",ISIPAD);
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
    float zeroX = 0.0f;
    
    if ( self.autoShowLeftOnIpadAtLandscape && SELF_VIEWCONTROLER_IS_IPAD_LANDSCAPE ){
        zeroX = kMenuLeftDisplayedWidth;
    }

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
		
        CGPoint translation = [gesture translationInView:self.view];
        
        if ( DDMenuPanDirectionLeft == leftOrRight && translation.x < zeroX ) {
            return;
        }
        if ( DDMenuPanDirectionRight == leftOrRight && translation.x > zeroX ) {
            return;
        }
        if ( !self.canShowRight && translation.x < zeroX  ) {
            return;
        }
        if ( !self.canShowLeft && translation.x > zeroX ) {
            return;
        }
		
        CGRect frame = CGRectMake(_panOriginX + translation.x, _rootViewController.view.frame.origin.y, _rootViewController.view.bounds.size.width, _rootViewController.view.bounds.size.height);
        
        if ( frame.origin.x < kMenuLeftDisplayedWidth && frame.origin.x > zeroX - kMenuRightDisplayedWidth ){
            _rootViewController.view.frame = frame;
        
            if ( frame.origin.x > zeroX ){
                
                self.transformRotationStatus = KLeftTransformMakeRotation * (frame.origin.x /kMenuLeftDisplayedWidth );
                for (UIView *view in self.leftButtonViewForTransitionArray) {
                    view.transform = CGAffineTransformMakeRotation(self.transformRotationStatus);
                }
            } else if ( frame.origin.x < zeroX) {
                self.transformRotationStatus = -KRightTransformMakeRotation * ((frame.origin.x - zeroX) /kMenuRightDisplayedWidth );
                for (UIView *view in self.rightButtonViewForTransitionArray) {
                    view.transform = CGAffineTransformMakeRotation(self.transformRotationStatus);
                }
            }
        }
        
        if (frame.origin.x > zeroX && !_menuFlags.showingLeftView) {
            if(_menuFlags.showingRightView) {
                _menuFlags.showingRightView = NO;
                [self.rightViewController.view removeFromSuperview];
            }
            
            if (_menuFlags.canShowLeft) {
                _menuFlags.showingLeftView = YES;
                CGRect frame = self.view.bounds;
				frame.size.width = kMenuLeftDisplayedWidth; // kMenuFullWidth;
                self.leftViewController.view.frame = frame;
                [self.view insertSubview:self.leftViewController.view atIndex:0];
            } else {
                frame.origin.x = 0.0f; // ignore right view if it's not set
            }
        } else if (frame.origin.x < zeroX && !_menuFlags.showingRightView) {
            if(_menuFlags.showingLeftView) {
                if ( !(self.autoShowLeftOnIpadAtLandscape && SELF_VIEWCONTROLER_IS_IPAD_LANDSCAPE) ){
                    _menuFlags.showingLeftView = NO;
                    [self.leftViewController.view removeFromSuperview];
                }
            }
            
            if (_menuFlags.canShowRight) {
                _menuFlags.showingRightView = YES;
                CGRect frame = self.view.bounds;
                
                frame.origin.x = frame.size.width - kMenuRightDisplayedWidth;
                frame.size.width = kMenuRightDisplayedWidth;
                
                self.rightViewController.view.frame = frame;
                [self.view insertSubview:self.rightViewController.view atIndex:0];
            } else {
                frame.origin.x = zeroX; // ignore left view if it's not set
            }
            
        }
		
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        
        //  Finishing moving to left, right or root view with current pan velocity
        if (_panDirection == DDMenuPanDirectionRight && _menuFlags.showingLeftView && !(self.autoShowLeftOnIpadAtLandscape && SELF_VIEWCONTROLER_IS_IPAD_LANDSCAPE) ) {
            [self showLeftController:YES];
        } else if (_panDirection == DDMenuPanDirectionLeft && _menuFlags.showingRightView) {
            [self showRightController:YES];
        } else {
            [self showRootController:YES];
            
        }
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
//    if (!_rootViewController) return;
//    
//    _rootViewController.view.layer.shadowOpacity = val ? 0.8f : 0.0f;
//    if (val) 
//	{
//        _rootViewController.view.layer.cornerRadius = 4.0f;
//        _rootViewController.view.layer.shadowOffset = CGSizeZero;
//        _rootViewController.view.layer.shadowRadius = 4.0f;
//        _rootViewController.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
//    }
//    
}

- (void)showRootController:(BOOL)animated 
{
    [_tap setEnabled:NO];
    _rootViewController.view.userInteractionEnabled = YES;

    CGRect frame = _rootViewController.view.frame;
    frame.origin.x = 0.0f;
    
    if ( self.autoShowLeftOnIpadAtLandscape && SELF_VIEWCONTROLER_IS_IPAD_LANDSCAPE
        && _leftViewController && !_leftViewController.view.superview) {
        [self showLeftController:animated];
        
    }
    
    if (animated){
        if (_menuFlags.showingRightView ) {
            if ( self.autoShowLeftOnIpadAtLandscape && SELF_VIEWCONTROLER_IS_IPAD_LANDSCAPE) {
                frame.origin.x = kMenuLeftDisplayedWidth;
                _menuFlags.showingLeftView = YES;
             }
            [self showControllerAnimation:frame rotationsView:self.rightButtonViewForTransitionArray rotationsValue:0.0f];
        } else if (_menuFlags.showingLeftView ) {
            if ( self.autoShowLeftOnIpadAtLandscape && SELF_VIEWCONTROLER_IS_IPAD_LANDSCAPE) {
                return;
            }
            [self showControllerAnimation:frame rotationsView:self.leftButtonViewForTransitionArray rotationsValue:0.0f];
        }
    } else {
        _rootViewController.view.frame = frame;
        for (UIView *view in self.leftButtonViewForTransitionArray) {
            view.transform = CGAffineTransformMakeRotation(0.0f);
        }
        for (UIView *view in self.rightButtonViewForTransitionArray) {
            view.transform = CGAffineTransformMakeRotation(0.0f);
        }
        [_tap setEnabled:NO];
        if ( self.mustinitTouchAction ) {
            self.mustinitTouchAction = NO;
            [self performSelectorOnMainThread:@selector(initTouchAction) withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)showLeftController:(BOOL)animated 
{
//    NSLog(@"Interface Orientation is Landscape:%d",UIInterfaceOrientationIsLandscape(self.interfaceOrientation));
//    NSLog(@"Interface Orientation is ipad and Landscape:%d",SELF_VIEWCONTROLER_IS_IPAD_LANDSCAPE);
    if (!_menuFlags.canShowLeft) return;
    
    if (_menuFlags.showingLeftView  && SELF_VIEWCONTROLER_IS_IPAD_LANDSCAPE) {
            return;
    }
    
    if (_rightViewController && _rightViewController.view.superview)
	{
        [_rightViewController.view removeFromSuperview];
        _menuFlags.showingRightView = NO;
    }
    
    if (_menuFlags.respondsToWillShowViewController)
        [self.delegate menuController:self willShowViewController:self.leftViewController];
	
    _menuFlags.showingLeftView = YES;
    [self showShadow:YES];
    
    _rootViewController.view.userInteractionEnabled = NO;
    
    UIView *view = self.leftViewController.view;
	CGRect frame = self.view.bounds;
    frame.size.width =  kMenuLeftDisplayedWidth; 
    view.frame = frame;
    [self.view insertSubview:view atIndex:0];
    [self.leftViewController viewWillAppear:animated];
    
    frame = _rootViewController.view.frame;
    frame.origin.x =  kMenuLeftDisplayedWidth;
//    RECTLOG(self.view.frame, @" applicationFrame");
    if ( SELF_VIEWCONTROLER_IS_IPAD_LANDSCAPE ) {
        frame.size.width = [[UIScreen mainScreen] applicationFrame].size.height - kMenuLeftDisplayedWidth;
        _rootViewController.view.userInteractionEnabled = YES;
        
    }
    
    if (animated){
        [self showControllerAnimation:frame rotationsView:self.leftButtonViewForTransitionArray rotationsValue:KLeftTransformMakeRotation];
    } else {
        _rootViewController.view.frame = frame;
        for (UIView *view in self.leftButtonViewForTransitionArray) {
            view.transform = CGAffineTransformMakeRotation(KLeftTransformMakeRotation);
        }
        [_tap setEnabled:YES];
    }
}

- (void)showRightController:(BOOL)animated
{
    if (!_menuFlags.canShowRight) return;
    
    if (_leftViewController && _leftViewController.view.superview && !(SELF_VIEWCONTROLER_IS_IPAD_LANDSCAPE && self.autoShowLeftOnIpadAtLandscape) )
	{
        if ( !(self.autoShowLeftOnIpadAtLandscape && SELF_VIEWCONTROLER_IS_IPAD_LANDSCAPE) ) {
            [_leftViewController.view removeFromSuperview];
            _menuFlags.showingLeftView = NO;
        }
    }
    
    if (_menuFlags.respondsToWillShowViewController) 
        [self.delegate menuController:self willShowViewController:self.rightViewController];

	_menuFlags.showingRightView = YES;
    [self showShadow:YES];

    UIView *view = self.rightViewController.view;
    
    CGRect frame = self.view.bounds;
	frame.origin.x = frame.size.width - kMenuRightDisplayedWidth ;
	frame.size.width = kMenuRightDisplayedWidth;
    
    view.frame = frame;
    
    [self.view insertSubview:view atIndex:0];
    [self.rightViewController viewWillAppear:animated];
    
    frame = _rootViewController.view.frame;
    frame.origin.x = - kMenuRightDisplayedWidth ; //self.rightOverlayWidth;
    if ( SELF_VIEWCONTROLER_IS_IPAD_LANDSCAPE ){
        frame.origin.x = kMenuLeftDisplayedWidth - kMenuRightDisplayedWidth;
//        NSLog(@" root view :%@",_rootViewController.view);
//        NSLog(@" root view subview :%@",_rootViewController.view.subviews);
//        NSLog(@" root view prerent :%@",_rootViewController.view.superview);
//        NSLog(@" root view prerent subview :%@",_rootViewController.view.superview.subviews);
    }
    
    _rootViewController.view.userInteractionEnabled = NO;
    if (animated){
        [self showControllerAnimation:frame rotationsView:self.rightButtonViewForTransitionArray rotationsValue:KRightTransformMakeRotation];
    } else {
        _rootViewController.view.frame = frame;
        for (UIView *view in self.rightButtonViewForTransitionArray) {
            view.transform = CGAffineTransformMakeRotation(KRightTransformMakeRotation);
        }
        [_tap setEnabled:YES];
    }
}

-(void) showControllerAnimation:(CGRect)toFrame rotationsView:(NSArray *) viewTransitionArray rotationsValue:(CGFloat) rotationsValue
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        
        _rootViewController.view.frame = toFrame;
        [_rootViewController.view.layer removeAllAnimations];
//        RECTLOG(_rootViewController.view.frame,@" rootView(%@) after move frame",_rootViewController.view);
        
        for (UIView *view in viewTransitionArray) {
            [view.layer removeAllAnimations];
            view.transform = CGAffineTransformMakeRotation(rotationsValue);
        }
        [self.view setUserInteractionEnabled:YES];
        [_tap setEnabled:YES];
        
        if ( _rootViewController.view.userInteractionEnabled ){
            if (_leftViewController && _leftViewController.view.superview) {
                if ( !(self.autoShowLeftOnIpadAtLandscape && SELF_VIEWCONTROLER_IS_IPAD_LANDSCAPE ) ) {
                    [_leftViewController.view removeFromSuperview];
                    _menuFlags.showingLeftView = NO;
                }
            }
            
            if (_rightViewController && _rightViewController.view.superview) {
                [_rightViewController.view removeFromSuperview];
                _menuFlags.showingRightView = NO;
            }
            
            [_tap setEnabled:NO];
            [self showShadow:NO];
            
            if ( self.mustinitTouchAction ) {
                self.mustinitTouchAction = NO;
                [self performSelectorOnMainThread:@selector(initTouchAction) withObject:nil waitUntilDone:NO];
            }
        }
    }];
    
    CGPoint pos = _rootViewController.view.layer.position;
    CGFloat duration = kMenuSlideDuration; // default duration with 0 velocity
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CAKeyframeAnimation *animationTransform = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    NSMutableArray *keyTimes = [[NSMutableArray alloc] initWithCapacity: 2];
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity: 2];
    NSMutableArray *valuesTransform = [[NSMutableArray alloc] initWithCapacity:2];
    NSMutableArray *timingFunctions = [[NSMutableArray alloc] initWithCapacity:2];
    
    [values addObject:[NSValue valueWithCGPoint:pos]];
    [values addObject:[NSValue valueWithCGPoint:CGPointMake(toFrame.origin.x + toFrame.size.width/2, toFrame.origin.y + toFrame.size.height/2)]];
    [valuesTransform addObject:[NSNumber numberWithFloat:self.transformRotationStatus]];
    [valuesTransform addObject:[NSNumber numberWithFloat:rotationsValue]];
    
    self.transformRotationStatus = rotationsValue;
    
    [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [keyTimes addObject:[NSNumber numberWithFloat:0.0f]];
   
    [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [keyTimes addObject:[NSNumber numberWithFloat:1.0f]];
    
    animation.timingFunctions = timingFunctions;
    animation.keyTimes = keyTimes;
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
    
    for (UIView *view in viewTransitionArray) {
        [view.layer addAnimation:animationTransform forKey:nil];
    }
   
    [CATransaction commit];
    [timingFunctions release];
    [keyTimes release];
    [values release];
    [valuesTransform release];
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
        _rightViewController = [rightController don_retain];
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
        _leftViewController = [leftController don_retain];
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
        _rootViewController = [rootController don_retain];
    }
    if (_rootViewController && _rootViewController.view.superview != self.view ) {
        UIView *view = _rootViewController.view;
        view.frame = self.view.bounds;
        self.view.backgroundColor = [UIColor clearColor];
//        NSLog(@" DDMenuController:%@",self.view);
        [self.view addSubview:view];
        
        [_pan release];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        pan.delegate = (id<UIGestureRecognizerDelegate>)self;
        [view addGestureRecognizer:pan];
        _pan = [pan don_retain];
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
        if ( ! SELF_VIEWCONTROLER_IS_IPAD_LANDSCAPE ) {
            frame.origin.x = rootRef.view.bounds.size.width;
        }
        
        [UIView animateWithDuration:.1 animations: ^ {
            rootRef.view.frame = frame;
         } completion: ^(BOOL finished) {
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
//        NSLog(@"root controller is not a navigation controller.");
        return;
    }
	
	if (_menuFlags.showingRightView) 
	{
        [navController pushViewController:viewController animated:NO];
        [self showRootController:animated];
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
