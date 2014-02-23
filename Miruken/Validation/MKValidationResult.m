//
//  MKValidationResult.m
//  Miruken
//
//  Created by Craig Neuwirt on 11/19/12.
//  Copyright (c) 2012 Craig Neuwirt. All rights reserved.
//

#import "MKValidationResult.h"
#import "NSError+MKValidation.h"

@implementation MKValidationResult
{
    id                   _target;
    NSString            *_scope;
    NSMutableDictionary *_errors;
}

+ (instancetype)validateObject:(id)object inScope:(NSString *)scope
{
    return [[MKValidationResult alloc] initWithObject:object andScope:scope];
}

- (id)initWithObject:(id)object andScope:(NSString *)scope
{
    if (object == nil)
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"object cannot be nil"
                                     userInfo:nil];

    if (self = [super init])
    {
        _target = object;
        _scope  = scope;
        _errors = [NSMutableDictionary new];
    }
    return self;
}

- (id)target
{
    return _target;
}

- (NSString *)scope
{
    return _scope;
}

- (BOOL)isValid
{
    return _errors.count == 0;
}

- (BOOL)isNotValid
{
    return _errors.count > 0;
}

- (NSArray *)keyPathCulprits
{
    return [_errors allKeys];
}

- (NSDictionary *)errors
{
    return _errors;
}

- (id)errorsForKeyPath:(NSString *)keyPath
{
    return [_errors objectForKey:keyPath];
}

- (void)addError:(NSError *)error forKeyPath:(NSString *)keyPath
{
    NSMutableArray *keyPathErrors = [_errors objectForKey:keyPath];
    if (keyPathErrors == nil)
        [_errors setValue:[NSMutableArray arrayWithObject:error] forKey:keyPath];
    else
        [keyPathErrors addObject:error];
}

- (NSError *)errorSummary
{
    if (self.isValid)
        return nil;
    
    NSError *summary = nil;
    for (NSError *validationError in self.errors)
        summary = summary ? [summary combineErrors:validationError] : validationError;
    
    return summary;
}

@end
