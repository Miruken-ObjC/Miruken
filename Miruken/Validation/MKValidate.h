//
//  MKValidate.h
//  Miruken
//
//  Created by Craig Neuwirt on 2/4/13.
//  Copyright (c) 2013 ZixCorp. All rights reserved.
//

#import "MKValidationResult.h"
#import "MKValidationErrors.h"

@protocol MKValidate

@optional
- (BOOL)validateObject:(id)object scope:(NSString *)scope;

- (BOOL)validateObject:(id)object scope:(NSString *)scope
                result:(MKValidationResult * __autoreleasing *)result;

@end

#define MKValidate(handler)  ((id<MKValidate>)(handler))
