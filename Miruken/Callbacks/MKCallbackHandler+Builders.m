//
//  CallbackHandler+Builders.m
//  Miruken
//
//  Created by Craig Neuwirt on 9/10/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler+Builders.h"
#import "MKConditionCallbackHandler.h"
#import "MKCascadeCallbackHandler.h"
#import "MKCompositeCallbackHandler.h"
#import "MKAcceptingCallbackHandler.h"
#import "MKProvidingCallbackHandler.h"
#import "MKObjectCallbackReceiver.h"
#import "MKProtocolCallbackReceiver.h"

@implementation MKCallbackHandler (Builders)

- (instancetype)when:(MKWhenPredicate)condition
{
    return [MKConditionCallbackHandler for:self when:condition];
}

- (instancetype)whenKindOfClass:(Class)aClass
{
    return [self when:^(id callback) 
    { 
        if ([callback isKindOfClass:MKObjectCallbackReceiver.class])
        {
            MKObjectCallbackReceiver *receiver = (MKObjectCallbackReceiver *)callback;
            return [[receiver forClass] isSubclassOfClass:aClass];
        }
        return [callback isKindOfClass:aClass];
    }];
}

- (instancetype)whenMemberOfClass:(Class)aClass
{
    return [self when:^(id callback) 
    { 
        if ([callback isKindOfClass:MKObjectCallbackReceiver.class])
        {
            MKObjectCallbackReceiver *receiver = (MKObjectCallbackReceiver *)callback;
            return (BOOL)([receiver forClass] == aClass);
        }
        return [callback isMemberOfClass:aClass];
    }];        
}

- (instancetype)whenConformsToProtocol:(Protocol *)protocol
{
    return [self when:^(id callback) 
    { 
        if ([callback isKindOfClass:MKObjectCallbackReceiver.class])
        {
            MKObjectCallbackReceiver *receiver = (MKObjectCallbackReceiver *)callback;
            return [[receiver forClass] conformsToProtocol:protocol];
        }
        if ([callback isKindOfClass:MKProtocolCallbackReceiver.class])
        {
            MKProtocolCallbackReceiver *receiver = (MKProtocolCallbackReceiver *)callback;
            return (BOOL)([receiver forProtocol] == protocol);
        }        
        return [callback conformsToProtocol:protocol];
    }];
}

- (instancetype)whenPredicate:(NSPredicate *)predicate
{
    return [self when:^(id callback)
    {
        if ([callback isKindOfClass:MKObjectCallbackReceiver.class])
        {
            MKObjectCallbackReceiver *receiver = (MKObjectCallbackReceiver *)callback;
            return (BOOL)(receiver.object != nil
                && [predicate evaluateWithObject:receiver.object]);
        }        
        return [predicate evaluateWithObject:callback];
    }];
}

- (instancetype)then:(MKCallbackHandler *)handler
{
    return handler == nil ? self :
       [MKCascadeCallbackHandler withHandler:self cascadeTo:handler];
}

- (instancetype)thenAll:(MKCallbackHandler *)handler, ...
{
    va_list args;
    va_start(args, handler);
    MKCompositeCallbackHandler *composite = [MKCompositeCallbackHandler withHandler:self];
    for (id<MKCallbackHandler> arg = handler; arg != nil; arg = va_arg(args, MKCallbackHandler *))
        [composite addHandler:arg];
    va_end(args);
    return composite;
}

+ (MKAcceptingCallbackHandler *)acceptingWith:(MKAcceptingCallbackBlock)handler
{
    return [MKAcceptingCallbackHandler handledBy:handler];
}

+ (MKProvidingCallbackHandler *)providingWith:(MKPovidingCallbackBlock)provider
{
    return [MKProvidingCallbackHandler providedBy:provider];
}

@end
