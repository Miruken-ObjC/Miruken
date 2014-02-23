//
//  MKSideEffectCallbackHandler.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/1/12.
//  Copyright (c) 2012 ZixCorp. All rights reserved.
//

#import "MKDynamicCallbackHandler.h"
#import "MKSideEffects.h"

/**
  The MKSideEffectCallbackHandler is a CallbackHandler that handles side-effects. A
  side-effect is typically a non-business operation like showing networking status
  or loading dialogues.
  */

@interface MKSideEffectCallbackHandler : MKDynamicCallbackHandler <MKSideEffects>

@end
