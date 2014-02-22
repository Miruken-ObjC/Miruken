//
//  MKActionSheetMixin.h
//  Miruken
//
//  Created by Craig Neuwirt on 9/10/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
  Protocol adopted by targets requiring UIActionSheet mixin.
 */

@protocol MKActionSheetDelegate <UIActionSheetDelegate>

@optional
@property (strong, nonatomic) UIActionSheet *actionSheet;

@end

/**
  This class is an opaque mix-in that dismisses the active UIActionSheet when the
  application becomes inactive.
  e.g. MKActionSheetMixin mixInto:MyViewController.class]
 */

@interface MKActionSheetMixin : NSObject

+ (void)mixInto:(Class)class;

@end
