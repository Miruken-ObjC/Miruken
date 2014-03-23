//
//  CallbackHandler+Subscripting.h
//  Miruken
//
//  Created by Craig Neuwirt on 8/13/13.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"

/**
  MKCallbackHandler category for supporting indexed subscripting.
 */

@interface MKCallbackHandler (Subscripting)

- (id)objectForKeyedSubscript:(id)classOrProtocolKey;

@end
