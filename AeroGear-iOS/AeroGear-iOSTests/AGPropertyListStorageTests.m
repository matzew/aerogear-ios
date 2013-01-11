/*
 * JBoss, Home of Professional Open Source.
 * Copyright Red Hat, Inc., and individual contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <SenTestingKit/SenTestingKit.h>

#import "AGPropertyListStorage.h"

@interface AGPropertyListStorageTests : SenTestCase

@end

@implementation AGPropertyListStorageTests {
    AGStoreConfiguration* _config;
}

-(void)setUp {
    [super setUp];
    
    // shared configuration
    _config = [[AGStoreConfiguration alloc] init];
    [_config setName:@"pliststore"];
    [_config setRecordId:@"id"];
}

-(void)tearDown {
    [super tearDown];

    // remove all elements from the store
    // so next test starts fresh
    AGPropertyListStorage* plistStore = [AGPropertyListStorage storeWithConfig:_config];
    [plistStore reset:nil failure:nil];
}

-(void) testSaveAndRead{
    NSMutableDictionary* user = [NSMutableDictionary
                                  dictionaryWithObjectsAndKeys:@"Matthias",@"name",@"0",@"id", nil];
    

    AGPropertyListStorage* plistStore;

    // create store
    plistStore = [AGPropertyListStorage storeWithConfig:_config];
    
    // save object
    [plistStore save:user success:^(id object) {
        STAssertNotNil(object, @"object should not be nil");
    } failure:^(NSError *error) {
        STFail(@"save should not fail");
    }];
    
    // reload store
    plistStore = [AGPropertyListStorage storeWithConfig:_config];
    
    // read it
    [plistStore read:@"0" success:^(id object) {
        STAssertEqualObjects(@"Matthias", [object valueForKey:@"name"], @"should be equal");
    } failure:^(NSError *error) {
        STFail(@"read should not fail");
    }];
}

-(void) testSaveAndRemoveAndRead{
    NSMutableDictionary* user = [NSMutableDictionary
                                 dictionaryWithObjectsAndKeys:@"0",@"id", @"Matthias",@"name", nil];
    
    AGPropertyListStorage* plistStore;
    
    plistStore = [AGPropertyListStorage storeWithConfig:_config];

    //save it
    [plistStore save:user success:^(id object) {
        STAssertNotNil(object, @"object should not be nil");
        
    } failure:^(NSError *error) {
        STFail(@"save should not fail");
    }];
    
    // reload store
    plistStore = [AGPropertyListStorage storeWithConfig:_config];

    // read it
    [plistStore read:@"0" success:^(id object) {
        STAssertEqualObjects(@"Matthias", [object valueForKey:@"name"], @"should be equal");
    } failure:^(NSError *error) {
        STFail(@"read should not fail");
    }];
    
    // remove it
    [plistStore remove:@"0" success:^(id object) {
        STAssertNotNil(object, @"object should not be nil");
    } failure:^(NSError *error) {
        STFail(@"remove should not fail");
    }];

     // reload store
     plistStore = [AGPropertyListStorage storeWithConfig:_config];
    
    // read it
    [plistStore read:@"0" success:^(id object) {
        STAssertNil(object, @"object should be nil");
    } failure:^(NSError *error) {
        STFail(@"read should not fail");
    }];
}

-(void) testReset {
    NSMutableDictionary* user1 = [NSMutableDictionary
                                 dictionaryWithObjectsAndKeys:@"0",@"id", @"Matthias",@"name", nil];
    NSMutableDictionary* user2 = [NSMutableDictionary
                                 dictionaryWithObjectsAndKeys:@"1",@"id", @"John",@"name", nil];
    
    
    NSArray* users = [NSArray arrayWithObjects:user1, user2, nil];
    
    AGPropertyListStorage* plistStore;

    plistStore = [AGPropertyListStorage storeWithConfig:_config];
    
    //save objects
    [plistStore save:users success:^(id object) {
        STAssertNotNil(object, @"object should not be nil");
    } failure:^(NSError *error) {
        STFail(@"save should not fail");
    }];
    
    // reload store
    plistStore = [AGPropertyListStorage storeWithConfig:_config];

    // read first object
    [plistStore read:@"0" success:^(id object) {
        STAssertNotNil(object, @"object should not be nil");
    } failure:^(NSError *error) {
        STFail(@"read should not fail");
    }];
    
    // reload store
    plistStore = [AGPropertyListStorage storeWithConfig:_config];

    // read second object
    [plistStore read:@"1" success:^(id object) {
        STAssertNotNil(object, @"object should not be nil");
    } failure:^(NSError *error) {
        STFail(@"read should not fail");
    }];
    
    [plistStore reset:nil
             failure:^(NSError *error) {
                    STFail(@"reset should not fail");
             }
    ];
    
    // reload store
    plistStore = [AGPropertyListStorage storeWithConfig:_config];

    // read first object
    [plistStore read:@"0" success:^(id object) {
        STAssertNil(object, @"object should be nil");
    } failure:^(NSError *error) {
        STFail(@"read should not fail");
    }];
    
    // read second object
    [plistStore read:@"1" success:^(id object) {
        STAssertNil(object, @"object should be nil");
    } failure:^(NSError *error) {
        STFail(@"read should not fail");
    }];
}

-(void)testReadWithEmptyStore {
    AGPropertyListStorage* plistStore;
    
    plistStore = [AGPropertyListStorage storeWithConfig:_config];
    
    [plistStore read:@"0" success:^(id object) {
        STAssertNil(object, @"object should be nil");
    } failure:^(NSError *error) {
        STFail(@"read should not fail");
    }];
}

-(void)testReadAllWithEmptyStore {
    
    AGPropertyListStorage* plistStore;
    
    plistStore = [AGPropertyListStorage storeWithConfig:_config];
    
    [plistStore readAll:^(NSArray *objects) {
        STAssertEquals((NSUInteger)0, [objects count], @"Must be size 0");
    } failure:^(NSError *error) {
        STFail(@"readAll should not fail");
    }];
}

@end
