//
//  MKReadWriteLock.h
//  Miruken
//
//  Created by Craig Neuwirt on 4/24/13.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKReadWriteLock : NSObject <NSLocking>

- (BOOL)tryLock;

- (void)lockForWriting;

- (BOOL)tryLockForWriting;

@end


@interface MKReadWriteLock (MKReadWriteLock_Block)

- (void)reading:(dispatch_block_t)block;

- (void)writing:(dispatch_block_t)block;

- (BOOL)tryWriting:(dispatch_block_t)block;

@end
