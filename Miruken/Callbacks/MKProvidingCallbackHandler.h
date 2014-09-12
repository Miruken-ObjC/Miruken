//
//  MKProvidingCallbackHandler.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/3/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"

/**
  An MKProvidingtCallbackHandler provides on-demand support for providing callbacks.
 */

typedef id (^MKPovidingBlock)(id<MKCallbackHandler> composer);

@interface MKProvidingCallbackHandler : MKCallbackHandler

+ (instancetype)providedBy:(MKPovidingBlock)provider;

@end
