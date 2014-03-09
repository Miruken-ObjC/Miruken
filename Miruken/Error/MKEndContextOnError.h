//
//  MKEndContextOnError.h
//  Miruken
//
//  Created by Craig Neuwirt on 9/3/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import "MKErrors.h"
#import "MKContextual.h"

@interface MKEndContextOnError : MKContextual <MKErrors>
@end

@interface MKContext (MKContext_EndContextOnError)

- (MKContext *)endContextOnError;

@end