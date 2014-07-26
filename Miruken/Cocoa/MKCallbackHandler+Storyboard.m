//
//  MKCallbackHandler+Storyboard.m
//  Miruken
//
//  Created by Craig Neuwirt on 7/26/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler+Storyboard.h"
#import "MKViewRegion.h"
#import "UIStoryboard+Naming.h"

@implementation MKCallbackHandler (Storyboard)

- (MKPromise)showStory:(NSString *)storyBaseName
{
    UIStoryboard *story = [UIStoryboard storyboardWithBaseName:storyBaseName bundle:nil];
    UIViewController*viewController = [story instantiateInitialViewController];
    return [MKViewRegion(self) presentViewController:viewController];
}

- (MKPromise)showStory:(NSString *)storyBaseName bundleForClass:(Class)class
{
    UIStoryboard *story = [UIStoryboard storyboardWithBaseName:storyBaseName bundleForClass:class];
    UIViewController*viewController = [story instantiateInitialViewController];
    return [MKViewRegion(self) presentViewController:viewController];
}

- (MKPromise)showStory:(NSString *)storyBaseName bundle:(NSBundle *)bundle
{
    UIStoryboard *story = [UIStoryboard storyboardWithBaseName:storyBaseName bundle:bundle];
    UIViewController*viewController = [story instantiateInitialViewController];
    return [MKViewRegion(self) presentViewController:viewController];
}

- (MKPromise)showStory:(NSString *)storyBaseName controllerIdentifier:(NSString *)identifier
{
    UIStoryboard *story = [UIStoryboard storyboardWithBaseName:storyBaseName bundle:nil];
    UIViewController*viewController = [story instantiateViewControllerWithIdentifier:identifier];
    return [MKViewRegion(self) presentViewController:viewController];
}

- (MKPromise)showStory:(NSString *)storyBaseName controllerIdentifier:(NSString *)identifier
        bundleForClass:(Class)class
{
    UIStoryboard *story = [UIStoryboard storyboardWithBaseName:storyBaseName bundleForClass:class];
    UIViewController*viewController = [story instantiateViewControllerWithIdentifier:identifier];
    return [MKViewRegion(self) presentViewController:viewController];
}

- (MKPromise)showStory:(NSString *)storyBaseName controllerIdentifier:(NSString *)identifier
                bundle:(NSBundle *)bundle
{
    UIStoryboard *story = [UIStoryboard storyboardWithBaseName:storyBaseName bundle:bundle];
    UIViewController*viewController = [story instantiateViewControllerWithIdentifier:identifier];
    return [MKViewRegion(self) presentViewController:viewController];
}

@end
