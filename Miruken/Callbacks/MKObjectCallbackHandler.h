//
//  MKObjectCallbackHandler.h
//  Miruken
//
//  Created by Craig Neuwirt on 9/8/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"

/**
  An ObjectCallbackHandler handles ObjectCallbackReceivers by providing a
  specified instance of the callback.
  */

@interface MKObjectCallbackHandler : MKCallbackHandler

+ (instancetype)withObject:(id)object;

+ (instancetype)withObject:(id)object isKindOf:(BOOL)isKindOf;

@end
