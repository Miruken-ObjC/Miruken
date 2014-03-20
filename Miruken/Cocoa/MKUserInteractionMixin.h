//
//  MKUserIneractionMixin.h
//  Miruken
//
//  Created by Craig Neuwirt on 4/16/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
  Protocol adopted by targets interested in user interaction
 */

@protocol MKUserInteractionDelegate

@optional
- (BOOL)eventDetected:(UIEvent *)event;

@end

/**
  This class is an opaque mix-in that detects user interaction.
  It can only be mixed into UIApplication classes.
    e.g. MKUserIneractionMixin mixInto:MyApplication.class]
 */

@interface MKUserInteractionMixin : UIApplication

@end
