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

- (instancetype)modal:(BOOL)modal
{
    MKPresentationPolicy *modalPolicy = [MKPresentationPolicy new];
    modalPolicy.modal                 = YES;
    return [self usePresentationPolicy:modalPolicy];
}

- (instancetype)usePresentationPolicy:(MKPresentationPolicy *)policy
{
    MKPresentationPolicyHandler *policyHandler =
        [MKPresentationPolicyHandler handlerWithPresentationPolicy:policy];
    return [MKCascadeCallbackHandler withHandler:policyHandler cascadeTo:self];
}

- (instancetype)presentationPolicy:(MKConfigurePresentationPolicy)configurePolicy
{
    MKPresentationPolicy *presentationPolicy = [MKPresentationPolicy new];
    if (configurePolicy)
        configurePolicy(presentationPolicy);
    return [self usePresentationPolicy:presentationPolicy];
}

@end
