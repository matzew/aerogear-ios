/*
 * JBoss, Home of Professional Open Source
 * Copyright 2012, Red Hat, Inc., and individual contributors
 * by the @authors tag. See the copyright.txt in the distribution for a
 * full listing of individual contributors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "AGPipeline.h"

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
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"tasks" baseURL:baseURL];
    STAssertNotNil(pipeline, @"pipeline creation");
}

-(void) testCreatePipelineWithType {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"tasks" baseURL:baseURL type:@"REST"];
    STAssertNotNil(pipeline, @"pipeline creation");
}

-(void) testCreatePipelineWithInvalidType {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"tasks" baseURL:baseURL type:@"OData"];
    STAssertNil(pipeline, @"invalid pipeline creation");
    
}

-(void) testAddNewPipeToPipeline {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"tasks" baseURL:baseURL];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> newPipe = [pipeline add:@"projects" baseURL:baseURL];
    STAssertNotNil(newPipe, @"Added pipe");
}

-(void) testAddNewPipeToPipelineWithType {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"tasks" baseURL:baseURL];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> newPipe = [pipeline add:@"projects" baseURL:baseURL type:@"REST"];
    STAssertNotNil(newPipe, @"Added pipe");
}

-(void) testAddNewPipeToPipelineWithInvalidType {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"tasks" baseURL:baseURL];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> newPipe = [pipeline add:@"projects" baseURL:baseURL type:@"OData"];
    STAssertNil(newPipe, @"Not added pipe");
}

-(void) testGetExistingPipe {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"tasks" baseURL:baseURL];
    STAssertNotNil(pipeline, @"pipeline creation");

    id<AGPipe> tasksPipe = [pipeline get:@"tasks"];
    STAssertNotNil(tasksPipe, @"received pipe");
}

-(void) testGetNonExistingPipe {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"tasks" baseURL:baseURL];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> tasksPipe = [pipeline get:@"Footasks"];
    STAssertNil(tasksPipe, @"Not received pipe");
}

-(void) testRemoveExistingPipe {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"tasks" baseURL:baseURL];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> tasksPipe = [pipeline remove:@"tasks"];
    STAssertNotNil(tasksPipe, @"deleted pipe");
    
    tasksPipe = [pipeline get:@"tasks"];
    STAssertNil(tasksPipe, @"Not received pipe");
}

-(void) testRemoveNonExistingPipe {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"tasks" baseURL:baseURL];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> fooPipe = [pipeline remove:@"foo"];
    STAssertNil(fooPipe, @"Not deleted pipe");
}

-(void) testPipeDefaultTypeProperty {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"tasks" baseURL:baseURL];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> fooPipe = [pipeline get:@"tasks"];
    
    STAssertEqualObjects(@"REST", fooPipe.type, @"verifying the (default) type");
}

-(void) testPipeURLProperty {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"tasks" baseURL:baseURL];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> fooPipe = [pipeline get:@"tasks"];
    
    STAssertEqualObjects(@"http://server.com/context/tasks/", fooPipe.url, @"verifying the given URL");
}


// some endpoint tests

-(void) testEndpointURL {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"bad name" baseURL:baseURL endpoint:@"projects"];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> myPipe = [pipeline get:@"bad name"];
    
    STAssertEqualObjects(@"http://server.com/context/projects/", myPipe.url, @"verifying the given URL");
}

-(void) testEndpointURLWithType {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"bad name" baseURL:baseURL endpoint:@"projects" type:@"REST"];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> myPipe = [pipeline get:@"bad name"];
    
    STAssertEqualObjects(@"http://server.com/context/projects/", myPipe.url, @"verifying the given URL");
}


-(void) testAddPipeWithEndpoint {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"projects" baseURL:baseURL];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> myPipe = [pipeline get:@"projects"];
    
    STAssertEqualObjects(@"http://server.com/context/projects/", myPipe.url, @"verifying the given URL");
    
    
    NSURL* newPipeBaseURL = [NSURL URLWithString:@"http://server.com/otherContext/"];
    [pipeline add:@"bad name" baseURL:newPipeBaseURL endpoint:@"foo"];
    
    id<AGPipe> newPipe = [pipeline get:@"bad name"];
    STAssertEqualObjects(@"http://server.com/otherContext/foo/", newPipe.url, @"verifying the given URL");
}

-(void) testAddWithRestType {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"projects" baseURL:baseURL];
    STAssertNotNil(pipeline, @"pipeline creation");

    [pipeline add:@"foo" type:@"REST"];

    id<AGPipe> newPipe = [pipeline get:@"foo"];
    STAssertEqualObjects(@"REST", newPipe.type, @"verifying the type");
}

-(void) testAddWithEndpointAndRestType {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"projects" baseURL:baseURL];
    STAssertNotNil(pipeline, @"pipeline creation");

    [pipeline add:@"foo" endpoint:@"bar" type:@"REST"];

    id<AGPipe> newPipe = [pipeline get:@"foo"];
    STAssertEqualObjects(@"REST", newPipe.type, @"verifying the type");
    STAssertEqualObjects(@"http://server.com/context/bar/", newPipe.url, @"verifying the given URL");
}

-(void) testAddPipeWithoutEndpoint {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"projects" baseURL:baseURL];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> myPipe = [pipeline get:@"projects"];
    
    STAssertEqualObjects(@"http://server.com/context/projects/", myPipe.url, @"verifying the given URL");
    
    
    NSURL* newPipeBaseURL = [NSURL URLWithString:@"http://server.com/otherContext/"];
    [pipeline add:@"foo" baseURL:newPipeBaseURL];
    
    id<AGPipe> newPipe = [pipeline get:@"foo"];
    STAssertEqualObjects(@"http://server.com/otherContext/foo/", newPipe.url, @"verifying the given URL");
}

-(void) testAddPipeWithoutEndpointAndWithoutBaseURL {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"projects" baseURL:baseURL];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> myPipe = [pipeline get:@"projects"];
    
    STAssertEqualObjects(@"http://server.com/context/projects/", myPipe.url, @"verifying the given URL");
    
    [pipeline add:@"foo"];
    
    id<AGPipe> newPipe = [pipeline get:@"foo"];
    STAssertEqualObjects(@"http://server.com/context/foo/", newPipe.url, @"verifying the given URL");
}

@end