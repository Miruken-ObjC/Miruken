//
//  MKCallbackHandler+Storyboard.h
//  Miruken
//
//  Created by Craig Neuwirt on 7/26/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"
#import "MKPromise.h"
#import <UIKit/UIKit.h>

@interface MKCallbackHandler (Storyboard)

- (MKPromise)showStory:(NSString *)storyBaseName;

- (MKPromise)showStory:(NSString *)storyBaseName bundleForClass:(Class)class;

- (MKPromise)showStory:(NSString *)storyBaseName bundle:(NSBundle *)bundle;

- (MKPromise)showStory:(NSString *)storyBaseName controllerIdentifier:(NSString *)identifier;

- (MKPromise)showStory:(NSString *)storyBaseName controllerIdentifier:(NSString *)identifier
        bundleForClass:(Class)class;

- (MKPromise)showStory:(NSString *)storyBaseName controllerIdentifier:(NSString *)identifier
                bundle:(NSBundle *)bundle;

@end
