//
//  SomeViewController.h
//  Miruken
//
//  Created by Craig Neuwirt on 10/9/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKContextual.h"
#import "MKDeferred.h"

@interface SomeViewController : UIViewController <MKContextual>

- (void)doSomething;

- (NSInteger)add:(NSInteger)op to:(NSInteger)operand;

- (MKDeferred *)longRunningOperation;

@end
