//
//  MKAsyncProxyResult.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/23/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKAsyncResult.h"

/**
  Extends to the AsyncResult protocol to present the asynchronous
  result as a proxy when the result is an object (id).
  Accessing any members of this proxy will block until the actual result
  is available.
 */

@interface MKAsyncProxyResult : NSProxy <MKAsyncResult>

- (id)initWithInvocation:(NSInvocation *)invocation;

@end
