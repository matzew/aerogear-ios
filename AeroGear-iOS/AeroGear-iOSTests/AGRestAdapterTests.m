/*
 * JBoss, Home of Professional Open Source.
 * Copyright 2012 Red Hat, Inc., and individual contributors
 * as indicated by the @author tags.
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
#import "AGRestAdapter.h"

@interface AGRestAdapterTests : SenTestCase

@end

@implementation AGRestAdapterTests {
    BOOL _finishedFlag;
}

-(void)setUp {
    [super setUp];
    _finishedFlag = NO;
}

-(void)tearDown {
    //
    [super tearDown];
}

-(void) testCreateRESTfulPipe {
    NSURL* dummyURL = [NSURL URLWithString:@"http://server.com/projects/"];
    id<AGPipe> restPipe = [AGRestAdapter pipeForURL:dummyURL recordId:@"id" authModule:nil];
    STAssertNotNil(restPipe, @"pipe creation");
}

-(void) testPipeTypeProperty {
    NSURL* dummyURL = [NSURL URLWithString:@"http://server.com/projects/"];
    id<AGPipe> restPipe = [AGRestAdapter pipeForURL:dummyURL recordId:@"id" authModule:nil];
    STAssertNotNil(restPipe, @"pipe creation");
    
    STAssertEqualObjects(@"REST", restPipe.type, @"verifying the (default) type");
}

-(void) testPipeURLProperty {
    NSURL* dummyURL = [NSURL URLWithString:@"http://server.com/projects/"];
    id<AGPipe> restPipe = [AGRestAdapter pipeForURL:dummyURL recordId:@"id" authModule:nil];
    STAssertNotNil(restPipe, @"pipe creation");
    
    STAssertEqualObjects(@"http://server.com/projects/", restPipe.url, @"verifying the given URL");
}

-(void) testAccepts {
    STAssertTrue([AGRestAdapter accepts:@"REST"], @"type '%@' should be accepted", @"REST");
    [self assertNotAcceptedType: nil];
    [self assertNotAcceptedType: @"bogus"];
    [self assertNotAcceptedType:[@"REST" lowercaseString]];
}

-(void) assertNotAcceptedType:(NSString*) type {
    STAssertFalse([AGRestAdapter accepts:type], @"type '%@' should not be accepted", type);
}

@end
