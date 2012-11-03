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
//#import "AGPipeline.h"
#import "AeroGear.h"

@interface AGPipelineTests : SenTestCase

@end

@implementation AGPipelineTests {
    // some ivars...
}
-(void)setUp {
    [super setUp];
    //code
}

-(void)tearDown {
    //code
    [super tearDown];
}

-(void) testCreateDefaultPipeline {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    //AGPipeline* pipeline = [AGPipeline pipeline];
    AGPipeline* pipeline = [AGPipeline pipeline:baseURL];
    [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"tasks"];
        [config baseURL:baseURL];
    }];
    STAssertNotNil(pipeline, @"pipeline creation");
}

-(void) testCreatePipelineWithType {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipeline];
    [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"tasks"];
        [config baseURL:baseURL];
        [config type:@"REST"];
    }];

    STAssertNotNil(pipeline, @"pipeline creation");
}

-(void) testCreatePipelineWithInvalidType {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    //AGPipeline* pipeline = [AGPipeline pipeline];
    AGPipeline* pipeline = [AGPipeline pipeline:baseURL];
    [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"tasks"];
        [config baseURL:baseURL];
        [config type:@"OData"];
    }];
    STAssertNil([pipeline get:@"tasks"], @"invalid pipeline creation");
    
}

-(void) testAddNewPipeToPipeline {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipeline];
    [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"tasks"];
        [config baseURL:baseURL];
    }];

    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> newPipe = [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"projects"];
        [config baseURL:baseURL];
    }];
;
    STAssertNotNil(newPipe, @"Added pipe");
}

-(void) testAddNewPipeToPipelineWithType {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipeline];
    [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"tasks"];
        [config baseURL:baseURL];
    }];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> newPipe = [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"projects"];
        [config baseURL:baseURL];
        [config type:@"REST"];
    }];
    STAssertNotNil(newPipe, @"Added pipe");
}

-(void) testAddNewPipeToPipelineWithInvalidType {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipeline];
    [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"tasks"];
        [config baseURL:baseURL];
    }];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> newPipe = [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"projects"];
        [config baseURL:baseURL];
        [config type:@"OData"];
    }];
    STAssertNil(newPipe, @"Not added pipe");
}

-(void) testGetExistingPipe {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipeline];
    [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"tasks"];
        [config baseURL:baseURL];
    }];
    STAssertNotNil(pipeline, @"pipeline creation");

    id<AGPipe> tasksPipe = [pipeline get:@"tasks"];
    STAssertNotNil(tasksPipe, @"received pipe");
}

-(void) testGetNonExistingPipe {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipeline];
    [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"tasks"];
        [config baseURL:baseURL];
    }];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> tasksPipe = [pipeline get:@"Footasks"];
    STAssertNil(tasksPipe, @"Not received pipe");
}

-(void) testRemoveExistingPipe {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipeline];
    [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"tasks"];
        [config baseURL:baseURL];
    }];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> tasksPipe = [pipeline remove:@"tasks"];
    STAssertNotNil(tasksPipe, @"deleted pipe");
    
    tasksPipe = [pipeline get:@"tasks"];
    STAssertNil(tasksPipe, @"Not received pipe");
}

-(void) testRemoveNonExistingPipe {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipeline];
    [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"tasks"];
        [config baseURL:baseURL];
    }];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> fooPipe = [pipeline remove:@"foo"];
    STAssertNil(fooPipe, @"Not deleted pipe");
}

-(void) testPipeDefaultTypeProperty {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipeline];
    [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"tasks"];
        [config baseURL:baseURL];
    }];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> fooPipe = [pipeline get:@"tasks"];
    
    STAssertEqualObjects(@"REST", fooPipe.type, @"verifying the (default) type");
}

-(void) testPipeURLProperty {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipeline];
    [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"tasks"];
        [config baseURL:baseURL];
    }];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> fooPipe = [pipeline get:@"tasks"];
    
    STAssertEqualObjects(@"http://server.com/context/tasks", fooPipe.url, @"verifying the given URL");
}


// some endpoint tests

