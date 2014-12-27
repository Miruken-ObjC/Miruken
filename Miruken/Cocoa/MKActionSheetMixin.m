//
//  MKActionSheetMixin.m
//  Miruken
//
//  Created by Craig Neuwirt on 9/10/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import "MKActionSheetMixin.h"

static UIActionSheet *activeActionSheet;

@interface MKActionSheetMixin() <MKActionSheetDelegate, UIApplicationDelegate>
@end

@implementation MKActionSheetMixin

+ (void)verifyCanMixIntoClass:(Class)targetClass
{
    if ([targetClass conformsToProtocol:@protocol(UIActionSheetDelegate)] == NO)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"The MKActionSheetMixin requires the target class "
                                                "to conform to the UIActionSheetDelegate protocol."
                                     userInfo:nil];
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
    [self MKActionSheet_dismissActionSheet];
}

#pragma mark - UIActionSheetDelegate

- (UIActionSheet *)actionSheet
{
    return activeActionSheet;
}

- (UIActionSheet *)swizzleActionSheet_actionSheet
{
    return activeActionSheet ? activeActionSheet : [self swizzleActionSheet_actionSheet];
}

- (void)setActionSheet:(UIActionSheet *)actionSheet
{
    activeActionSheet = actionSheet;
}

- (void)swizzleActionSheet_setActionSheet:(UIActionSheet *)actionSheet
{
    activeActionSheet = actionSheet;
    [self swizzleActionSheet_setActionSheet:actionSheet];
}

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
    self.actionSheet = nil;
}

- (void)MKActionSheet_dismissActionSheet
{
    UIActionSheet *actionSheet = self.actionSheet;
    if (actionSheet.visible)
        [actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated:NO];
}

@end
