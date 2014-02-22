//
//  SomeContextualObject.h
//  Miruken
//
//  Created by Craig Neuwirt on 1/28/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKContextual.h"
#import "MKDeferred.h"

@interface SomeContextualObject : NSObject <MKContextual>

- (BOOL)initWasCalled;

@end
