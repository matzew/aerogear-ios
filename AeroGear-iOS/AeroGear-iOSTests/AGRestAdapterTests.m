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

#import "AGRestAdapterTests.h"
#import "AGRestAdapter.h"

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
    NSURL* dummyURL = [NSURL URLWithString:@"http://server.com/project"];
    id<AGPipe> restPipe = [AGRestAdapter pipeForURL:dummyURL];
    STAssertNotNil(restPipe, @"pipe creation");
}

-(void) testPipeTypeProperty {
    NSURL* dummyURL = [NSURL URLWithString:@"http://server.com/project"];
    id<AGPipe> restPipe = [AGRestAdapter pipeForURL:dummyURL];
    STAssertNotNil(restPipe, @"pipe creation");
    
    STAssertEqualObjects(@"REST", restPipe.type, @"verifying the (default) type");
}

-(void) testPipeURLProperty {
    NSURL* dummyURL = [NSURL URLWithString:@"http://server.com/project"];
    id<AGPipe> restPipe = [AGRestAdapter pipeForURL:dummyURL];
    STAssertNotNil(restPipe, @"pipe creation");
    
    STAssertEqualObjects(@"http://server.com/project", restPipe.url, @"verifying the given URL");
}

// Integration tests....
-(void) testReadFromRESTfulPipe {
    
    NSURL* projectURL = [NSURL URLWithString:@"http://todo-aerogear.rhcloud.com/todo-server/projects"];
    id<AGPipe> projectPipe = [AGRestAdapter pipeForURL:projectURL];
    
    
    [projectPipe read:^(id responseObject) {
        
        NSLog(@"Projects: %@", [responseObject description]);
        _finishedFlag = YES;
        
    } failure:^(NSError *error) {
        
        NSLog(@"An error occured! \n%@", error);
    }];
    
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
}




@end
