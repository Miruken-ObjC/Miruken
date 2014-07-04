//
//  CallbackHandler+SideEffects.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/1/12.
//  Copyright (c) 2012 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler+SideEffects.h"
#import "MKCallbackHandlerFilter.h"
#import "MKSideEffects.h"
#import "NSObject+Concurrency.h"
#import "NSObject+ResolvePromise.h"
#import "MKContext+Subscribe.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

@implementation MKCallbackHandler (SideEffects)

- (instancetype)timer:(void(^)(double duration))done
{
    if (done == nil)
        return self;
 
    __block CFTimeInterval startTime;
    
    return [self sideEffect:^(id callback, MKCallbackHandler *composer) {
                startTime = CACurrentMediaTime();
                return YES;
            }
            after:^(id callback, MKCallbackHandler *composer) {
                CFTimeInterval duration = CACurrentMediaTime() - startTime;
                done(duration);
            }];
}

#pragma mark - loading

- (instancetype)network
{
    return [self sideEffect:^(id callback, MKCallbackHandler *composer) {
                [MKSideEffects(composer) beginNetworkActivity];
                return YES;
            }
            after:^(id callback, MKCallbackHandler *composer) {
                [MKSideEffects(composer) endNetworkActivity];
            }];
}

- (instancetype)loading:(id<MKLoading>)Loading
{
    __block void(^restore)();
    
    return [self sideEffect:^(id callback, MKCallbackHandler *composer) {
                restore = [Loading loading];
                return YES;
            }
            after:^(id callback, MKCallbackHandler *composer) {
                if (restore)
                    restore();
            }];
}

- (instancetype)spinToolbarItem:(UIViewController<MKContextual> *)viewController atIndex:(NSUInteger)index
{
    __block BOOL    restored      = NO;
    NSArray        *toolbarItems  = viewController.toolbarItems;
    NSMutableArray *spinItems     = [NSMutableArray arrayWithArray:toolbarItems];
    UIActivityIndicatorView *activityIndiciator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    spinItems[index] = [[UIBarButtonItem alloc] initWithCustomView:activityIndiciator];
    [activityIndiciator startAnimating];
    
    MKContextUnsubscribe unsubscribe = [viewController.context subscribeDidEnd:^(id<MKContext> context) {
        if (restored == NO)
        {
            [activityIndiciator stopAnimating];
            [[viewController onMainQueue] setToolbarItems:toolbarItems];
            restored = YES;
        }
    }];
    
    return [self sideEffect:^(id callback, MKCallbackHandler *composer) {
                [[viewController onMainQueue] setToolbarItems:spinItems];
                return YES;
            }
            after:^(id callback, MKCallbackHandler *composer) {
                if (restored == NO)
                {
                    [activityIndiciator stopAnimating];
                    [[viewController onMainQueue] setToolbarItems:toolbarItems];
                    restored = YES;
                }
                
                if (unsubscribe)
                    unsubscribe();
            }];
}

- (instancetype)oneClick:(UIControl *)control
{
    __block BOOL guarded = NO;
    __block BOOL enabled = control.enabled;
    return [self sideEffect:^(id callback, MKCallbackHandler *composer) {
                if ((guarded = [self isGuarded:control]))
                    return NO;
                [self setGuarded:control guarded:YES];
                [[control onMainQueue] setEnabled:NO];
                return YES;
            }
            after:^(id callback, MKCallbackHandler *composer) {
                if (guarded == NO)
                {
                    [self setGuarded:control guarded:NO];
                    [[control onMainQueue] setEnabled:enabled];
                }
            }];
}

- (instancetype)oneClickBarButton:(UIBarButtonItem *)barItem
{
    __block BOOL guarded = NO;
    __block BOOL enabled = barItem.enabled;
    return [self sideEffect:^(id callback, MKCallbackHandler *composer) {
                if ((guarded = [self isGuarded:barItem]))
                    return NO;
                [self setGuarded:barItem guarded:YES];
                [[barItem onMainQueue] setEnabled:NO];
                return YES;
            }
            after:^(id callback, MKCallbackHandler *composer) {
                if (guarded == NO)
                {
                    [self setGuarded:barItem guarded:NO];
                    [[barItem onMainQueue] setEnabled:enabled];
                }
            }];
}

#pragma mark - guard

- (instancetype)guard:(id)guard
{
    __block BOOL guarded = NO;
    return [self sideEffect:^(id callback, MKCallbackHandler *composer) {
                if ((guarded = [self isGuarded:guard]))
                    return NO;
                [self setGuarded:guard guarded:YES];
                return YES;
            }
            after:^(id callback, MKCallbackHandler *composer) {
                if (guarded == NO)
                    [self setGuarded:guard guarded:NO];
            }];
}

- (instancetype)suspendUserInteraction:(UIView *)view
{
    BOOL userInterfaceEnabled = view.userInteractionEnabled;
    return [self sideEffect:^(id callback, MKCallbackHandler *composer) {
                view.userInteractionEnabled = NO;
                return YES;
            }
            after:^(id callback, MKCallbackHandler *composer) {
                view.userInteractionEnabled = userInterfaceEnabled;
            }];
}

- (instancetype)suppressScrolling:(UIScrollView *)scrollView
{
    BOOL scrollEnabled = scrollView.scrollEnabled;
    return [self sideEffect:^(id callback, MKCallbackHandler *composer) {
                scrollView.scrollEnabled = NO;
                return YES;
            }
            after:^(id callback, MKCallbackHandler *composer) {
                scrollView.scrollEnabled = scrollEnabled;
            }];
}

- (BOOL)isGuarded:(id)guard
{
    NSNumber *guarded = objc_getAssociatedObject(guard, @selector(isGuarded:));
    return [guarded boolValue];
}

- (void)setGuarded:(id)guard guarded:(BOOL)guarded
{
    NSNumber *guardedBool = guarded ? @YES : nil;
    objc_setAssociatedObject(guard, @selector(isGuarded:), guardedBool, OBJC_ASSOCIATION_RETAIN);
}

#pragma mark - side effect

- (instancetype)sideEffect:(MKSideEffectBeforeAction)before after:(MKSideEffectAfterAction)after
{
    if (before == nil && after == nil)
        return self;
    
    return [MKCallbackHandlerFilter for:self
            filter:^(id callback, id<MKCallbackHandler> composer, BOOL(^proceed)()) {
                MKPromise promise = nil;
                
                if (before && before(callback, composer) == NO)
                    return YES;
                
                @try {
                    BOOL handled = proceed();
                    if (handled && (promise = [callback effectivePromise]))
                    {
                        // Use 'done', 'fail' & cancel instead of 'always' to ensure filter
                        // boundary is consistent with synchronous invocations and avoid issues
                        // with reentrancy.
                        
                        if (after)
                            [[[promise done:^(id result) {
                                after(callback, composer);
                            }]
                            fail:^(id reason, BOOL *handled) {
                                after(callback, composer);
                            }]
                          cancel:^{
                                after(callback, composer);
                            }];
                    }
                    return handled;
                }
                @finally {
                    if (promise == nil && after)
                        after(callback, composer);
                }
            }];
}

@end
