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
- (id<MKPromise>)selectedDetail:(Class)detailClass;

- (id<MKPromise>)selectedDetails:(Class)detailClass;

- (void)selectDetail:(id)selectedDetail;

- (void)deselectDetail:(id)selectedDetail;

- (BOOL)hasPreviousDetail:(Class)detailClass;

- (BOOL)hasNextDetail:(Class)detailClass;

- (id<MKPromise>)previousDetail:(Class)detailClass;

- (id<MKPromise>)nextDetail:(Class)detailClass;

- (id<MKPromise>)addDetail:(id)detail;

- (id<MKPromise>)removeDetail:(id)detail delete:(BOOL)delete;

@end

#define MKMasterDetail(handler)  ((id<MKMasterDetail>)(handler))

@protocol MKMasterDetailAware <NSObject>

@optional
- (void)masterChanged;

- (void)didSelectDetail:(id)detail;

- (void)didDeselectDetail:(id)detail;

- (void)didRemoveDetail:(id)detail;

@end

#define MKMasterDetailAware(handler)  ((id<MKMasterDetailAware>)(handler))