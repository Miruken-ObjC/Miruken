//
//  Configuration.h
//  MirukenTests
//
//  Created by Craig Neuwirt on 9/11/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Configuration <NSObject>
@end

@interface Configuration : NSObject<Configuration>

- (id)initWithName:(NSString *)name;

@property (readonly,  copy,   nonatomic) NSString       *name;
@property (readwrite, copy,   nonatomic) NSString       *url;
@property (readonly,  strong, nonatomic) NSMutableArray *tags;

@end
