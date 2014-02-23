//
//  MKValidation.h
//  Miruken
//
//  Created by Craig Neuwirt on 2/4/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import "MKValidationResult.h"
#import "MKValidationErrors.h"

@protocol MKValidation

@optional
- (BOOL)validateObject:(id)object scope:(NSString *)scope;

- (BOOL)validateObject:(id)object scope:(NSString *)scope
                result:(MKValidationResult * __autoreleasing *)result;

@end

#define MKValidation(handler)  ((id<MKValidation>)(handler))
