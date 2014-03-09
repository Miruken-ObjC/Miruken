//
//  UINavigationController_ContextualMixin.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/12/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "UINavigationController_ContextualMixin.h"
#import "UIViewController_ContextualMixin.h"
#import "MKContextualHelper.h"
#import "MKContextObserver.h"
#import "EXTScope.h"

@implementation UINavigationController_ContextualMixin

- (void)contextChanged:(MKContext *)context
{
    if (context == nil)
        return;
    
    id owner = self;
    for (UIViewController *viewController in self.viewControllers)
    {
        [self bindChildContextAndPopOnEnd:viewController owner:owner];
        owner = viewController;
    }
}

#pragma mark - Swizzled methods

- (id)swizzleContextual_initWithRootViewController:(UIViewController *)rootViewController
{
    [self bindChildContextAndPopOnEnd:rootViewController owner:self];
    return [self swizzleContextual_initWithRootViewController:rootViewController];
}

- (void)swizzleContextual_setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    id owner = self;
    for (UIViewController *viewController in viewControllers)
    {
        [self bindChildContextAndPopOnEnd:viewController owner:owner];
        owner = viewController;
    }
    [self swizzleContextual_setViewControllers:viewControllers animated:animated];
}

- (void)swizzleContextual_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    id owner = self.topViewController ? self.topViewController : self;
    
    [self bindChildContextAndPopOnEnd:viewController owner:owner];
    [self swizzleContextual_pushViewController:viewController animated:animated];
}

- (UIViewController *)swizzleContextual_popViewControllerAnimated:(BOOL)animated
{
    // The following check for the popped controller against self is ONLY
    // needed to accomodate a bug in MonkeyTalk in which calling
    // popViewController on a UINavigationController that has a single child
    // returns the owning navigatorinstead of nil.
    
    NSUInteger count = [[self viewControllers] count];
    UIViewController *topController = [self topViewController];
    id viewController = [self swizzleContextual_popViewControllerAnimated:animated];
    
    if (count > 1 && viewController == self)
        viewController = topController;
    
    if (viewController)
        [MKContextualHelper endContextBoundTo:viewController];
    return viewController;
}

- (NSArray *)swizzleContextual_popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSArray *popped = [self swizzleContextual_popToViewController:viewController animated:animated];
    for (id poppedViewController in popped)
        [MKContextualHelper endContextBoundTo:poppedViewController];
    return popped;
}

- (NSArray *)swizzleContextual_popToRootViewControllerAnimated:(BOOL)animated
{
    NSArray *popped = [self swizzleContextual_popToRootViewControllerAnimated:animated];
    for (id poppedViewController in popped)
        [MKContextualHelper endContextBoundTo:poppedViewController];
    return popped;    
}

- (MKContext *)bindChildContextAndPopOnEnd:(UIViewController *)viewController owner:(id)owner
{
    // This gesture recognizer performs a pop without a push back
    
    self.interactivePopGestureRecognizer.enabled = NO;
    
    MKContext *childContext = [MKContextualHelper bindChildContextFrom:owner toChild:viewController];
    
    if (childContext)
    {
        BOOL toolbarHidden = self.toolbarHidden;
        BOOL navBarHidden  = self.navigationBarHidden;

        @weakify(self, viewController);
        [childContext subscribe:[MKContextObserver contextDidEnd:^(MKContext *context)
        {
            @strongify(self, viewController);
            
            // Ensure the parent is active to prevent nested UINavigationController
            // pops which is not supported.
            
            if (context.parent && context.parent.state != MKContextStateActive)
                return;
            
            [self setNavigationBarHidden:navBarHidden animated:YES];
            [self setToolbarHidden:toolbarHidden animated:YES];
            
            if ([self.viewControllers containsObject:viewController])
            {
                [self popToViewController:viewController animated:NO];
            
                // The following check for the popped controller against self is ONLY
                // needed to accomodate a bug in MonkeyTalk in which calling
                // popViewController on a UINavigationController that has a single child
                // returns the owning navigator instead of nil.
                
                NSUInteger count = [self.viewControllers count];
                UIViewController *poppedController = [self popViewControllerAnimated:YES];
                if (count == 1 && (poppedController == nil || poppedController == self))
                    [self.context end];
            }
        }] retain:YES];
    }

    return childContext;
}

@end

#pragma mark - UINavigationController_Contextual methods

@implementation UINavigationController (UINavigationController_Contextual)

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
             pushedContext:(MKContextAction)pushedContext
{
    if (pushedContext)
    {
        id owner = self.topViewController ? self.topViewController : self;
        
        MKContext *childContext =
            [MKContextualHelper bindChildContextFrom:owner toChild:viewController];

        if (childContext)
            pushedContext(childContext);
    }
    [self pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated poppedContext:(MKContextAction)poppedContext
{
    if (poppedContext && self.viewControllers.count > 1)
    {
        MKContext *childContext = [MKContextualHelper contextBoundTo:self.topViewController];
        if (childContext)
            poppedContext(childContext);
    }
    return [self popViewControllerAnimated:animated];
}

@end
