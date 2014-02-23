//
//  MKValidationResult.h
//  Miruken
//
//  Created by Craig Neuwirt on 11/19/12.
//  Copyright (c) 2012 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
  MKValidationResult is a container for object validation results.
 */

@interface MKValidationResult : NSObject

+ (instancetype)validateObject:(id)object inScope:(NSString *)scope;

- (id)target;

- (NSString *)scope;

- (BOOL)isValid;

- (BOOL)isNotValid;

- (NSArray *)keyPathCulprits;

- (NSDictionary *)errors;

- (void)addError:(NSError *)error forKeyPath:(NSString *)keyPath;

- (NSArray *)errorsForKeyPath:(NSString *)keyPath;

- (NSError *)errorSummary;

@end
