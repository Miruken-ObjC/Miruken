//
//  MKDynamicCallbackHandler.h
//  Miruken
//
//  Created by Craig Neuwirt on 9/10/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"

/**
  The MKDynamicCallbackHandler is the primary integration point with the
  MKCallbackHandler infrastructure.  It acts as a bridge between ordinary
  objective-c classes (usually Controllers) and the MKCallbackHandler protocol.
  This class can be extended directly to handle the callbacks or use a delegate
  when inheritance is not an option (i.e UIViewController).
 */
@interface MKDynamicCallbackHandler : MKCallbackHandler

@property (readonly, weak, nonatomic) id delegate;

+ (instancetype)delegateTo:(id)delegate;

- (SEL)resolveNamedSelector:(NSString *)selectorName target:(id)target;

@end
