//
//  MKCallbackHandlerDecorator.m
//  Miruken
//
//  Created by Craig Neuwirt on 9/26/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandlerDecorator.h"
#import "MKDecorator.h"

@interface MKCallbackHandlerDecorator() <MKDecorator>
@end

@implementation MKCallbackHandlerDecorator

- (id)initWithDecoratee:(MKCallbackHandler *)decoratee
{
    if (decoratee == nil)
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"decoratee cannot be nil"
                                     userInfo:nil];
    
    if (self = [super init])
        self.decoratee = decoratee;
    return self;
}

- (void)setDecoratee:(MKCallbackHandler *)decoratee
{
    _decoratee = decoratee;
}

- (BOOL)handle:(id)callback greedy:(BOOL)greedy composition:(id<MKCallbackHandler>)composer
{
    return [_decoratee handle:callback greedy:greedy composition:composer]
        || [super handle:callback greedy:greedy composition:composer];
}

- (void)dealloc
{
    _decoratee = nil;
}

@end
