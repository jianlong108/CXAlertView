//
//  CXCustomKeyWindow.m
//  CXAlertViewDemo
//
//  Created by Wangjianlong on 2018/12/5.
//  Copyright © 2018 ChrisXu. All rights reserved.
//

#import "CXCustomKeyWindow.h"
#import "CusKeyWindowRootViewController.h"

@class CXAlertBackgroundWindow;

static NSMutableArray *__cx_pending_alert_queue;
static BOOL __cx_alert_animating;
static CXAlertBackgroundWindow *__cx_alert_background_window;
static CXCustomKeyWindow *__cx_alert_current_view;
static BOOL __cx_statsu_prefersStatusBarHidden;

@interface CXTempViewController : UIViewController

@end

@implementation CXTempViewController

- (BOOL)prefersStatusBarHidden
{
    return __cx_statsu_prefersStatusBarHidden;
}

@end

@interface CXAlertBackgroundWindow : UIWindow

@end

@implementation CXAlertBackgroundWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = NO;
        self.windowLevel = UIWindowLevelAlert - 1;
        self.rootViewController = [[CXTempViewController alloc] init];
        self.rootViewController.view.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor colorWithWhite:0 alpha:0.5] set];
    CGContextFillRect(context, self.bounds);
}

@end

@interface CXCustomKeyWindow()

@property (nonatomic, strong) UIWindow *oldKeyWindow;
@property (nonatomic, strong) UIWindow *alertWindow;
@property (nonatomic, assign, getter = isVisible) BOOL visible;

+ (NSMutableArray *)sharedQueue;
+ (CXCustomKeyWindow *)currentAlertView;

+ (BOOL)isAnimating;
+ (void)setAnimating:(BOOL)animating;

+ (void)showBackground;
+ (void)hideBackgroundAnimated:(BOOL)animated;

@end

@implementation CXCustomKeyWindow
- (void)setup
{
    
}
// AlertView action
- (void)show
{
    self.oldKeyWindow = [[UIApplication sharedApplication] keyWindow];
    
    if (![[CXCustomKeyWindow sharedQueue] containsObject:self]) {
        [[CXCustomKeyWindow sharedQueue] addObject:self];
    }
    
    if ([CXCustomKeyWindow isAnimating]) {
        return; // wait for next turn
    }
    
    if (self.isVisible) {
        return;
    }
    
    if ([CXCustomKeyWindow currentAlertView].isVisible) {
        CXCustomKeyWindow *alert = [CXCustomKeyWindow currentAlertView];
        [alert dismissWithCleanup:NO];
        return;
    }
    
    if (self.willShowHandler) {
        self.willShowHandler(self);
    }
    
    self.visible = YES;
    
    [CXCustomKeyWindow setAnimating:YES];
    [CXCustomKeyWindow setCurrentAlertView:self];
    
    // transition background
    [CXCustomKeyWindow showBackground];
    
    CusKeyWindowRootViewController *viewController = [[CusKeyWindowRootViewController alloc]initWithCustomKeyWindow:self];
    
//    CXAlertViewController *viewController = [[CXAlertViewController alloc] initWithNibName:nil bundle:nil];
//    viewController.alertView = self;
//
//    if ([self.oldKeyWindow.rootViewController respondsToSelector:@selector(prefersStatusBarHidden)]) {
//        viewController.rootViewControllerPrefersStatusBarHidden = self.oldKeyWindow.rootViewController.prefersStatusBarHidden;
//        __cx_statsu_prefersStatusBarHidden = self.oldKeyWindow.rootViewController.prefersStatusBarHidden;
//    }
    
    if (!self.alertWindow) {
        UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        window.opaque = NO;
        window.windowLevel = UIWindowLevelAlert;
        window.rootViewController = viewController;
        self.alertWindow = window;
    }
    [self.alertWindow makeKeyAndVisible];
    [self validateLayout];
    
    [self transitionInCompletion:^{
        if (self.didShowHandler) {
            self.didShowHandler(self);
        }
        
        [CXCustomKeyWindow setAnimating:NO];
        
        NSInteger index = [[CXCustomKeyWindow sharedQueue] indexOfObject:self];
        if (index < [CXCustomKeyWindow sharedQueue].count - 1) {
            [self dismissWithCleanup:NO]; // dismiss to show next alert view
        }
    }];
}

- (void)validateLayout
{
    
}

- (void)dismiss
{
    [self dismissWithCleanup:YES];
}

- (void)tearDown
{
//    [self.containerView removeFromSuperview];
//    [self.blurView removeFromSuperview];
//
//    [self.titleLabel removeFromSuperview];
//    self.titleLabel = nil;
    
    [self.alertWindow removeFromSuperview];
    self.alertWindow = nil;
//    self.layoutDirty = NO;
}
- (void)shake
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.duration = 0.1;
    animation.repeatCount = 3;
    animation.autoreverses = YES;
    //    animation.fromValue = [NSNumber numberWithFloat:0.0];
    animation.toValue = [NSNumber numberWithFloat:10.0];
    [self.layer removeAllAnimations];
    [self.layer addAnimation:animation forKey:@"transform.translation.x"];
    
}
// Operation
- (void)cleanAllPenddingAlert
{
    [[CXCustomKeyWindow sharedQueue] removeAllObjects];
}

#pragma mark - CXAlertView PV
+ (NSMutableArray *)sharedQueue
{
    if (!__cx_pending_alert_queue) {
        __cx_pending_alert_queue = [NSMutableArray array];
    }
    return __cx_pending_alert_queue;
}

