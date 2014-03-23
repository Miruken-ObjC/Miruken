//
//  MKPresentationPolicy.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/22/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPresentationPolicy.h"

@implementation MKPresentationPolicy
{
    struct
    {
        unsigned int modal:1;
        unsigned int modalTransitionStyle:1;
        unsigned int modalPresentationStyle:1;
        unsigned int definesPresentationContext:1;
        unsigned int providesPresentationContextTransitionStyle:1;
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
    self.modal                            = YES;
    _definesPresentationContext           = definesPresentationContext;
    _specified.definesPresentationContext = YES;
}

- (void)setProvidesPresentationContextTransitionStyle:(BOOL)providesPresentationContextTransitionStyle
{
    self.modal                                            = YES;
    _providesPresentationContextTransitionStyle           = providesPresentationContextTransitionStyle;
    _specified.providesPresentationContextTransitionStyle = YES;
}

- (void)applyToViewController:(UIViewController *)viewController
{
    if (_specified.modalTransitionStyle)
        viewController.modalTransitionStyle = _modalTransitionStyle;
    
    if (_specified.modalPresentationStyle)
        viewController.modalPresentationStyle = _modalPresentationStyle;
    
    if (_specified.definesPresentationContext)
        viewController.definesPresentationContext = _definesPresentationContext;
    
    if (_specified.providesPresentationContextTransitionStyle)
        viewController.providesPresentationContextTransitionStyle =
            _providesPresentationContextTransitionStyle;
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
}

@end
