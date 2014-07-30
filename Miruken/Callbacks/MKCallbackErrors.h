//
//  MKCallbackErrors.h
//  Miruken
//
//  Created by Craig Neuwirt on 11/21/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
  Error domain used to identify callback errors.
  */
extern NSString * const MKCallbackErrorDomain;

typedef NS_ENUM(NSInteger, MKCallbackErrors) {
    MKCallbackErrorCallbackNotHandled = 3000,
    MKCallbackErrorCallbackClassNotFound,
    MKCallbackErrorCallbackProtocolNotFound,
    MKCallbackErrorCallbackReceiverMismatch
};