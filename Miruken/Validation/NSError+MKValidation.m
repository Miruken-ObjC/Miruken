//
//  NSError+Validation.m
//  Miruken
//
//  Created by Craig Neuwirt on 11/19/12.
//  Copyright (c) 2012 Craig Neuwirt. All rights reserved.
//

#import "NSError+MKValidation.h"
#import "MKValidationErrors.h"
#import <CoreData/CoreData.h>

@implementation NSError (NSError_MKValidation)

- (id)validationSourceCulprit
{
    return self.userInfo[MKValidationErrorSourceUserInfoKey];
}

- (NSString *)validationKeyPathCulprit
{
    return self.userInfo[MKValidationErrorKeyPathUserInfoKey];
}

- (NSError *)combineErrors:(NSError *)otherError
{
    NSMutableDictionary *userInfo    = [NSMutableDictionary dictionary];
    NSMutableArray      *otherErrors = [NSMutableArray arrayWithObject:otherError];
    
    if (self.code == NSValidationMultipleErrorsError)
    {
        [userInfo addEntriesFromDictionary:self.userInfo];
        [otherErrors addObjectsFromArray:[userInfo objectForKey:NSDetailedErrorsKey]];
    }
    else
    {
        [otherErrors addObject:self];
    }
    
    [userInfo setObject:otherErrors forKey:NSDetailedErrorsKey];
    
    return [NSError errorWithDomain:NSCocoaErrorDomain
                               code:NSValidationMultipleErrorsError
                           userInfo:userInfo];
}

@end
