//
//  MKTypeOf.h
//  Miruken
//
//  Created by Craig Neuwirt on 8/16/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MKIdType) {
    MKIdTypeNil = 0,
    MKIdTypeObject,
    MKIdTypeClass,
    MKIdTypeProtocol,
    MKIdTypeBlock
};

@interface MKTypeOf : NSObject

+ (MKIdType)id:(id)anything;

@end
