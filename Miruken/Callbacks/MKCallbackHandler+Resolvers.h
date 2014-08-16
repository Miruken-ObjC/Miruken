//
//  CallbackHandler+Resolvers.h
//  Miruken
//
//  Created by Craig Neuwirt on 9/10/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"
#import "MKPromise.h"

/**
  MKCallbackHandler category for resolving callbacks using more intuitive verbage.
  */

@interface MKCallbackHandler (Resolvers)

- (id)resolve:(id)descriptor;

- (id)objectForKeyedSubscript:(id)descriptor;

@end