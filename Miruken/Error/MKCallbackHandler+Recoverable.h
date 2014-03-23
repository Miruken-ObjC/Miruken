//
//  MKCallbackHandler+Recoverable.h
//  Miruken
//
//  Created by Craig Neuwirt on 11/30/12.
//  Copyright (c) 2012 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"

@interface MKCallbackHandler (Recoverable)

- (instancetype)recoverable;

- (instancetype)recoverableInContext:(void *)context;

@end
