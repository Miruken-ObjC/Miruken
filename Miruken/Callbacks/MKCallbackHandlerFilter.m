//
//  MKCallbackHandlerFilter.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/1/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandlerFilter.h"
#import "MKInternalCallback.h"

@implementation MKCallbackHandlerFilter
{
    MKCallbackFilter  _filter;
}

+ (instancetype)for:(MKCallbackHandler *)handler filter:(MKCallbackFilter)filter;
{
    MKCallbackHandlerFilter *aHandler = [[self alloc] initWithDecoratee:handler];
    aHandler->_filter                 = filter;
    return aHandler;
}

- (BOOL)handle:(id)callback greedy:(BOOL)greedy composition:(id<MKCallbackHandler>)composer
{
    if (_filter == nil || [callback conformsToProtocol:@protocol(MKInternalCallback)])
        return [self.decoratee handle:callback greedy:greedy];
   
    if (composer == self)
        composer = self.decoratee;
    
    return _filter(callback, composer, ^{
        return [self.decoratee handle:callback greedy:greedy];
    });
}

@end