+ (CXCustomKeyWindow *)currentAlertView
{
    return __cx_alert_current_view;
}

+ (void)setCurrentAlertView:(CXCustomKeyWindow *)alertView
{
    __cx_alert_current_view = alertView;
}

+ (BOOL)isAnimating
{
    return __cx_alert_animating;
}

+ (void)setAnimating:(BOOL)animating
{
    __cx_alert_animating = animating;
}

+ (void)showBackground
{
    if (!__cx_alert_background_window) {
        
        CGSize screenSize = [self currentScreenSize];
        
        __cx_alert_background_window = [[CXAlertBackgroundWindow alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    }
    
    [__cx_alert_background_window makeKeyAndVisible];
    __cx_alert_background_window.alpha = 0;
    [UIView animateWithDuration:0.3
                     animations:^{
                         __cx_alert_background_window.alpha = 1;
                     }];
}

+ (CGSize)currentScreenSize
{
    CGRect frame;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]) {
        frame = [UIScreen mainScreen].nativeBounds;
    }
    else {
        frame = [UIScreen mainScreen].bounds;
    }
#else
    frame = [UIScreen mainScreen].bounds;
#endif
    
    CGFloat screenWidth = frame.size.width;
    CGFloat screenHeight = frame.size.height;
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation) && ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)) {
        CGFloat tmp = screenWidth;
        screenWidth = screenHeight;
        screenHeight = tmp;
    }
    
    return CGSizeMake(screenWidth, screenHeight);
}


+ (void)hideBackgroundAnimated:(BOOL)animated
{
    if (!animated) {
        [__cx_alert_background_window removeFromSuperview];
        __cx_alert_background_window = nil;
        return;
    }
    [UIView animateWithDuration:0.3
                     animations:^{
                         __cx_alert_background_window.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [__cx_alert_background_window removeFromSuperview];
                         __cx_alert_background_window = nil;
                     }];
}

- (void)dismissWithCleanup:(BOOL)cleanup
{
    BOOL isVisible = self.isVisible;
    
    if (isVisible) {
        if (self.willDismissHandler) {
            self.willDismissHandler(self);
        }
    }
    
    void (^dismissComplete)(void) = ^{
        self.visible = NO;
        [self tearDown];
        
        [CXCustomKeyWindow setCurrentAlertView:nil];
        
        // show next alertView
        CXCustomKeyWindow *nextAlertView;
        NSInteger index = [[CXCustomKeyWindow sharedQueue] indexOfObject:self];
        if (index != NSNotFound && index < [CXCustomKeyWindow sharedQueue].count - 1) {
            nextAlertView = [CXCustomKeyWindow sharedQueue][index + 1];
        }
        
        if (cleanup) {
            [[CXCustomKeyWindow sharedQueue] removeObject:self];
        }
        
        [CXCustomKeyWindow setAnimating:NO];
        
        if (isVisible) {
            if (self.didDismissHandler) {
                self.didDismissHandler(self);
            }
        }
        
        // check if we should show next alert
        if (!isVisible) {
            return;
        }
        
        if (nextAlertView) {
            [nextAlertView show];
        } else {
            // show last alert view
            if ([CXCustomKeyWindow sharedQueue].count > 0) {
                CXCustomKeyWindow *alert = [[CXCustomKeyWindow sharedQueue] lastObject];
                [alert show];
            }
        }
    };
    
    if (isVisible) {
        [CXCustomKeyWindow setAnimating:YES];
        [self transitionOutCompletion:dismissComplete];
        
        if ([CXCustomKeyWindow sharedQueue].count == 1) {
            [CXCustomKeyWindow hideBackgroundAnimated:YES];
        }
        
    } else {
        dismissComplete();
        
        if ([CXCustomKeyWindow sharedQueue].count == 0) {
            [CXCustomKeyWindow hideBackgroundAnimated:YES];
        }
    }
    
    [_oldKeyWindow makeKeyWindow];
    _oldKeyWindow.hidden = NO;
}
// Transition
- (void)transitionInCompletion:(void(^)(void))completion
{
//    _containerView.alpha = 0;
//    _containerView.transform = CGAffineTransformMakeScale(1.2, 1.2);
//
//    _blurView.alpha = 0.9;
//    _blurView.transform = CGAffineTransformMakeScale(1.2, 1.2);
//
//    [UIView animateWithDuration:0.3
//                     animations:^{
//                         _containerView.alpha = 1.;
//                         _containerView.transform = CGAffineTransformMakeScale(1.0,1.0);
//
//                         _blurView.alpha = 1.;
//                         _blurView.transform = CGAffineTransformMakeScale(1.0,1.0);
//                     }
//                     completion:^(BOOL finished) {
//                         [_blurView blur];
//                         if (completion) {
//                             completion();
//                         }
//                     }];
}

- (void)transitionOutCompletion:(void(^)(void))completion
{
//    [UIView animateWithDuration:0.25
//                     animations:^{
//                         _containerView.alpha = 0;
//                         _containerView.transform = CGAffineTransformMakeScale(0.9,0.9);
//
//                         _blurView.alpha = 0.9;
//                         _blurView.transform = CGAffineTransformMakeScale(0.9,0.9);
//                     }
//                     completion:^(BOOL finished) {
//                         if (completion) {
//                             completion();
//                         }
//                     }];
}
@end
