//
//  MKPartialViewRegion.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/20/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPartialViewRegion.h"
#import "MKDynamicCallbackHandler.h"
#import "MKContextual.h"
#import "MKContext+Subscribe.h"
#import "NSObject+NotHandled.h"
#import "NSObject+Context.h"
#import "EXTScope.h"

@implementation MKPartialViewRegion
{
    MKContext        *_context;
    __weak UIView    *_partialView;
    UIViewController *_particalViewController;
}

- (MKContext *)context
{
    if (_context == nil)
    {
        UIViewController<MKContextual> *owningController = [self owningViewController];
        _context                                         = [owningController.context newChildContext];
        
        @weakify(self);
        [_context subscribeDidEnd:^(id<MKContext> context) {
            @strongify(self);
            [self removePartialController];
        }];
        
        [_context addHandler:[MKDynamicCallbackHandler delegateTo:self]];
    }
    return _context;
}

- (id)partialViewController
{
    return _particalViewController;
}

#pragma mark - MKViewRegion

- (void)presentViewController:(UIViewController *)viewControllerToPresent
{
    if (self.composer == _context)
    {
        [self removePartialController];
        if (viewControllerToPresent)
            [self addPartialController:viewControllerToPresent];
    }
    else
        [self notHandled];
}

- (void)addPartialController:(UIViewController *)partialController
{
    UIViewController *owningController = [self owningViewController];
    _particalViewController            = partialController;
    [_particalViewController willMoveToParentViewController:owningController];
    [owningController        addChildViewController:partialController];
    [partialController       didMoveToParentViewController:owningController];
    [self addSubview:_partialView      = partialController.view];
}

- (void)removePartialController
{
    if (_particalViewController)
    {
        [_particalViewController willMoveToParentViewController:nil];
        [_particalViewController removeFromParentViewController];
        [_partialView            removeFromSuperview];
        [_particalViewController didMoveToParentViewController:nil];
        _particalViewController = nil;
        _partialView            = nil;
    }
}

- (UIViewController<MKContextual> *)owningViewController
{
    id nextResponder = self;
    while ((nextResponder = [nextResponder nextResponder]))
        if ([nextResponder isKindOfClass:UIViewController.class])
            return nextResponder;
    return nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_partialView)
        _partialView.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
}

- (void)dealloc
{
    [_context end];
    _context = nil;
}

@end
