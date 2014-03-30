//
//  UIViewController_ContextualMixin.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/16/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "UIViewController_ContextualMixin.h"
#import "MKContextualHelper.h"
#import "MKContextObserver.h"
#import "EXTScope.h"

@implementation UIViewController_ContextualMixin

#pragma mark - Modal methods

- (void)swizzleContextual_presentViewController:(UIViewController *)viewControllerToPresent
                                       animated:(BOOL)flag completion:(void (^)(void))completion
{
    MKContext *childContext =
        [MKContextualHelper bindChildContextFrom:self toChild:viewControllerToPresent];
    
    if (childContext)
    {
        @weakify(self, viewControllerToPresent);
        [childContext subscribe:[MKContextObserver contextDidEnd:^(id<MKContext> ctx) {
            @strongify(self, viewControllerToPresent);
            if (self.presentedViewController == viewControllerToPresent
            && [self.presentedViewController isBeingDismissed] == NO)
                [self dismissViewControllerAnimated:YES completion:nil];
        }] retain:YES];
    }
    
    [self swizzleContextual_presentViewController:viewControllerToPresent
                                         animated:flag completion:completion];
}

- (void)swizzleContextual_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    UIViewController *presentedViewController = self.presentedViewController;
    if ([presentedViewController isBeingDismissed] == NO)
        [self swizzleContextual_dismissViewControllerAnimated:flag completion:completion];
    if (presentedViewController != nil)
        [MKContextualHelper endContextBoundTo:presentedViewController];
}

#pragma mark - Container methods

- (void)swizzleContextual_addChildViewController:(UIViewController *)childController
{
    [MKContextualHelper bindChildContextFrom:self toChild:childController];
    [self swizzleContextual_addChildViewController:childController];
}

- (void)swizzleContextual_removeFromParentViewController
{
    [MKContextualHelper endContextBoundTo:self];
    [self swizzleContextual_removeFromParentViewController];
}

- (void)swizzleContextual_prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    // Container Views are realized by emebedded segues that ultimately get added
    // as child controllers.  Unfortunately, this lifecycle results in the contained
    // view controller's viewDidLoad method being called before addChildViewController.
    // This prevents access to the child context.  To overcome this, we bind the
    // context in the prepareForSegue method which occurs before viewDidLoad.
    
    if ([NSStringFromClass(segue.class) isEqualToString:@"UIStoryboardEmbedSegue"])
        [MKContextualHelper bindChildContextFrom:self toChild:segue.destinationViewController];
    
    [self swizzleContextual_prepareForSegue:segue sender:sender];
}

- (void)swizzleContextual_dealloc
{
    // This delegate often involves circularities so we clear it to be safe.
    
    self.transitioningDelegate = nil;
    
    [self swizzleContextual_dealloc];
}

@end

#pragma mark - UIViewController_Contextual methods

@implementation UIViewController (UIViewController_Contextual)

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)animated
                   completion:(void (^)(void))completion presentedContext:(MKContextAction)presentedContext
{
    if (presentedContext)
    {
        MKContext *childContext =
            [MKContextualHelper bindChildContextFrom:self toChild:viewControllerToPresent];
        
        if (childContext)
            presentedContext(childContext);
    }
    [self presentViewController:viewControllerToPresent animated:animated completion:completion];
}

- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion
                     dismissedContext:(MKContextAction)dismissedContext
{
    if (dismissedContext)
    {
        UIViewController *presentedViewController = self.presentedViewController;
        if (presentedViewController)
        {
            MKContext *childContext = [MKContextualHelper contextBoundTo:presentedViewController];
            if (childContext)
                dismissedContext(childContext);
        }
    }
    [self dismissViewControllerAnimated:animated completion:completion];
}

@end
