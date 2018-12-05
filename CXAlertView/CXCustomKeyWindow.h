//
//  CXCustomKeyWindow.h
//  CXAlertViewDemo
//
//  Created by Wangjianlong on 2018/12/5.
//  Copyright © 2018 ChrisXu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CXCustomKeyWindow;
typedef void(^CXAlertViewHandler)(CXCustomKeyWindow *alertView);

@interface CXCustomKeyWindow : UIView

@property (nonatomic, copy) CXAlertViewHandler willShowHandler;
@property (nonatomic, copy) CXAlertViewHandler didShowHandler;
@property (nonatomic, copy) CXAlertViewHandler willDismissHandler;
@property (nonatomic, copy) CXAlertViewHandler didDismissHandler;

@property (nonatomic, readonly, getter = isVisible) BOOL visible;

// AlertView action
- (void)show;
- (void)dismiss;
- (void)shake;
// Operation
- (void)cleanAllPenddingAlert;
- (void)tearDown;
- (void)setup;
- (void)transitionInCompletion:(void(^)(void))completion;
- (void)transitionOutCompletion:(void(^)(void))completion;
- (void)validateLayout;
@end

NS_ASSUME_NONNULL_END
