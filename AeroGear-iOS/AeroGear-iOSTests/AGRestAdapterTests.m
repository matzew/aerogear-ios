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
#import "AGHTTPMockHelper.h"

#import "AGRESTPipe.h"

static NSString *const PROJECTS = @"[{\"id\":1,\"title\":\"First Project\",\"style\":\"project-161-58-58\",\"tasks\":[]},{\"id\":                 2,\"title\":\"Second Project\",\"style\":\"project-64-144-230\",\"tasks\":[]}]";

static NSString *const PROJECT = @"{\"id\":1,\"title\":\"First Project\",\"style\":\"project-161-58-58\",\"tasks\":[]}";

@interface AGRestAdapterTests : SenTestCase

@end

@implementation AGRestAdapterTests {
    BOOL _finishedFlag;
    
    id<AGPipe> _restPipe;
}

-(void)setUp {
    [super setUp];
    
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    
    AGPipeConfiguration* config = [[AGPipeConfiguration alloc] init];
    [config setBaseURL:baseURL];
    [config setName:@"projects"];
    [config setTimeout:1]; // this is just for testing of testSaveWithTimeout
    
    _restPipe = [AGRESTPipe pipeWithConfig:config];
}

-(void)tearDown {
    // remove all handlers installed by test methods
    // to avoid any interference
    [AGHTTPMockHelper clearAllMockedRequests];
    
    [super tearDown];
}

-(void)testCreateRESTfulPipe {
    STAssertNotNil(_restPipe, @"pipe creation");
}

-(void)testPipeTypeProperty {
    STAssertEqualObjects(@"REST", _restPipe.type, @"verifying the (default) type");
}

-(void)testPipeURLProperty {
    STAssertEqualObjects([NSURL URLWithString:@"http://server.com/context/projects"], _restPipe.URL, @"verifying the given URL");
}

