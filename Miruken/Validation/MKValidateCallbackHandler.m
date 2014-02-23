//
//  ValidationCallbackHandler.m
//  Miruken
//
//  Created by Craig Neuwirt on 2/4/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import "MKValidateCallbackHandler.h"
#import "MKValidationExtension.h"
#import "MKContextual.h"

@implementation MKValidateCallbackHandler

+ (void)initialize
{
    if (self == MKValidateCallbackHandler.class)
        [MKValidationExtension install];
}

- (BOOL)validateObject:(id)object scope:(NSString *)scope
{
    MKValidationResult *validation;
    return [self validateObject:object scope:scope result:&validation];
}

- (BOOL)validateObject:(id)object scope:(NSString *)scope
                result:(MKValidationResult *__autoreleasing *)result
{
    MKValidationResult *validation = [MKValidationResult validateObject:object inScope:scope];
    if ([self.composer handle:validation])
    {
        if (result)
            *result = validation;
        return validation.isValid;
    }
    return YES;
}

@end
