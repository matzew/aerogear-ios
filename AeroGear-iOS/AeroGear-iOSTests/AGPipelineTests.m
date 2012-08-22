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

#import "AGPipelineTests.h"
#import "AGPipeline.h"

@implementation AGPipelineTests
-(void)setUp {
    [super setUp];
    //code
}

-(void)tearDown {
    //code
    [super tearDown];
}

-(void) testCreateDefaultPipeline {
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"tasks" url:nil];
    STAssertNotNil(pipeline, @"pipeline creation");
}

-(void) testCreatePipelineWithType {
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"tasks" url:nil type:@"REST"];
    STAssertNotNil(pipeline, @"pipeline creation");
}

-(void) testCreatePipelineWithInvalidType {
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"tasks" url:nil type:@"OData"];
    STAssertNil(pipeline, @"invalid pipeline creation");
    
}

-(void) testAddNewPipeToPipeline {
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"tasks" url:nil];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> newPipe = [pipeline add:@"projects" url:nil];
    STAssertNotNil(newPipe, @"Added pipe");
}

-(void) testAddNewPipeToPipelineWithType {
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"tasks" url:nil];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> newPipe = [pipeline add:@"projects" url:nil type:@"REST"];
    STAssertNotNil(newPipe, @"Added pipe");
}

-(void) testAddNewPipeToPipelineWithInvalidType {
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"tasks" url:nil];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> newPipe = [pipeline add:@"projects" url:nil type:@"OData"];
    STAssertNil(newPipe, @"Not added pipe");
}

-(void) testGetExistingPipe {
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"tasks" url:nil];
    STAssertNotNil(pipeline, @"pipeline creation");

    id<AGPipe> tasksPipe = [pipeline get:@"tasks"];
    STAssertNotNil(tasksPipe, @"received pipe");
}

-(void) testGetNonExistingPipe {
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"tasks" url:nil];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> tasksPipe = [pipeline get:@"Footasks"];
    STAssertNil(tasksPipe, @"Not received pipe");
}

-(void) testRemoveExistingPipe {
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"tasks" url:nil];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> tasksPipe = [pipeline remove:@"tasks"];
    STAssertNotNil(tasksPipe, @"deleted pipe");
    
    tasksPipe = [pipeline get:@"tasks"];
    STAssertNil(tasksPipe, @"Not received pipe");
}

-(void) testRemoveNonExistingPipe {
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"tasks" url:nil];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> fooPipe = [pipeline remove:@"foo"];
    STAssertNil(fooPipe, @"Not deleted pipe");
}

-(void) testPipeType {
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"tasks" url:nil];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> fooPipe = [pipeline get:@"tasks"];
    
    STAssertEqualObjects(@"REST", fooPipe.type, @"verifying the (default) type");
}

-(void) testPipeURL {
    NSURL* dummyURL = [NSURL URLWithString:@"http://server.com/project"];
    AGPipeline* pipeline = [AGPipeline pipelineWithPipe:@"tasks" url:dummyURL];
    STAssertNotNil(pipeline, @"pipeline creation");
    
    id<AGPipe> fooPipe = [pipeline get:@"tasks"];
    
    STAssertEqualObjects(@"http://server.com/project", fooPipe.url, @"verifying the given URL");
}

@end
