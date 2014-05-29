//
//  MKModalOptions.m
//  Miruken
//
//  Created by Craig Neuwirt on 5/25/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKModalOptions.h"
#import "MKModalFlipHorizontalTransition.h"

@implementation MKModalOptions
{
    id<UIViewControllerTransitioningDelegate> _transitionDelegate;
    
    struct
    {
        unsigned int modalTransitionStyle:1;
        unsigned int modalPresentationStyle:1;
        unsigned int definesPresentationContext:1;
        unsigned int providesPresentationContextTransitionStyle:1;
    } _specified;
}

- (void)setModalTransitionStyle:(UIModalTransitionStyle)modalTransitionStyle
{
    _modalTransitionStyle           = modalTransitionStyle;
    _specified.modalTransitionStyle = YES;
}

- (void)setModalPresentationStyle:(UIModalPresentationStyle)modalPresentationStyle
{
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

- (void)applyPolicyToViewController:(UIViewController *)viewController
{
    if (_specified.modalPresentationStyle)
        viewController.modalPresentationStyle = _modalPresentationStyle;
    
    if (_specified.definesPresentationContext)
        viewController.definesPresentationContext = _definesPresentationContext;
    
    if (_specified.providesPresentationContextTransitionStyle)
        viewController.providesPresentationContextTransitionStyle =
        _providesPresentationContextTransitionStyle;
    
    if (_specified.modalTransitionStyle)
    {
        if (_modalTransitionStyle == UIModalTransitionStyleFlipHorizontal)
        {
            _transitionDelegate = [MKModalFlipHorizontalTransition new];
            viewController.transitioningDelegate = _transitionDelegate;
        }
        else
        {
            viewController.modalTransitionStyle = _modalTransitionStyle;
        }
    }
}

- (void)mergeIntoOptions:(id<MKPresentationOptions>)otherOptions
{
    if ([otherOptions isKindOfClass:self.class] == NO)
        return;
    
    MKModalOptions *modalOptions = otherOptions;
    
    if (_specified.modalTransitionStyle && (modalOptions->_specified.modalTransitionStyle == NO))
        modalOptions.modalTransitionStyle = _modalTransitionStyle;
    
    if (_specified.modalPresentationStyle && (modalOptions->_specified.modalPresentationStyle == NO))
        modalOptions.modalPresentationStyle = _modalPresentationStyle;
    
    if (_specified.definesPresentationContext && (modalOptions->_specified.definesPresentationContext == NO))
        modalOptions.definesPresentationContext = _definesPresentationContext;
    
    if (_specified.providesPresentationContextTransitionStyle &&
        (modalOptions->_specified.providesPresentationContextTransitionStyle == NO))
        modalOptions.providesPresentationContextTransitionStyle = _providesPresentationContextTransitionStyle;
}

@end
