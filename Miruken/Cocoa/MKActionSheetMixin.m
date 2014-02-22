//
//  MKActionSheetMixin.m
//  Miruken
//
//  Created by Craig Neuwirt on 9/10/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import "MKActionSheetMixin.h"
#import "MKMixin.h"

@interface MKActionSheetMixin() <MKActionSheetDelegate, UIApplicationDelegate>
@end

@implementation MKActionSheetMixin

+ (void)mixInto:(Class)class
{
    if ([class conformsToProtocol:@protocol(UIActionSheetDelegate)] == NO)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"The MKActionSheetMixin requires the target class "
                                                "to conform to the UIActionSheetDelegate protocol."
                                     userInfo:nil];
    
    [class mixinFrom:self];
}

#pragma mark - UIApplicationDelegate

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self MKActionSheet_applicationWillResignActive:application];
}

- (void)swizzleActionSheet_applicationWillResignActive:(UIApplication *)application
{
    [self MKActionSheet_applicationWillResignActive:application];
    [self swizzleActionSheet_applicationWillResignActive:application];
}

- (void)MKActionSheet_applicationWillResignActive:(UIApplication *)application
{
    if ([self respondsToSelector:@selector(actionSheet)])
    {
        UIActionSheet *actionSheet = self.actionSheet;
        if (actionSheet.visible)
            [actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated:NO];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self MKActionSheet_actionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];
}

- (void)swizzleActionSheet_actionSheet:(UIActionSheet *)actionSheet
             didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self MKActionSheet_actionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];
    [self swizzleActionSheet_actionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];
}

- (void)MKActionSheet_actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([self respondsToSelector:@selector(setActionSheet:)])
        self.actionSheet = nil;
}

@end
