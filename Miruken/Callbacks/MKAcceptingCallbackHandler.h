//
//  MKAcceptingCallbackHandler.m
//  Miruken
//
//  Created by Craig Neuwirt on 9/9/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"

/**
  An MKAcceptingCallbackHandler provides on-demand support for accepting callbacks.
  */

typedef BOOL (^MKAcceptingBlock)(id callback, id<MKCallbackHandler> composer);

@interface MKAcceptingCallbackHandler : MKCallbackHandler

+ (instancetype)handledBy:(MKAcceptingBlock)handler;

@end
