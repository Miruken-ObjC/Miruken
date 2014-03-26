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

#pragma mark - Modal presentations

- (instancetype)presentModal
{
    MKPresentationPolicy *modalPolicy = [MKPresentationPolicy new];
    modalPolicy.modal                 = YES;
    return [self usePresentationPolicy:modalPolicy];
}

- (instancetype)presentFullScreen
{
    return [self presentationStyle:UIModalPresentationFullScreen];
}

- (instancetype)presentPageSheet
{
    return [self presentationStyle:UIModalPresentationPageSheet];
}

- (instancetype)presentFormSheet
{
    return [self presentationStyle:UIModalPresentationFormSheet];
}

- (instancetype)presentCurrent
{
    return [self presentationStyle:UIModalPresentationCurrentContext];
}

- (instancetype)presentationStyle:(UIModalPresentationStyle)presentationStyle
{
    MKPresentationPolicy *presentationPolicy = [MKPresentationPolicy new];
    presentationPolicy.modalPresentationStyle = presentationStyle;
    return [self usePresentationPolicy:presentationPolicy];
}

#pragma mark - Modal transitions

- (instancetype)modalTransitionCoverVertical
{
    return [self modalTransitionStyle:UIModalTransitionStyleCoverVertical];
}

- (instancetype)modalTransitionFlipHorizontal
{
    return [self modalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
}

- (instancetype)modalTransitionCrossDissolve
{
    return [self modalTransitionStyle:UIModalTransitionStyleCrossDissolve];
}

- (instancetype)modalTransitionPartialCurl
{
    return [self modalTransitionStyle:UIModalTransitionStylePartialCurl];
}

- (instancetype)modalTransitionStyle:(UIModalTransitionStyle)transitionStyle
{
    MKPresentationPolicy *presentationPolicy = [MKPresentationPolicy new];
    presentationPolicy.modalTransitionStyle  = transitionStyle;
    return [self usePresentationPolicy:presentationPolicy];
}

#pragma mark - Animation options

- (instancetype)transitionFlipFromLeft
{
     return [self animationOptions:UIViewAnimationOptionTransitionFlipFromLeft];
}

- (instancetype)transitionFlipFromRight
{
     return [self animationOptions:UIViewAnimationOptionTransitionFlipFromRight];
}

- (instancetype)transitionCurlUp
{
     return [self animationOptions:UIViewAnimationOptionTransitionCurlUp];
}

- (instancetype)transitionCurlDown
{
     return [self animationOptions:UIViewAnimationOptionTransitionCurlDown];
}

- (instancetype)transitionCrossDissolve
{
     return [self animationOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

- (instancetype)transitionFlipFromTop
{
     return [self animationOptions:UIViewAnimationOptionTransitionFlipFromTop];
}

- (instancetype)transitionFlipFromBottom
{
    return [self animationOptions:UIViewAnimationOptionTransitionFlipFromBottom];
}

- (instancetype)animationOptions:(UIViewAnimationOptions)options
{
    MKPresentationPolicy *presentationPolicy = [MKPresentationPolicy new];
    presentationPolicy.animationOptions      = options;
    return [self usePresentationPolicy:presentationPolicy];
}

- (instancetype)transition:(id<UIViewControllerTransitioningDelegate>)transition
{
    MKPresentationPolicy *presentationPolicy = [MKPresentationPolicy new];
    presentationPolicy.transitionDelegate = transition;
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

- (instancetype)usePresentationPolicy:(MKPresentationPolicy *)policy
{
    MKPresentationPolicyHandler *policyHandler =
        [MKPresentationPolicyHandler handlerWithPresentationPolicy:policy];
    return [MKCascadeCallbackHandler withHandler:policyHandler cascadeTo:self];
}

@end
