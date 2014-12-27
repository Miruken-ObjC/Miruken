//
//  MasterDetail.h
//  Miruken
//
//  Created by Venkat Palivela on 3/27/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import "MKPromise.h"

@protocol MKMasterDetail <NSObject>

@optional
- (MKPromise)selectedDetail:(Class)detailClass;

- (MKPromise)selectedDetails:(Class)detailClass;

- (void)selectDetail:(id)selectedDetail;

- (void)deselectDetail:(id)selectedDetail;

- (BOOL)hasPreviousDetail:(Class)detailClass;

- (BOOL)hasNextDetail:(Class)detailClass;

- (MKPromise)previousDetail:(Class)detailClass;

- (MKPromise)nextDetail:(Class)detailClass;

- (MKPromise)addDetail:(id)detail;

- (MKPromise)updateDetail:(id)detail;

- (MKPromise)removeDetail:(id)detail delete:(BOOL)delete;

@end

#define MKMasterDetail(handler)  ((id<MKMasterDetail>)(handler))

@protocol MKMasterDetailAware <NSObject>

@optional
- (void)masterChanged:(id)master;

- (void)didSelectDetail:(id)detail master:(id)master;

- (void)didDeselectDetail:(id)detail master:(id)master;

- (void)didRemoveDetail:(id)detail master:(id)master;

@end

#define MKMasterDetailAware(handler)  ((id<MKMasterDetailAware>)(handler))