-(void) testEndpointURL {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipeline];
    [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"bad name"];
        [config baseURL:baseURL];
        [config endpoint:@"projects"];
    }];
    
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> myPipe = [pipeline get:@"bad name"];
    
    STAssertEqualObjects(@"http://server.com/context/projects", myPipe.url, @"verifying the given URL");
}

-(void) testEndpointURLWithType {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipeline];
    [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"bad name"];
        [config baseURL:baseURL];
        [config endpoint:@"projects"];
        [config type:@"REST"];
    }];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> myPipe = [pipeline get:@"bad name"];
    
    STAssertEqualObjects(@"http://server.com/context/projects", myPipe.url, @"verifying the given URL");
}


-(void) testAddPipeWithEndpoint {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipeline];
    [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"projects"];
        [config baseURL:baseURL];
    }];

    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> myPipe = [pipeline get:@"projects"];
    
    STAssertEqualObjects(@"http://server.com/context/projects", myPipe.url, @"verifying the given URL");
    
    
    NSURL* newPipeBaseURL = [NSURL URLWithString:@"http://server.com/otherContext/"];
    [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"bad name"];
        [config baseURL:newPipeBaseURL];
        [config endpoint:@"foo"];
    }];
    
    id<AGPipe> newPipe = [pipeline get:@"bad name"];
    STAssertEqualObjects(@"http://server.com/otherContext/foo", newPipe.url, @"verifying the given URL");
}

-(void) testAddWithRestType {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipeline];
    [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"projects"];
        [config baseURL:baseURL];
    }];

    STAssertNotNil(pipeline, @"pipeline creation");

    [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"foo"];
        [config type:@"REST"];
    }];


    id<AGPipe> newPipe = [pipeline get:@"foo"];
    STAssertEqualObjects(@"REST", newPipe.type, @"verifying the type");
}

-(void) testAddWithEndpointAndRestType {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    //AGPipeline* pipeline = [AGPipeline pipeline];
    AGPipeline* pipeline = [AGPipeline pipeline:baseURL];
    [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"projects"];
        [config baseURL:baseURL];
    }];

    STAssertNotNil(pipeline, @"pipeline creation");

    [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"foo"];
        [config type:@"REST"];
        [config endpoint:@"bar"];
    }];

    id<AGPipe> newPipe = [pipeline get:@"foo"];
    STAssertEqualObjects(@"REST", newPipe.type, @"verifying the type");
    STAssertEqualObjects(@"http://server.com/context/bar", newPipe.url, @"verifying the given URL");
}

-(void) testAddPipeWithoutEndpoint {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipeline];
    [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"projects"];
        [config baseURL:baseURL];
    }];

    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> myPipe = [pipeline get:@"projects"];
    
    STAssertEqualObjects(@"http://server.com/context/projects", myPipe.url, @"verifying the given URL");
    
    
    NSURL* newPipeBaseURL = [NSURL URLWithString:@"http://server.com/otherContext/"];
    [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"foo"];
        [config baseURL:newPipeBaseURL];
    }];
    
    id<AGPipe> newPipe = [pipeline get:@"foo"];
    STAssertEqualObjects(@"http://server.com/otherContext/foo", newPipe.url, @"verifying the given URL");
}

-(void) testAddPipeWithoutEndpointAndWithoutBaseURL {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipeline:baseURL];
    [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"projects"];
        [config baseURL:baseURL];
    }];

    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> myPipe = [pipeline get:@"projects"];
    
    STAssertEqualObjects(@"http://server.com/context/projects", myPipe.url, @"verifying the given URL");
    
    // check default type:
    STAssertEqualObjects(@"REST", myPipe.type, @"has expected REST type");

    
    [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"foo"];
    }];

    
    id<AGPipe> newPipe = [pipeline get:@"foo"];
    STAssertEqualObjects(@"http://server.com/context/foo", newPipe.url, @"verifying the given URL");
}



-(void) testPipeConfigObject {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipeline:baseURL];
    
    [pipeline add:^(id<AGPipeConfig> config) {
        [config name:@"projects"];
        [config type:@"REST"];
    }];
    id<AGPipe> newPipe = [pipeline get:@"projects"];
    STAssertEqualObjects(@"http://server.com/context/projects", newPipe.url, @"verifying the given URL");
}


@end