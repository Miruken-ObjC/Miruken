//
//  MKTransitionOptions.m
//  Miruken
//
//  Created by Craig Neuwirt on 5/25/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKTransitionOptions.h"
#import <objc/runtime.h>

@implementation MKTransitionOptions
{
    struct
    {
        unsigned int animationDuration:1;
        unsigned int fadeStyle:1;
        unsigned int perspective:1;
        unsigned int clipToBounds:1;
    } _specified;
}

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

- (void)setClipToBounds:(BOOL)clipToBounds
{
    _clipToBounds           = clipToBounds;
    _specified.clipToBounds = YES;
}

- (void)setTransitionDelegate:(id<UIViewControllerTransitioningDelegate>)transitionDelegate
{
    _transitionDelegate = transitionDelegate;
}

- (void)applyPolicyToViewController:(UIViewController *)viewController
{
    if (_transitionDelegate)
    {
        if (_specified.animationDuration &&
            [_transitionDelegate respondsToSelector:@selector(setAnimationDuration:)])
            [(id)_transitionDelegate setAnimationDuration:_animationDuration];

        if (_specified.fadeStyle &&
            [_transitionDelegate respondsToSelector:@selector(setFadeStyle:)])
            [(id)_transitionDelegate setFadeStyle:_fadeStyle];
        
        if (_specified.perspective &&
            [_transitionDelegate respondsToSelector:@selector(setPerspective:)])
            [(id)_transitionDelegate setPerspective:_perspective];

        if (_specified.clipToBounds &&
            [_transitionDelegate respondsToSelector:@selector(setClipToBounds:)])
            [(id)_transitionDelegate setClipToBounds:_clipToBounds];

        viewController.transitioningDelegate = _transitionDelegate;
        
        if (_transitionDelegate != (id)viewController)
        {
            // Keep transition delegate alive if not viewController
            objc_setAssociatedObject(viewController, _cmd, _transitionDelegate, OBJC_ASSOCIATION_RETAIN);
            
        }
    }
}

- (void)mergeIntoOptions:(id<MKPresentationOptions>)otherOptions
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

    if (_specified.clipToBounds && (transitionOptions->_specified.clipToBounds == NO))
        transitionOptions.clipToBounds = _clipToBounds;

    if (_transitionDelegate && (transitionOptions->_transitionDelegate == nil))
        transitionOptions.transitionDelegate = _transitionDelegate;
}

@end
