//
//  MKCallbackHandler+Buffer.h
//  Miruken
//
//  Created by Craig Neuwirt on 4/5/13.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"
#import "MKBufferedPromise.h"

@interface MKCallbackHandler (Buffer)

- (instancetype)bufferPromise;

@end
