//
//  MKErrors.h
//  Miruken
//
//  Created by Craig Neuwirt on 11/15/12.
//  Copyright (c) 2012 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKWellKnownErrorResults.h"
#import "MKPromise.h"

@protocol MKErrors

@optional
- (MKPromise)handleFailure:(id)reason context:(void *)context;

- (MKPromise)handleError:(NSError *)error context:(void *)context;

- (MKPromise)handleException:(NSException *)exception context:(void *)context;

- (MKPromise)reportError:(NSError *)error message:(NSString *)message
                   title:(NSString *)title context:(void *)context;

- (MKPromise)reportException:(NSException *)exception context:(void *)context;

@end

#define MKErrors(handler)  ((id<MKErrors>)(handler))