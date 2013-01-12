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

#import <Kiwi/Kiwi.h>
#import "AGMemoryStorage.h"

SPEC_BEGIN(AGMemoryStorageSpec)

describe(@"AGMemoryStorage", ^{
    context(@"when newly created", ^{
        
        //A 'in mempry' storage object:
        __block AGMemoryStorage* memStore = nil;
        
        
        beforeEach(^{
            AGStoreConfiguration* config = [[AGStoreConfiguration alloc] init];
            [config setRecordId:@"id"];
            
            memStore = [AGMemoryStorage storeWithConfig:config];
        });


        it(@"should not be nil", ^{
            [memStore shouldNotBeNil];
        });
        
        it(@"should save a single object ", ^{
            
            NSMutableDictionary* user1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Matthias",@"name",@"0",@"id", nil];
            
            [memStore save:user1 success:^(id object) {
                
                [object shouldNotBeNil];
                
            } failure:nil];
            
            
        });
        
        it(@"should read an object _after_ storing it", ^{
            
            NSMutableDictionary* user1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Matthias",@"name",@"0",@"id", nil];

            // store it
            [memStore save:user1 success:^(id object) {
                [object shouldNotBeNil];
            } failure:nil];

            // read it
            [memStore read:@"0" success:^(id object) {
                [[[object objectForKey:@"name"] should] equal:@"Matthias"];
            } failure:^(NSError *error) {
                // todo
            }];
        });

        it(@"should read an object _after_ storing it (using readAll)", ^{
            
            NSMutableDictionary* user1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Matthias",@"name",@"0815",@"id", nil];
            
            // store it
            [memStore save:user1 success:^(id object) {
                [object shouldNotBeNil];
            } failure:nil];
            
            // read it
            [memStore readAll:^(NSArray *objects) {
                [[objects should] haveCountOf:(NSUInteger)1];
                [[objects should] containObjects:user1, nil];
                
                [[[[objects objectAtIndex:(NSUInteger)0] objectForKey:@"name"] should] equal:@"Matthias"];
                [[[[objects objectAtIndex:(NSUInteger)0] objectForKey:@"id"] should] equal:@"0815"];
                
            } failure:^(NSError *error) {
                
            }];
        });
        
        
        it(@"should read nothing out of an empty store", ^{
            
            [memStore readAll:^(NSArray *objects) {
                [[objects should] beEmpty];
            } failure:^(NSError *error) {
                // todo
            }];
        });
        
        it(@"should read not object out of an empty store", ^{
            
            [memStore read:@"someId" success:^(id object) {
                [object shouldBeNil];
            } failure:^(NSError *error) {
                // todo
            }];
            
        });
        
        it(@"should read and save multiple objects", ^{
            
            NSMutableDictionary* user1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Matthias",@"name",@"123",@"id", nil];
            NSMutableDictionary* user2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"abstractj",@"name",@"456",@"id", nil];
            NSMutableDictionary* user3 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"qmx",@"name",@"5",@"id", nil];
            
            NSArray* users = [NSArray arrayWithObjects:user1, user2, user3, nil];
            
            // store it
            [memStore save:users success:^(id object) {
                [object shouldNotBeNil];
            } failure:nil];
            
            // read it
            [memStore readAll:^(NSArray *objects) {
                [[objects should] haveCountOf:(NSUInteger)3];
                [[objects should] containObjects:user1, nil];
                [[objects should] containObjects:user2, nil];
                [[objects should] containObjects:user3, nil];
            } failure:^(NSError *error) {
                
            }];
        });
        
        it(@"should read nothing after reset", ^{
            
            NSMutableDictionary* user1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Matthias",@"name",@"123",@"id", nil];
            NSMutableDictionary* user2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"abstractj",@"name",@"456",@"id", nil];
            NSMutableDictionary* user3 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"qmx",@"name",@"5",@"id", nil];
            
            NSArray* users = [NSArray arrayWithObjects:user1, user2, user3, nil];
            
            // store it
            [memStore save:users success:^(id object) {
                [object shouldNotBeNil];
            } failure:nil];
            
            // read it
            [memStore readAll:^(NSArray *objects) {
                [[objects should] haveCountOf:(NSUInteger)3];
                [[objects should] containObjects:user1, nil];
                [[objects should] containObjects:user2, nil];
                [[objects should] containObjects:user3, nil];
            } failure:^(NSError *error) {
                
            }];
            
            
            [memStore reset:^{
                // nope...
            } failure:^(NSError *error) {
                // todo..
            }];
            
            
            // read from the empty store...
            [memStore readAll:^(NSArray *objects) {
                [[objects should] haveCountOf:(NSUInteger)0];
            } failure:^(NSError *error) {
                
            }];
        });
        
        it(@"should be able to do bunch of read, save, reset operations", ^{
            
            NSMutableDictionary* user1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Matthias",@"name",@"123",@"id", nil];
            NSMutableDictionary* user2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"abstractj",@"name",@"456",@"id", nil];
            NSMutableDictionary* user3 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"qmx",@"name",@"5",@"id", nil];
            
            NSArray* users = [NSArray arrayWithObjects:user1, user2, user3, nil];
            
            // store it
            [memStore save:users success:^(id object) {
                [object shouldNotBeNil];
            } failure:nil];
            
            // read it
            [memStore readAll:^(NSArray *objects) {
                [[objects should] haveCountOf:(NSUInteger)3];
                [[objects should] containObjects:user1, nil];
                [[objects should] containObjects:user2, nil];
                [[objects should] containObjects:user3, nil];
            } failure:^(NSError *error) {
                
            }];
            
            
            [memStore reset:^{
                // nope...
            } failure:^(NSError *error) {
                // todo..
            }];
            
            
            // read from the empty store...
            [memStore readAll:^(NSArray *objects) {
                [[objects should] haveCountOf:(NSUInteger)0];
            } failure:^(NSError *error) {
                
            }];
            
            
            // store it again...
            [memStore save:users success:^(id object) {
                [object shouldNotBeNil];
            } failure:nil];
            
            // read it again ...
            [memStore readAll:^(NSArray *objects) {
                [[objects should] haveCountOf:(NSUInteger)3];
                [[objects should] containObjects:user1, nil];
                [[objects should] containObjects:user2, nil];
                [[objects should] containObjects:user3, nil];
            } failure:^(NSError *error) {
                
            }];
        });
        
        it(@"should not read a remove object", ^{
            
            NSMutableDictionary* user1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Matthias",@"name",@"0",@"id", nil];
            
            // store it
            [memStore save:user1 success:^(id object) {
                [object shouldNotBeNil];
            } failure:nil];
            
            // read it
            [memStore read:@"0" success:^(id object) {
                [[[object objectForKey:@"name"] should] equal:@"Matthias"];
            } failure:^(NSError *error) {
                // todo
            }];
            
            
            // remove the above user:
            [memStore remove:user1 success:^(id object) {
                [[object should] equal:user1];
            } failure:^(NSError *error) {
                // todo
            }];
            
            // read from the empty store...
            [memStore readAll:^(NSArray *objects) {
                [[objects should] haveCountOf:(NSUInteger)0];
            } failure:^(NSError *error) {
                
            }];
            
        });
        
        it(@"should not remove non-existing object", ^{
            
            NSMutableDictionary* user1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Matthias",@"name",@"0",@"id", nil];
            
            // store it
            [memStore save:user1 success:^(id object) {
                [object shouldNotBeNil];
            } failure:nil];
            
            // read it
            [memStore read:@"0" success:^(id object) {
                [[[object objectForKey:@"name"] should] equal:@"Matthias"];
            } failure:^(NSError *error) {
                // todo
            }];
            
            NSMutableDictionary* user2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Matthias",@"name",@"1",@"id", nil];
            // remove the user with the id '1':
            [memStore remove:user2 success:^(id object) {
                [object shouldBeNil];
            } failure:^(NSError *error) {
                // todo
            }];
            
            // should contain the first object
            [memStore readAll:^(NSArray *objects) {
                [[objects should] haveCountOf:(NSUInteger)1];
            } failure:^(NSError *error) {
                
            }];
            
        });

    });
});

SPEC_END