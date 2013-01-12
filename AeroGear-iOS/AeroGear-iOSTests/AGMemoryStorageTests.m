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

#import "AGMemoryStorage.h"

@interface AGMemoryStorageTests : SenTestCase

@end

@implementation AGMemoryStorageTests {
    AGMemoryStorage* _memStore;
}

-(void)setUp {
    [super setUp];
    
    AGStoreConfiguration* config = [[AGStoreConfiguration alloc] init];
    [config setRecordId:@"id"];
    
    _memStore = [AGMemoryStorage storeWithConfig:config];
}

-(void)tearDown {
    _memStore = nil;

    [super tearDown];
}

-(void) testMemoryStorageCreation {
    STAssertNotNil(_memStore, @"storage should not be nil");
}

-(void) testSave {
    NSMutableDictionary* user = [NSMutableDictionary
                                  dictionaryWithObjectsAndKeys:@"Robert",@"name",@"0",@"id", nil];
    
    [_memStore save:user success:^(id object) {
        STAssertNotNil(object, @"object should not be nil");
    } failure:^(NSError *error) {
        STFail(@"save should not fail");
    }];
}

-(void) testRead {
    NSMutableDictionary* user = [NSMutableDictionary
                                 dictionaryWithObjectsAndKeys:@"Robert",@"name",@"0",@"id", nil];

    //save it
    [_memStore save:user success:^(id object) {
        STAssertNotNil(object, @"object should not be nil");
        
    } failure:^(NSError *error) {
        STFail(@"save should not fail");
    }];

    // read it
    [_memStore read:@"0" success:^(id object) {
        STAssertEqualObjects(@"Robert", [object valueForKey:@"name"], @"should be equal");
    } failure:^(NSError *error) {
        STFail(@"read should not fail");
    }];
}

-(void) testReadNonExisting {
    NSMutableDictionary* user = [NSMutableDictionary
                                 dictionaryWithObjectsAndKeys:@"Robert",@"name",@"0",@"id", nil];
    
    //save it
    [_memStore save:user success:^(id object) {
        STAssertNotNil(object, @"object should not be nil");
        
    } failure:^(NSError *error) {
        STFail(@"save should not fail");
    }];
    
    // read it
    [_memStore read:@"1" success:^(id object) {
        STAssertNil(object, @"object should be nil");
    } failure:^(NSError *error) {
        STFail(@"read should not fail");
    }];
}

-(void) testRemove {
    NSMutableDictionary* user = [NSMutableDictionary
                                 dictionaryWithObjectsAndKeys:@"0",@"id", @"Robert",@"name", nil];
    
    //save it
    [_memStore save:user success:^(id object) {
        STAssertNotNil(object, @"object should not be nil");
        
    } failure:^(NSError *error) {
        STFail(@"save should not fail");
    }];
    
    // read it
    [_memStore read:@"0" success:^(id object) {
        STAssertEqualObjects(@"Robert", [object valueForKey:@"name"], @"should be equal");
    } failure:^(NSError *error) {
        STFail(@"read should not fail");
    }];
    
    // remove it
    [_memStore remove:@"0" success:^(id object) {
        STAssertNotNil(object, @"object should not be nil");
    } failure:^(NSError *error) {
        STFail(@"remove should not fail");
    }];

    // read it
    [_memStore read:@"0" success:^(id object) {
        STAssertNil(object, @"object should be nil");
    } failure:^(NSError *error) {
        STFail(@"read should not fail");
    }];
}

