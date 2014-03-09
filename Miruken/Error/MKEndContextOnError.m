//
//  MKEndContextOnError.m
//  Miruken
//
//  Created by Craig Neuwirt on 9/3/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import "MKEndContextOnError.h"
#import "MKContext+Subscribe.h"
#import "UIAlertView+Block.h"
#import "MKDeferred.h"

@implementation MKEndContextOnError

- (id<MKPromise>)reportError:(NSError *)error message:(NSString *)message
                       title:(NSString *)title context:(void *)context
{
    MKDeferred *deferred = [MKDeferred new];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message
                                                   delegate:self cancelButtonTitle:@"Continue"
                                          otherButtonTitles:nil];
    
    [alert showUsingBlock:^(NSInteger buttonIndex) {
        [self endContext];
        [deferred resolve:nil];
    }];
    
    return [deferred promise];
}

@end

@implementation MKContext (MKCallbackHandler_EndContextOnError)

- (MKContext *)endContextOnError
{
    __block MKEndContextOnError *end = [[MKEndContextOnError allocInContext:self] init];
    [end.context subscribeDidEnd:^(id<MKContext> context) {
        end = nil;  // keeps alive until context ends
    }];
    return end.context;
}

@end
