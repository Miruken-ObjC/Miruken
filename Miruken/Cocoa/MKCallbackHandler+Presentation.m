//
//  MKCallbackHandler+Presentation.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/23/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler+Presentation.h"
#import "MKPresentationPolicyHandler.h"
#import "MKCascadeCallbackHandler.h"

@implementation MKCallbackHandler (Presentation)

- (instancetype)presentModal
{
    MKPresentationPolicy *modalPolicy = [MKPresentationPolicy new];
    modalPolicy.modal                 = YES;
    return [self usePresentationPolicy:modalPolicy];
}

- (instancetype)presentFullScreen
{
    return [self presentStyle:UIModalPresentationFullScreen];
}

- (instancetype)presentPageSheet
{
    return [self presentStyle:UIModalPresentationPageSheet];
}

- (instancetype)presentFormSheet
{
    return [self presentStyle:UIModalPresentationFormSheet];
}

- (instancetype)presentCurrent
{
    return [self presentStyle:UIModalPresentationCurrentContext];
}

- (instancetype)presentStyle:(UIModalPresentationStyle)presentationStyle
{
    MKPresentationPolicy *presentationPolicy = [MKPresentationPolicy new];
    presentationPolicy.modalPresentationStyle = presentationStyle;
    return [self usePresentationPolicy:presentationPolicy];
}

- (instancetype)definesPresentationContext
{
    MKPresentationPolicy *presentationPolicy = [MKPresentationPolicy new];
    presentationPolicy.definesPresentationContext = YES;
    return [self usePresentationPolicy:presentationPolicy];
}

- (instancetype)providesPresentationContextTransition
{
    MKPresentationPolicy *presentationPolicy = [MKPresentationPolicy new];
    presentationPolicy.providesPresentationContextTransitionStyle = YES;
    return [self usePresentationPolicy:presentationPolicy];
}

- (instancetype)transition:(id<UIViewControllerTransitioningDelegate>)transition
{
    MKPresentationPolicy *presentationPolicy = [MKPresentationPolicy new];
    presentationPolicy.transitionDelegate = transition;
    return [self usePresentationPolicy:presentationPolicy];
}

- (instancetype)usePresentationPolicy:(MKPresentationPolicy *)policy
{
    MKPresentationPolicyHandler *policyHandler =
        [MKPresentationPolicyHandler handlerWithPresentationPolicy:policy];
    return [MKCascadeCallbackHandler withHandler:policyHandler cascadeTo:self];
}

@end