-(void) testRemoveNonExisting {
    NSMutableDictionary* user = [NSMutableDictionary
                                 dictionaryWithObjectsAndKeys:@"0",@"id", @"Robert",@"name", nil];
    
    //save it
    [_memStore save:user success:^(id object) {
        STAssertNotNil(object, @"object should not be nil");
        
    } failure:^(NSError *error) {
        STFail(@"save should not fail");
    }];
    
    // read it
    [_memStore read:@"0" success:^(id object) {
        STAssertEqualObjects(@"Robert", [object valueForKey:@"name"], @"should be equal");
    } failure:^(NSError *error) {
        STFail(@"read should not fail");
    }];
    
    // remove non existant
    [_memStore remove:@"1" success:^(id object) {
        STAssertNil(object, @"object should be nil");
    } failure:^(NSError *error) {
        STFail(@"remove should not fail");
    }];
    
    // read it
    [_memStore read:@"0" success:^(id object) {
        STAssertNotNil(object, @"object should not be nil");
    } failure:^(NSError *error) {
        STFail(@"read should not fail");
    }];    
}

-(void) testReset {
    NSMutableDictionary* user1 = [NSMutableDictionary
                                 dictionaryWithObjectsAndKeys:@"0",@"id", @"Robert",@"name", nil];
    NSMutableDictionary* user2 = [NSMutableDictionary
                                 dictionaryWithObjectsAndKeys:@"1",@"id", @"John",@"name", nil];
    
    
    NSArray* users = [NSArray arrayWithObjects:user1, user2, nil];
    
    //save objects
    [_memStore save:users success:^(id object) {
        STAssertNotNil(object, @"object should not be nil");
    } failure:^(NSError *error) {
        STFail(@"save should not fail");
    }];
    
    // read first object
    [_memStore read:@"0" success:^(id object) {
        STAssertNotNil(object, @"object should not be nil");
    } failure:^(NSError *error) {
        STFail(@"read should not fail");
    }];
    
    // read second object
    [_memStore read:@"1" success:^(id object) {
        STAssertNotNil(object, @"object should not be nil");
    } failure:^(NSError *error) {
        STFail(@"read should not fail");
    }];
    
    [_memStore reset:nil
             failure:^(NSError *error) {
                    STFail(@"reset should not fail");
             }
    ];
    
    // read first object
    [_memStore read:@"0" success:^(id object) {
        STAssertNil(object, @"object should be nil");
    } failure:^(NSError *error) {
        STFail(@"read should not fail");
    }];
    
    // read second object
    [_memStore read:@"1" success:^(id object) {
        STAssertNil(object, @"object should be nil");
    } failure:^(NSError *error) {
        STFail(@"read should not fail");
    }];
}

-(void) testReadAll {
    NSMutableDictionary* user1 = [NSMutableDictionary
                                  dictionaryWithObjectsAndKeys:@"0",@"id", @"Robert",@"name", nil];
    NSMutableDictionary* user2 = [NSMutableDictionary
                                  dictionaryWithObjectsAndKeys:@"1",@"id", @"John",@"name", nil];
    
    
    NSArray* users = [NSArray arrayWithObjects:user1, user2, nil];
    
    //save objects
    [_memStore save:users success:^(id object) {
        STAssertNotNil(object, @"object should not be nil");
    } failure:^(NSError *error) {
        STFail(@"save should not fail");
    }];
    
    [_memStore readAll:^(NSArray *objects) {
        STAssertEquals((NSUInteger)2, [objects count], @"Must be equal size");

        STAssertTrue([objects containsObject:user1], @"store should contain object");
        STAssertTrue([objects containsObject:user2], @"store should contain object");
        
    } failure:^(NSError *error) {
        STFail(@"readAll should not fail");
    }];
}

-(void)testReadWithEmptyStore {
    [_memStore read:@"0" success:^(id object) {
        STAssertNil(object, @"object should be nil");
    } failure:^(NSError *error) {
        STFail(@"read should not fail");
    }];
}

-(void)testReadAllWithEmptyStore {
    [_memStore readAll:^(NSArray *objects) {
        STAssertEquals((NSUInteger)0, [objects count], @"Must be size 0");
    } failure:^(NSError *error) {
        STFail(@"readAll should not fail");
    }];
}

@end
