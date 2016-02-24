//
//  LITLightweightStore.h
//  LITLightweightStore
//
//  Created by Lobanov Dmitry on 31.08.15.
//  Copyright (c) 2015 lolgear. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString* LITLightweightStorePolicy;
extern LITLightweightStorePolicy LITLightweightStorePolicyDefaults;
extern LITLightweightStorePolicy LITLightweightStorePolicyKeychain;
extern LITLightweightStorePolicy LITLightweightStorePolicyMemory;

extern NSString* const LITLightweightStoreOptionsStoreScopeNameKey;
extern NSString* const LITLightweightStoreOptionsAllFieldsArrayKey;

@interface LITLightweightStore : NSObject

#pragma mark - Instantiation
- (instancetype) initWithOptions:(NSDictionary *)options;

#pragma mark - Accessors
@property (nonatomic, strong, readonly) NSDictionary *options;
@property (nonatomic, copy, readonly) NSString *storeScopeName;
@property (nonatomic, strong, readonly) NSArray *allFields;
@property (nonatomic, strong, readonly) NSArray *necessaryFields;
@property (nonatomic, copy, readonly) NSMutableDictionary *currentScopedStore;
@property (nonatomic, copy, readonly) id storeEntity;

#pragma mark - Load
- (void)setUp;
- (void)tearDown;

#pragma mark - Getters / Setters
- (void)setField:(id<NSCopying>)name byValue:(id<NSCopying>)value;
- (id)fieldByName:(id<NSCopying>)name;

@end

@interface LITLightweightStore (Subscription)

/*
 Getters and Setters
 Unlike NSDictionary accessor methods, lightweight store methods
 * -setField:byValue
 * -fieldByName:
 should work nil-safe.
 
 Their opponents are item manipulation methods
 * -setItem:forKey:
 * -itemForKey:
 * -removeItemForKey:
 
 They are used in subsciption interface implementation and should work as 'expected' with nil values like setting nil means deletion and should be handled separately.
 */

#pragma mark - Subscription
- (id)objectForKeyedSubscript:(id<NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key;

- (void)setItem:(id)item forKey:(id<NSCopying>)key;
- (id)itemForKey:(id<NSCopying>)key;
- (void)removeItemForKey:(id<NSCopying>)key;

@end

@interface LITLightweightStore (Cluster)

@property (nonatomic, readonly) LITLightweightStorePolicy policy;

- (BOOL)isEqualToPolicy:(LITLightweightStorePolicy)policy;

+ (instancetype)storeWithPolicy:(LITLightweightStorePolicy)policy andOptions:(NSDictionary *)options;

+ (instancetype)store:(LITLightweightStore*)store switchPolicy:(LITLightweightStorePolicy)policy;
- (instancetype)switchPolicy:(LITLightweightStorePolicy)policy;

@end