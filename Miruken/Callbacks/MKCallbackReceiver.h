//
//  MKCallbackReceiver.h
//  Miruken
//
//  Created by Craig Neuwirt on 9/14/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPromise.h"

/**
  The MKCallbackReceiver protocol identifies a callback to be used in the "pull" model.
  Typically, callbacks are "pushed" into the pipeline where one or more MKCallbackHandlers
  operate on them.  This protocol is used by Callback wrappers to allow MKCallbackHandlers
  to provide instances of callbacks rather than accept instances to mutate them.
  */

@protocol MKCallbackReceiver <MKPromise>

@property (readonly, strong, nonatomic) id object;

- (id)resolve:(id)result;

- (BOOL)tryResolve:(id)result;

- (id)reject:(id)reason;

@end