-(void)testRead {
    // install the mock:
    [AGHTTPMockHelper mockResponse:[PROJECTS dataUsingEncoding:NSUTF8StringEncoding]];
    
    [_restPipe read:^(id responseObject) {
        STAssertNotNil(responseObject, @"response should not be nil");
        _finishedFlag = YES;
        
    } failure:^(NSError *error) {
        _finishedFlag = YES;
        STFail(@"should not fail");
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testSaveWithTimeout {
    // here we simulate POST
    // for iOS 5 and iOS 6 the timeout should be honoured correctly
    // regardless of the iOS 5 bug
    
    // install the mock:
    [AGHTTPMockHelper mockResponseTimeout:[PROJECT dataUsingEncoding:NSUTF8StringEncoding]
                                   status:200
                             responseTime:2]; // two secs delay
    
    NSMutableDictionary* project = [NSMutableDictionary
                                    dictionaryWithObjectsAndKeys:@"First Project", @"title",
                                    @"project-161-58-58", @"style", nil];
    
    
    [_restPipe save:project success:^(id responseObject) {
        STFail(@"%@", @"should NOT have been called");
        _finishedFlag = YES;
        
    } failure:^(NSError *error) {
        STAssertEquals(-1001, [error code], @"should be equal to code -1001 [request time out]");
        _finishedFlag = YES;
        
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testSaveExistingWithTimeout {
    // here we simulate PUT
    // for iOS 5 and iOS 6 the timeout should be honoured correctly
    // regardless of the iOS 5 bug
    
    [AGHTTPMockHelper mockResponseTimeout:[PROJECT dataUsingEncoding:NSUTF8StringEncoding]
                                   status:200
                             responseTime:2]; // two secs delay
    
    NSMutableDictionary* project = [NSMutableDictionary
                                    dictionaryWithObjectsAndKeys:@"1", @"id", @"First Project", @"title",
                                    @"project-161-58-58", @"style", nil];
    
    
    [_restPipe save:project success:^(id responseObject) {
        STFail(@"%@", @"should NOT have been called");
        _finishedFlag = YES;
        
    } failure:^(NSError *error) {
        STAssertEquals(-1001, [error code], @"should be equal to code -1001 [request time out]");
        _finishedFlag = YES;
        
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testCancel {
    [AGHTTPMockHelper mockResponseTimeout:[PROJECT dataUsingEncoding:NSUTF8StringEncoding]
                                   status:200
                             responseTime:2]; // two secs delay
    
    [_restPipe read:^(id responseObject) {
        STFail(@"success should not have been called");
        _finishedFlag = YES;
        
    } failure:^(NSError *error) {
        STAssertEquals(-999, [error code], @"should be equal to code -999 [request cancelled]");
        _finishedFlag = YES;
    }];
    
    // cancel the request
    [_restPipe cancel];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testReadOneObjectWithStringArgument {
    [AGHTTPMockHelper mockResponse:[PROJECT dataUsingEncoding:NSUTF8StringEncoding]];
    
    [_restPipe read:@"1"
            success:^(id responseObject) {
                STAssertNotNil(responseObject, @"response should not be nil");
                _finishedFlag = YES;
                
            } failure:^(NSError *error) {
                _finishedFlag = YES;
                STFail(@"should not fail");
            }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testReadOneObjectWithIntegerArgument {
    [AGHTTPMockHelper mockResponse:[PROJECT dataUsingEncoding:NSUTF8StringEncoding]];
    
    [_restPipe read:[NSNumber numberWithInt:1]
            success:^(id responseObject) {
                STAssertNotNil(responseObject, @"response should not be nil");
                _finishedFlag = YES;
            } failure:^(NSError *error) {
                _finishedFlag = YES;
                STFail(@"should not fail");
            }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testReadOneObjectWithNil {
    [_restPipe read:nil
            success:^(id responseObject) {
                _finishedFlag = YES;
                STFail(@"should not successed");
                
            } failure:^(NSError *error) {
                _finishedFlag = YES;
            }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testSaveNew {
    [AGHTTPMockHelper mockResponse:[PROJECT dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary* project = [NSMutableDictionary
                                    dictionaryWithObjectsAndKeys:@"First Project", @"title",
                                    @"project-161-58-58", @"style", nil];
    
    [_restPipe save:project success:^(id responseObject) {
        STAssertNotNil(responseObject, @"response should not be nil");
        STAssertEqualObjects(@"POST", [AGHTTPMockHelper lastHTTPMethodCalled], @"POST should have been called");
        _finishedFlag = YES;
        
    } failure:^(NSError *error) {
        _finishedFlag = YES;
        STFail(@"should not fail");
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testSaveExisting {
    [AGHTTPMockHelper mockResponse:[PROJECT dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary* project = [NSMutableDictionary
                                    dictionaryWithObjectsAndKeys:@"1", @"id", @"First Project", @"title",
                                    @"project-161-58-58", @"style", nil];
    
    [_restPipe save:project success:^(id responseObject) {
        STAssertNotNil(responseObject, @"response should not be nil");
        STAssertEqualObjects(@"PUT", [AGHTTPMockHelper lastHTTPMethodCalled], @"PUT should have been called");
        _finishedFlag = YES;
        
    } failure:^(NSError *error) {
        _finishedFlag = YES;
        STFail(@"should not fail");
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testRemove {
    [AGHTTPMockHelper mockResponse:[PROJECT dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary* project = [NSMutableDictionary
                                    dictionaryWithObjectsAndKeys:@"1", @"id", @"First Project", @"title",
                                    @"project-161-58-58", @"style", nil];
    
    
    [_restPipe remove:project success:^(id responseObject) {
        STAssertNotNil(responseObject, @"response should not be nil");
        _finishedFlag = YES;
        
    } failure:^(NSError *error) {
        _finishedFlag = YES;
        STFail(@"should not fail");
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testNSNullValueOnSave {
    [AGHTTPMockHelper mockResponse:[PROJECT dataUsingEncoding:NSUTF8StringEncoding]];
    
    //fake Tag: id + title
    NSDictionary* fakeTag = [NSDictionary dictionaryWithObjectsAndKeys:[NSNull null], @"id", @"Fake TAG", @"title", nil];
    
    [_restPipe save:fakeTag success:^(id responseObject) {
        STAssertNotNil(responseObject, @"response should not be nil");
        _finishedFlag = YES;
        
    } failure:^(NSError *error) {
        _finishedFlag = YES;
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testNSNullValueOnRemove {
    [AGHTTPMockHelper mockResponse:[PROJECT dataUsingEncoding:NSUTF8StringEncoding]];
    
    //fake Tag: id + title
    NSDictionary* fakeTag = [NSDictionary dictionaryWithObjectsAndKeys:[NSNull null], @"id", @"Fake TAG", @"title", nil];
    
    [_restPipe remove:fakeTag success:^(id responseObject) {
        STFail(@"success not expected");
        _finishedFlag = YES;
        
    } failure:^(NSError *error) {
        _finishedFlag = YES;
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testRemoveNilValue {
    [AGHTTPMockHelper mockResponse:[PROJECT dataUsingEncoding:NSUTF8StringEncoding]];
    
    [_restPipe remove:nil success:^(id responseObject) {
        STFail(@"success not expected");
        _finishedFlag = YES;
        
    } failure:^(NSError *error) {
        _finishedFlag = YES;
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testAccepts {
    STAssertTrue([AGRESTPipe accepts:@"REST"], @"type '%@' should be accepted", @"REST");
    [self assertNotAcceptedType: nil];
    [self assertNotAcceptedType: @"bogus"];
    [self assertNotAcceptedType:[@"REST" lowercaseString]];
}

-(void) assertNotAcceptedType:(NSString*) type {
    STAssertFalse([AGRESTPipe accepts:type], @"type '%@' should not be accepted", type);
}

@end