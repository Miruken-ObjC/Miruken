
//
//  ErrorCallbackHandler.m
//  Miruken
//
//  Created by Craig Neuwirt on 11/16/12.
//  Copyright (c) 2012 Craig Neuwirt. All rights reserved.
//

#import "MKErrorCallbackHandler.h"
#import "MKContextual.h"
#import "MKDeferred.h"
#import "UIAlertView+Block.h"
#import "MKAlertViewMixin.h"

@interface MKErrorCallbackHandler() <MKAlertViewDelegate>
@end

@implementation MKErrorCallbackHandler
{
    BOOL _alertingError;
}

@synthesize alertView = _alertView;

+ (void)initialize
{
    if (self ==  MKErrorCallbackHandler.class)
        [MKAlertViewMixin mixInto:self];
}

- (id<MKPromise>)handleFailure:(id)reason context:(void *)context
{
    if (reason != nil)
    {
        if ([reason isKindOfClass:NSError.class])
            return [MKErrors(self.composer) handleError:reason context:context];
    
        if ([reason isKindOfClass:NSException.class])
            return [MKErrors(self.composer) handleException:reason context:context];
    }
    return [[MKDeferred resolved] promise];
}

- (id<MKPromise>)handleError:(NSError *)error context:(void *)context
{
    NSString *title   = @"Error";
    NSString *message = @"An unspecified error has occurred.";
    
    return [MKErrors(self.composer) reportError:error message:message
                                         title:title context:context];
}

- (id<MKPromise>)handleException:(NSException *)exception context:(void *)context
{
    return [MKErrors(self.composer) reportException:exception context:context];
}


- (id<MKPromise>)reportError:(NSError *)error message:(NSString *)message
              title:(NSString *)title context:(void *)context
{
    MKDeferred *deferred = [MKDeferred new];
    
    if (_alertingError)
        return [[deferred resolve:[MKWellKnownErrorResults errorInProgress]] promise];
    
    _alertView = [[UIAlertView alloc] initWithTitle:title
                                             message:message
                                           delegate:nil
                                   cancelButtonTitle:@"Continue"
                                   otherButtonTitles:nil];
                  
    [_alertView showUsingBlock:^(NSInteger buttonIndex) {
        _alertingError = NO;
        [deferred resolve:[MKWellKnownErrorResults continue]];
        _alertView     = nil;
    }];
    
    _alertingError = YES;
    
    return [deferred promise];
}

- (id<MKPromise>)reportException:(NSException *)exception context:(void *)context
{
    MKDeferred *deferred = [MKDeferred new];
    
    if (_alertingError)
        return [[deferred resolve:[MKWellKnownErrorResults errorInProgress]] promise];
    
    _alertView = [[UIAlertView alloc] initWithTitle:exception.name
                                message:exception.reason delegate:self
                      cancelButtonTitle:@"Continue" otherButtonTitles:nil];
    
    [_alertView showUsingBlock:^(NSInteger buttonIndex) {
        _alertingError = NO;
        [deferred resolve:[MKWellKnownErrorResults continue]];
        _alertView     = nil;
    }];
    
    _alertingError = YES;
    
    return [deferred promise];
}

@end
