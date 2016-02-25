//
//  LITLightweightStore.m
//  LITLightweightStore
//
//  Created by Lobanov Dmitry on 31.08.15.
//  Copyright (c) 2015 lolgear. All rights reserved.
//

#import "LITLightweightStore.h"

#import <UICKeyChainStore/UICKeyChainStore.h>

LITLightweightStorePolicy LITLightweightStorePolicyDefaults = @"LITLightweightStorePolicyDefaults";
LITLightweightStorePolicy LITLightweightStorePolicyKeychain = @"LITLightweightStorePolicyKeychain";
LITLightweightStorePolicy LITLightweightStorePolicyMemory = @"LITLightweightStorePolicyMemory";

NSString* const LITLightweightStoreOptionsStoreScopeNameKey = @"LITLightweightStoreOptionsStoreScopeNameKey";
NSString* const LITLightweightStoreOptionsAllFieldsArrayKey = @"LITLightweightStoreOptionsAllFieldsArrayKey";

@interface LITLightweightStore ()

#pragma mark - Accessors
@property (nonatomic, copy) NSString *storeScopeName;
@property (nonatomic, strong) NSArray *allFields;

@end

@implementation LITLightweightStore

#pragma mark - Helpers
- (NSArray *)necessaryFields {
    NSArray *allFields = self.currentScopedStore.allKeys;
    if (self.allFields.count) {
        allFields =
        [allFields filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<NSCopying>evaluatedObject, NSDictionary *bindings) {
            return self.allFields && [self.allFields indexOfObject:evaluatedObject] != NSNotFound;
        }]];
    }
    return allFields;
}

#pragma mark - Instantiation
- (instancetype) initWithOptions:(NSDictionary *)options {
    self = [self init];
    
    _options = options;
    if (options) {
        NSString *scopeName = options[LITLightweightStoreOptionsStoreScopeNameKey];
        
        if (!scopeName) {
            return nil;
        }
        
        _storeScopeName = scopeName;
        
        NSArray *allFields = options[LITLightweightStoreOptionsAllFieldsArrayKey];
        _allFields = allFields;
    }
    
    return self;
}

#pragma mark - Load
- (void) setUp {
    
}

- (void) tearDown {
    
}


#pragma mark - Set/Get
- (void) setField:(NSString *)name byValue:(id)value {
    
}

- (id) fieldByName:(NSString *)name {
    return nil;
}
@end

@interface LITLightweightStoreDefaults : LITLightweightStore
@property (nonatomic, copy, readonly) NSUserDefaults *storeEntity;
@end

@implementation LITLightweightStoreDefaults

- (NSUserDefaults *)storeEntity {
    return [NSUserDefaults standardUserDefaults];
}

- (NSMutableDictionary *)currentScopedStore {
    if (![self.storeEntity dictionaryForKey:self.storeScopeName]) {
        [self.storeEntity setObject:@{} forKey:self.storeScopeName];
        [self.storeEntity synchronize];
    }
    return [[self.storeEntity dictionaryForKey:self.storeScopeName] mutableCopy];
}

- (void) tearDown {
    [self.storeEntity removeObjectForKey:self.storeScopeName];
}

#pragma mark - Set/Get
- (void) setField:(id<NSCopying>)name byValue:(id<NSCopying>)value {
    NSMutableDictionary *dictionary = self.currentScopedStore;
    if (!value) {
        [dictionary removeObjectForKey:name];
    }
    else {
        dictionary[name] = value;
    }
    
    [self.storeEntity setObject:[dictionary copy] forKey:self.storeScopeName];
    [self.storeEntity synchronize];
}

- (id) fieldByName:(id<NSCopying>)name {
    return name ? self.currentScopedStore[name] : nil;
}

@end

@interface LITLightweightStoreKeychain : LITLightweightStore
@property (nonatomic, copy, readonly) UICKeyChainStore *storeEntity;
@end

@implementation LITLightweightStoreKeychain

- (UICKeyChainStore *)storeEntity {
    return [UICKeyChainStore keyChainStoreWithService:self.storeScopeName];
}

- (NSMutableDictionary *)currentScopedStore {
    
    if (![self.storeEntity dataForKey:self.storeScopeName]) {
        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:@{}];
        [self.storeEntity setData:data forKey:self.storeScopeName];
    }
    
    
    NSMutableDictionary * dictionary =
    [[NSKeyedUnarchiver unarchiveObjectWithData:[self.storeEntity dataForKey:self.storeScopeName]] mutableCopy];
    return dictionary;
}

- (void) tearDown {
    NSError * error = nil;
    [self.storeEntity removeItemForKey:self.storeScopeName error:&error];
    if (error) {
        if (self.onError) {
            self.onError(error);
        }
    }
}

