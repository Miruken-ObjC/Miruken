//
//  MKSynchronousResult.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/26/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKAsyncResult.h"

/**
  An AsyncResult suitable for operations that behave synchronously.
 */

@interface MKSynchronousResult : NSObject <MKAsyncResult>

- (id)initWithInvocation:(NSInvocation *)invocation copyBlockArguments:(BOOL)copyBlockArguments;

@end
