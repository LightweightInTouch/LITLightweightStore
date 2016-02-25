//
//  LITLightweightStoreTests.m
//  LITLightweightStoreTests
//
//  Created by Lobanov Dmitry on 02/24/2016.
//  Copyright (c) 2016 Lobanov Dmitry. All rights reserved.
//

@import XCTest;
@import LITLightweightStore;

@interface Tests : XCTestCase

@property (nonatomic) NSMutableArray * stores;

@end

@implementation Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    
    [self.stores enumerateObjectsUsingBlock:^(LITLightweightStore * obj, NSUInteger idx, BOOL *stop) {
        [obj tearDown];
    }];
    
    [super tearDown];
    
    
}

- (void)generalTestForPolicy:(LITLightweightStorePolicy)policy {
    NSString *itemProperty = @"item";
    LITLightweightStore *store = [LITLightweightStore storeWithPolicy: LITLightweightStorePolicyKeychain andOptions:@{ LITLightweightStoreOptionsStoreScopeNameKey:@"scope",  LITLightweightStoreOptionsAllFieldsArrayKey:@[itemProperty]}];
    
    // cleanup later
    self.stores[self.stores.count] = store;
    
    XCTAssertThrows([store setField:nil byValue:nil]);
    
    XCTAssertThrows([store setField:nil byValue:@""]);
    
    [store setField:itemProperty byValue:nil];
    
    XCTAssertNil([store fieldByName:itemProperty]);
    
    NSDictionary *testValue = @{@"test" : @"value"};
    
    [store setField:itemProperty byValue:testValue];
    
    XCTAssert([[store fieldByName:itemProperty] isEqualToDictionary:testValue]);
}

- (void)generalTestForSubscriptionAndPolicy:(LITLightweightStorePolicy)policy {
    NSString *itemProperty = @"item";
    LITLightweightStore *store = [LITLightweightStore storeWithPolicy: LITLightweightStorePolicyKeychain andOptions:@{ LITLightweightStoreOptionsStoreScopeNameKey:@"scope",  LITLightweightStoreOptionsAllFieldsArrayKey:@[itemProperty]}];
    
    self.stores[self.stores.count] = store;
    
    // setItem:forKey
    // itemForKey:
    // removeItemForKey:
    {
        // nil key
        // not accepted as tests?
        
        XCTAssertNoThrow([store setItem:nil forKey:nil]);
        
        XCTAssertNoThrow([store setItem:itemProperty forKey:nil]);
        
        // nil value
        [store setItem:nil forKey:itemProperty];
        
        XCTAssertNil([store itemForKey:itemProperty]);
        
        // general value
        NSDictionary *testValue = @{@"test" : @"value"};
        
        [store setItem:testValue forKey:itemProperty];
        
        XCTAssert([[store itemForKey:itemProperty] isEqualToDictionary:testValue]);
        
        // remove item
        [store removeItemForKey:itemProperty];
        
        XCTAssertNil([store itemForKey:itemProperty]);
    }
    
    // subscription
    {
        // nil key
        // not accepted as tests?
        /*
        XCTAssertNoThrow(store[nil] = nil);
        
        XCTAssertNoThrow(store[nil] = itemProperty);
        */
        
        // nil value
        store[itemProperty] = nil;
        
        XCTAssertNil(store[itemProperty]);
        
        // general value
        NSDictionary *testValue = @{@"test" : @"value"};
        
        store[itemProperty] = testValue;
        
        XCTAssert([store[itemProperty] isEqualToDictionary:testValue]);
    }
}

- (void)testAggressiveDataInput:(LITLightweightStorePolicy)policy {
    
    // forgot scope name
    NSString *itemProperty = @"item";
    
    LITLightweightStore *nilStore = [LITLightweightStore storeWithPolicy: LITLightweightStorePolicyKeychain andOptions:@{LITLightweightStoreOptionsAllFieldsArrayKey:@[itemProperty]}];
    
    XCTAssertNil(nilStore);
    
    
    // forgot fields, switching policy should copy all fields
    LITLightweightStore *noFieldsStore = [LITLightweightStore storeWithPolicy:policy andOptions:@{LITLightweightStoreOptionsStoreScopeNameKey:@"aggressive"}];
    
    self.stores[self.stores.count] = noFieldsStore;
    
    XCTAssertNotNil(noFieldsStore);
    
    NSString *fieldName = @"field";
    NSString *value = @"value";
    
    [noFieldsStore setField:fieldName byValue:value];
    
    LITLightweightStorePolicy switchedPolicy = nil;
    
    if ([noFieldsStore isEqualToPolicy:LITLightweightStorePolicyMemory]) {
        switchedPolicy = LITLightweightStorePolicyDefaults;
    }
    
    if ([noFieldsStore isEqualToPolicy:LITLightweightStorePolicyDefaults]) {
        switchedPolicy = LITLightweightStorePolicyKeychain;
    }
    
    if ([noFieldsStore isEqualToPolicy:LITLightweightStorePolicyKeychain]) {
        switchedPolicy = LITLightweightStorePolicyMemory;
    }
    
    LITLightweightStore *switchedStore = [noFieldsStore switchPolicy:switchedPolicy];
    
    XCTAssertNotNil(switchedStore);
    
    self.stores[self.stores.count] = switchedStore;
    
    NSLog(@"current scope is: %@", switchedStore.currentScopedStore);
    
    // copy whole information dictionary
    XCTAssert([[switchedStore fieldByName:fieldName] isEqualToString:value]);
}

- (void)testKeychain {
    [self generalTestForPolicy:LITLightweightStorePolicyKeychain];
    [self generalTestForSubscriptionAndPolicy:LITLightweightStorePolicyKeychain];
    [self testAggressiveDataInput:LITLightweightStorePolicyKeychain];
}

- (void)testDefaults {
    [self generalTestForPolicy:LITLightweightStorePolicyDefaults];
    [self generalTestForSubscriptionAndPolicy:LITLightweightStorePolicyDefaults];
    [self testAggressiveDataInput:LITLightweightStorePolicyDefaults];
}

- (void)testMemory {
    [self generalTestForPolicy:LITLightweightStorePolicyMemory];
    [self generalTestForSubscriptionAndPolicy:LITLightweightStorePolicyMemory];
    [self testAggressiveDataInput:LITLightweightStorePolicyMemory];
}

@end

