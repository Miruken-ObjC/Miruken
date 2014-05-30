//
//  MKNavigationTransitionWrapper.h
//  Miruken
//
//  Created by Craig Neuwirt on 5/30/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKNavigationTransitionWrapper : NSObject <UINavigationControllerDelegate>

+ (instancetype)wrapNavigation:(id<UINavigationControllerDelegate>)nav
                withTransition:(id<UIViewControllerTransitioningDelegate>)transition;

@end
