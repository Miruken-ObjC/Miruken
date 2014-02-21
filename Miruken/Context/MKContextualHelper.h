//
//  MKContextualHelper.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/18/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKContextual.h"

/**
  Provides helper methods for context management.
 */

@interface MKContextualHelper : NSObject

+ (MKContext *)resolveContext:(id)contextual;

+ (MKContext *)requireContext:(id)contextual;

+ (MKContext *)contextBoundTo:(id)contextual;

+ (void)endContextBoundTo:(id)contextual;

+ (MKContext *)bindChildContextFrom:(id)parent toChild:(id)child;

@end
