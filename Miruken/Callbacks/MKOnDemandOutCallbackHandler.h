//
//  OnDemandOutCallbackHandler.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/3/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"
#import "MKWhen.h"

/**
  An MKOnDemandInCallbackHandler provides on-demand support for providing callbacks.
 */

@interface MKOnDemandOutCallbackHandler : MKCallbackHandler

+ (instancetype)providedBy:(MKOnDemandCallbackOut)provider when:(MKWhenPredicate)condition;

@end
