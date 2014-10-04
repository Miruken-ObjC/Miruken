//
//  MKAlertViewMixin.m
//  Miruken
//
//  Created by Craig Neuwirt on 1/27/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAlertViewMixin.h"

@interface MKAlertViewMixin() <MKAlertViewDelegate, UIApplicationDelegate>
@end

@implementation MKAlertViewMixin

+ (void)verifyCanMixIntoClass:(Class)targetClass
{
    if ([targetClass conformsToProtocol:@protocol(UIAlertViewDelegate)] == NO)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"The MKAlertViewMixin requires the target class "
                                               "to conform to the UIAlertViewDelegate protocol."
                                     userInfo:nil];
}

#pragma mark - UIApplicationDelegate

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self MKAlertView_applicationDidEnterBackground:application];
}

- (void)swizzleAlertView_applicationDidEnterBackground:(UIApplication *)application
{
    [self MKAlertView_applicationDidEnterBackground:application];
    [self swizzleAlertView_applicationDidEnterBackground:application];
}

- (void)MKAlertView_applicationDidEnterBackground:(UIApplication *)application
{
    if ([self respondsToSelector:@selector(alertView)])
    {
        UIAlertView *alertView = self.alertView;
        if (alertView.visible)
            [alertView dismissWithClickedButtonIndex:alertView.cancelButtonIndex animated:NO];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self MKAlertView_alertView:alertView didDismissWithButtonIndex:buttonIndex];
}

- (void)swizzleAlertView_alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self MKAlertView_alertView:alertView didDismissWithButtonIndex:buttonIndex];
    [self swizzleAlertView_alertView:alertView didDismissWithButtonIndex:buttonIndex];
}

- (void)MKAlertView_alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([self respondsToSelector:@selector(setAlertView:)])
        self.alertView = nil;
}

@end

