//
//  MKValidationErrors.h
//  Miruken
//
//  Created by Craig Neuwirt on 2/4/13.
//  Copyright (c) 2013 ZixCorp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSError+MKValidation.h"

/**
  Error domain used to identify validation errors.
 */
extern NSString * const MKValidationErrorDomain;

/**
  NSError userInfo key containing the keypath of the validation error.
 */
extern NSString * const MKValidationErrorKeyPathUserInfoKey;

/**
  NSError userInfo key containing the source of the validation error.
  */
extern NSString * const MKValidationErrorSourceUserInfoKey;

typedef NS_ENUM(NSUInteger, ValidationErrors) {
    MKValidationErrorEmpty    = 3000,
    MKValidationErrorInvalidEmailAddress
};
