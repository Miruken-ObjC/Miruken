//
//  MKEndContextWhenAppResignsMixin.h
//  Miruken
//
//  Created by Craig Neuwirt on 9/10/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import "MKContextual.h"

/**
  This class is an opaque mix-in that ends the current context when
  the application becomes inactive.  Requires the target to be Contextual.
  e.g. MKEndContextWhenAppResignsMixin mixInto:MyModel.class]
 */

@interface MKEndContextWhenAppResignsMixin : NSObject <MKContextual>

+ (void)mixInto:(Class)class;

@end
