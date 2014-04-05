//
//  MKPresentationPolicy.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/22/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPresentationPolicy.h"
#import "MKModalFlipHorizontalTransition.h"
#import "MKViewAnimationOptionsTransition.h"

@implementation MKPresentationPolicy
{
    struct
    {
        unsigned int modal:1;
        unsigned int modalTransitionStyle:1;
        unsigned int modalPresentationStyle:1;
        unsigned int definesPresentationContext:1;
        unsigned int providesPresentationContextTransitionStyle:1;
        unsigned int animationDuration:1;
        unsigned int transitionDelegate:1;
    } _specified;
}

- (id)copyWithZone:(NSZone *)zone
{
    MKPresentationPolicy *copy                        = [[self.class allocWithZone:zone] init];
    copy->_modal                                      = _modal;
    copy->_modalTransitionStyle                       = _modalTransitionStyle;
    copy->_modalPresentationStyle                     = _modalPresentationStyle;
    copy->_definesPresentationContext                 = _definesPresentationContext;
    copy->_providesPresentationContextTransitionStyle = _providesPresentationContextTransitionStyle;
    copy->_animationDuration                          = _animationDuration;
    copy->_transitionDelegate                         = _transitionDelegate;
    copy->_specified                                  = _specified;
    return copy;
}

- (void)setModal:(BOOL)modal
{
    _modal           = modal;
    _specified.modal = YES;
}

- (void)setModalTransitionStyle:(UIModalTransitionStyle)modalTransitionStyle
{
    self.modal                      = YES;
    _modalTransitionStyle           = modalTransitionStyle;
    _specified.modalTransitionStyle = YES;
}

- (void)setModalPresentationStyle:(UIModalPresentationStyle)modalPresentationStyle
{
    self.modal                        = YES;
    _modalPresentationStyle           = modalPresentationStyle;
    _specified.modalPresentationStyle = YES;
}

- (void)setDefinesPresentationContext:(BOOL)definesPresentationContext
{
    _definesPresentationContext           = definesPresentationContext;
    _specified.definesPresentationContext = YES;
}

- (void)setProvidesPresentationContextTransitionStyle:(BOOL)providesPresentationContextTransitionStyle
{
    _providesPresentationContextTransitionStyle           = providesPresentationContextTransitionStyle;
    _specified.providesPresentationContextTransitionStyle = YES;
}

- (void)setAnimationDuration:(NSTimeInterval)animationDuration
{
    _animationDuration           = animationDuration;
    _specified.animationDuration = YES;
}

- (void)setTransitionDelegate:(id<UIViewControllerTransitioningDelegate>)transitionDelegate
{
    _transitionDelegate           = transitionDelegate;
    _specified.transitionDelegate = YES;
}

- (void)applyPolicyToViewController:(UIViewController *)viewController
{
    if (_specified.modalPresentationStyle)
        viewController.modalPresentationStyle = _modalPresentationStyle;
    
    if (_specified.definesPresentationContext)
        viewController.definesPresentationContext = _definesPresentationContext;
    
    if (_specified.providesPresentationContextTransitionStyle)
        viewController.providesPresentationContextTransitionStyle =
        _providesPresentationContextTransitionStyle;
    
    if (_specified.transitionDelegate)
    {
        if (_specified.animationDuration &&
            [_transitionDelegate respondsToSelector:@selector(setAnimationDuration:)])
            [(id)_transitionDelegate setAnimationDuration:_animationDuration];
        viewController.transitioningDelegate = _transitionDelegate;
    }
    else if (_specified.modalTransitionStyle)
    {
        if (_modalTransitionStyle == UIModalTransitionStyleFlipHorizontal &&
            _specified.transitionDelegate == NO)
        {
            _transitionDelegate = [MKModalFlipHorizontalTransition new];
            viewController.transitioningDelegate = _transitionDelegate;
        }
        else
        {
            viewController.modalTransitionStyle = _modalTransitionStyle;
        }
    }
    
    if (_specified.modal && _specified.modalPresentationStyle == NO &&
        _specified.modalTransitionStyle == NO && viewController.transitioningDelegate)
        viewController.modalPresentationStyle = UIModalPresentationCustom;
}

- (void)mergeIntoPolicy:(MKPresentationPolicy *)otherPolicy
{
    if (_specified.modal && (otherPolicy->_specified.modal == NO))
        otherPolicy.modal = _modal;
    
    if (_specified.modalTransitionStyle && (otherPolicy->_specified.modalTransitionStyle == NO))
        otherPolicy.modalTransitionStyle = _modalTransitionStyle;
    
    if (_specified.modalPresentationStyle && (otherPolicy->_specified.modalPresentationStyle == NO))
        otherPolicy.modalPresentationStyle = _modalPresentationStyle;
    
    if (_specified.definesPresentationContext && (otherPolicy->_specified.definesPresentationContext == NO))
        otherPolicy.definesPresentationContext = _definesPresentationContext;
    
    if (_specified.providesPresentationContextTransitionStyle &&
        (otherPolicy->_specified.providesPresentationContextTransitionStyle == NO))
        otherPolicy.providesPresentationContextTransitionStyle = _providesPresentationContextTransitionStyle;
 
    if (_specified.animationDuration && (otherPolicy->_specified.animationDuration == NO))
        otherPolicy.animationDuration = _animationDuration;

    if (_specified.transitionDelegate && (otherPolicy->_specified.transitionDelegate == NO))
        otherPolicy.transitionDelegate = _transitionDelegate;
}

@end