#pragma mark - Set/Get
- (void) setField:(id<NSCopying>)name byValue:(id<NSCopying>)value {
    NSMutableDictionary * dictionary = self.currentScopedStore;
    if (!value) {
        [dictionary removeObjectForKey:name];
    }
    else {
        dictionary[name] = value;
    }
    
    NSData * data =
    [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    [self.storeEntity setData:data forKey:self.storeScopeName];
}

- (id) fieldByName:(id<NSCopying>)name {
    return name ? self.currentScopedStore[name] : nil;
}

@end


static NSDictionary *staticDictionaryInMemory = nil;
@interface LITLightweightStoreMemory : LITLightweightStore
@property (nonatomic, copy, readonly) NSMutableDictionary *storeEntity;
@end

@implementation LITLightweightStoreMemory

- (NSDictionary *)storeEntity {
    if (!staticDictionaryInMemory) {
        staticDictionaryInMemory = [[NSMutableDictionary alloc] init];
    }
    return staticDictionaryInMemory;
}

- (NSMutableDictionary *)currentScopedStore {
    if (!self.storeEntity[self.storeScopeName]) {
        self.storeEntity[self.storeScopeName] = [@{} mutableCopy];
    }
    return self.storeEntity[self.storeScopeName];
}

#pragma mark - Load
- (void) setUp {
}

- (void) tearDown {
    for (id<NSCopying> name in self.necessaryFields) {
        [self.currentScopedStore removeObjectForKey:name];
    }
}


#pragma mark - Set/Get
- (void) setField:(id<NSCopying>)name byValue:(id<NSCopying>)value {
    NSMutableDictionary *dictionary = self.currentScopedStore;
    
    if (!value) {
        [dictionary removeObjectForKey:name];
    }
    else {
        dictionary[name] = value;
    }
    
    self.storeEntity[self.storeScopeName] = dictionary;
}

- (id) fieldByName:(id<NSCopying>)name {
    return name ? self.currentScopedStore[name] : nil;
}

@end

@implementation LITLightweightStore (Subscription)

#pragma mark - Subscription
- (id)objectForKeyedSubscript:(id<NSCopying>)key {
    return [self itemForKey:key];
}
- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    [self setItem:obj forKey:key];
}

- (void)setItem:(id)item forKey:(id<NSCopying>)key {
    if (!key) {
        return;
    }
    
    [self setField:key byValue:item];
}

- (id)itemForKey:(id<NSCopying>)key {
    return key ? [self fieldByName:key] : nil;
}

- (void)removeItemForKey:(id<NSCopying>)key {
    if (!key) {
        return;
    }
    
    [self setField:key byValue:nil];
}

@end

@implementation LITLightweightStore (Cluster)

- (LITLightweightStorePolicy) policy {
    LITLightweightStorePolicy policy = nil;
    if (self.class == [LITLightweightStoreDefaults class]) {
        policy = LITLightweightStorePolicyDefaults;
    }
    
    if (self.class == [LITLightweightStoreKeychain class]) {
        policy = LITLightweightStorePolicyKeychain;
    }
    
    if (self.class == [LITLightweightStoreMemory class]) {
        policy = LITLightweightStorePolicyMemory;
    }
    
    return policy;
}

- (BOOL)isEqualToPolicy:(LITLightweightStorePolicy)policy {
    return [self.policy isEqualToString:policy];
}

+ (instancetype) storeWithPolicy:(LITLightweightStorePolicy)policy andOptions:(NSDictionary *)options {
    LITLightweightStore *store = nil;
    
    if (policy == LITLightweightStorePolicyDefaults) {
        store = [[LITLightweightStoreDefaults alloc] initWithOptions:options];
    }
    
    else if (policy == LITLightweightStorePolicyKeychain) {
        store = [[LITLightweightStoreKeychain alloc] initWithOptions:options];
    }
    
    else if (policy == LITLightweightStorePolicyMemory) {
        store = [[LITLightweightStoreMemory alloc] initWithOptions:options];
    }
    
    return store;
}

+ (instancetype) store:(LITLightweightStore*)store switchPolicy:(LITLightweightStorePolicy)policy {
    if ([store isEqualToPolicy:policy]) {
        return store;
    }
    
    LITLightweightStore *newStore = [LITLightweightStore storeWithPolicy:policy andOptions:store.options];
    
    for (id<NSCopying>field in [store necessaryFields]) {
        [newStore setField:field byValue:[store fieldByName:field]];
    }
    
    [store tearDown];
    
    return newStore;
}

- (instancetype) switchPolicy:(LITLightweightStorePolicy)policy {
    return [self.class store:self switchPolicy:policy];
}

@end
