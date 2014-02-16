//
//  ReadWriteLock.m
//  Miruken
//
//  Created by Craig Neuwirt on 4/24/13.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKReadWriteLock.h"
#import <pthread.h>

@implementation MKReadWriteLock
{
    pthread_rwlock_t _lock;
}

- (id)init
{
	if (self = [super init])
		pthread_rwlock_init(&_lock, NULL);
	return self;
}

- (void)lock
{
	pthread_rwlock_rdlock(&_lock);
}

- (void)unlock
{
	pthread_rwlock_unlock(&_lock);
}

- (BOOL)tryLock
{
	return (pthread_rwlock_tryrdlock(&_lock) == 0);
}

- (void)lockForWriting
{
	pthread_rwlock_wrlock(&_lock);
}

- (BOOL)tryLockForWriting
{
	return (pthread_rwlock_trywrlock(&_lock) == 0);
}

- (void)dealloc
{
	pthread_rwlock_destroy(&_lock);
}

@end

#pragma mark - Block support

@implementation MKReadWriteLock (ReadWriteLock_Block)

- (void)reading:(dispatch_block_t)block
{
    [self lock];
    @try {
        block();
    }
    @finally {
        [self unlock];
    }
}

- (void)writing:(dispatch_block_t)block
{
    [self lockForWriting];
    @try {
        block();
    }
    @finally {
        [self unlock];
    }
}

- (BOOL)tryWriting:(dispatch_block_t)block
{
    if ([self tryLockForWriting] == NO)
        return NO;
    
    @try {
        block();
    }
    @finally {
        [self unlock];
    }    
}

@end