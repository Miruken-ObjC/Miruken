//
//  MKTransitionOptions.m
//  Miruken
//
//  Created by Craig Neuwirt on 5/25/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKTransitionOptions.h"

@implementation MKTransitionOptions
{
    id<UIViewControllerTransitioningDelegate> _transitionDelegate;

    struct
    {
        unsigned int animationDuration:1;
        unsigned int fadeStyle:1;
        unsigned int perspective:1;
        unsigned int transitionDelegate:1;
    } _specified;
}

#pragma mark - MKTransitionOptions

- (void)setAnimationDuration:(NSTimeInterval)animationDuration
{
    _animationDuration           = animationDuration;
    _specified.animationDuration = YES;
}

- (void)setFadeStyle:(MKTransitionFadeStyle)fadeStyle
{
    _fadeStyle           = fadeStyle;
    _specified.fadeStyle = YES;
}

- (void)setPerspective:(CGFloat)perspective
{
    _perspective           = perspective;
    _specified.perspective = YES;
}

- (void)setTransitionDelegate:(id<UIViewControllerTransitioningDelegate>)transitionDelegate
{
    _transitionDelegate           = transitionDelegate;
    _specified.transitionDelegate = YES;
}

- (void)applyPolicyToViewController:(UIViewController *)viewController
{
}

- (void)mergeIntoOptions:(MKTransitionOptions *)otherOptions
{
    if ([otherOptions isKindOfClass:self.class] == NO)
        return;
    
    MKTransitionOptions *transitionOptions = otherOptions;
    
    if (_specified.animationDuration && (transitionOptions->_specified.animationDuration == NO))
        transitionOptions.animationDuration = _animationDuration;

    if (_specified.fadeStyle && (transitionOptions->_specified.fadeStyle == NO))
        transitionOptions.fadeStyle = _fadeStyle;

    if (_specified.perspective && (transitionOptions->_specified.perspective == NO))
        transitionOptions.perspective = _perspective;

    if (_specified.transitionDelegate && (transitionOptions->_specified.transitionDelegate == NO))
        transitionOptions.transitionDelegate = _transitionDelegate;
}

@end
