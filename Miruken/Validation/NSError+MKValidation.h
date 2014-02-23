//
//  NSError+Validation.h
//  Miruken
//
//  Created by Craig Neuwirt on 11/19/12.
//  Copyright (c) 2012 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (NSError_MKValidation)

- (id)validationSourceCulprit;

- (NSString *)validationKeyPathCulprit;

- (NSError *)combineErrors:(NSError *)otherError;

@end
