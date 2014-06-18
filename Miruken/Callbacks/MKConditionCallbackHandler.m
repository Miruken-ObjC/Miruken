//
//  MKConditionCallbackHandler.m
//  Miruken
//
//  Created by Craig Neuwirt on 9/12/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKConditionCallbackHandler.h"

@implementation MKConditionCallbackHandler
{
    MKWhenPredicate _condition;
}

+ (instancetype)for:(MKCallbackHandler *)aHandler when:(MKWhenPredicate)condition
{
    if (aHandler == nil)
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"handler cannot be nil"
                                     userInfo:nil];    
    }

    if (condition == nil)
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"condition cannot be nil"
                                     userInfo:nil];    
    }
    
    MKConditionCallbackHandler *conditional = [[MKConditionCallbackHandler alloc] initWithDecoratee:aHandler];
    conditional->_condition                 = condition;
    return conditional;
}

- (BOOL)handle:(id)callback greedy:(BOOL)greedy composition:(id<MKCallbackHandler>)composer
{
    return _condition(callback)
         ? [super handle:callback greedy:greedy composition:composer]
         : NO;
}

- (void)dealloc
{
    _condition = nil;
}

@end
