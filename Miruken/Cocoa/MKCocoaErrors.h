//
//  MKCocoaErrors.h
//  Miruken
//
//  Created by Craig Neuwirt on 4/20/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
  Error domain used to identify cocoa errors.
 */
extern NSString * const MKCocoaErrorDomain;

typedef NS_ENUM(NSInteger, MKCocoaErrors) {
    MKCocoaErrorTransitionInProgress = 3000
};