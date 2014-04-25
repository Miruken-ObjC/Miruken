//
//  MKOperationProxyResult.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/29/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAsyncProxyResult.h"
#import "MKOperationResult.h"

/**
 Specialized OperationResult that provides a proxy to the result.
 */

@interface MKOperationProxyResult : MKAsyncProxyResult <MKOperationResult>

- (id)initWithInvocation:(NSInvocation *)invocation;

@end
