//
//  MKProtocolCallbackReceiver.h
//  Miruken
//
//  Created by Craig Neuwirt on 9/10/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackReceiver.h"
#import "MKDeferred.h"

/**
  An MKProtocolCallbackReceiver is a callback wrapper for receiving instances
  conforming to a particular protocol.
 */

@interface MKProtocolCallbackReceiver : MKDeferred <MKCallbackReceiver>

@property (readonly, assign, nonatomic) Protocol *forProtocol;

+ (instancetype)forProtocol:(Protocol *)protocol;

@end
