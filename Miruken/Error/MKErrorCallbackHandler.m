
//
//  ErrorCallbackHandler.m
//  Miruken
//
//  Created by Craig Neuwirt on 11/16/12.
//  Copyright (c) 2012 Craig Neuwirt. All rights reserved.
//

#import "MKErrorCallbackHandler.h"
#import "MKDeferred.h"
#import "UIAlertView+Block.h"
#import "MKAlertViewMixin.h"
#import "MKMixingIn.h"
#import "NSObject+Context.h"

@interface MKErrorCallbackHandler() <MKAlertViewDelegate>
@end

@implementation MKErrorCallbackHandler

+ (void)initialize
{
    if (self ==  MKErrorCallbackHandler.class)
        [MKAlertViewMixin mixInto:self];
}

- (MKPromise)handleFailure:(id)reason context:(void *)context
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

- (MKPromise)handleError:(NSError *)error context:(void *)context
{
    NSString *title   = @"Error";
    NSString *message = @"An unspecified error has occurred.";
    
    return [MKErrors(self.composer) reportError:error message:message
                                         title:title context:context];
}

- (MKPromise)handleException:(NSException *)exception context:(void *)context
{
    return [MKErrors(self.composer) reportException:exception context:context];
}


- (MKPromise)reportError:(NSError *)error message:(NSString *)message
                   title:(NSString *)title context:(void *)context
{
    MKDeferred *deferred = [MKDeferred new];
    
    if (self.alertView)
        return [[deferred resolve:[MKWellKnownErrorResults errorInProgress]] promise];
    
    self.alertView = [[UIAlertView alloc] initWithTitle:title
                                                message:message
                                               delegate:nil
                                      cancelButtonTitle:@"Continue"
                                      otherButtonTitles:nil];
                  
    [self.alertView showUsingBlock:^(NSInteger buttonIndex) {
        if (buttonIndex != -1)
            [deferred resolve:[MKWellKnownErrorResults continue]];
        else
            [deferred cancel];
    }];
    
    return [deferred promise];
}

- (MKPromise)reportException:(NSException *)exception context:(void *)context
{
    MKDeferred *deferred = [MKDeferred new];
    
    if (self.alertView)
        return [[deferred resolve:[MKWellKnownErrorResults errorInProgress]] promise];
    
    self.alertView = [[UIAlertView alloc] initWithTitle:exception.name
                                                message:exception.reason delegate:self
                                      cancelButtonTitle:@"Continue" otherButtonTitles:nil];
    
    [self.alertView showUsingBlock:^(NSInteger buttonIndex) {
        if (buttonIndex != -1)
            [deferred resolve:[MKWellKnownErrorResults continue]];
        else
            [deferred cancel];
    }];
    
    return [deferred promise];
}

@end
