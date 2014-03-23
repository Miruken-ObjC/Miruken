//
//  MKPresentationPolicyHandler.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/22/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPresentationPolicyHandler.h"

@implementation MKPresentationPolicyHandler

+ (instancetype)handlerWithPresentationPolicy:(MKPresentationPolicy *)policy
{
    if (policy == nil)
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"policy cannot be nil"
                                     userInfo:nil];
    
    MKPresentationPolicyHandler *handler = [self new];
    handler->_presentationPolicy         = [policy copy];
    return handler;
}

- (BOOL)handle:(id)callback greedy:(BOOL)greedy composition:(id<MKCallbackHandler>)composer
{
    if ([callback isKindOfClass:MKPresentationPolicy.class])
    {
        [_presentationPolicy mergeIntoPolicy:callback];
        return YES;
    }
    return NO;
}

@end
