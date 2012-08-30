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
    NSURL* dummyURL = [NSURL URLWithString:@"http://server.com/projects/"];
    id<AGPipe> restPipe = [AGRestAdapter pipeForURL:dummyURL];
    STAssertNotNil(restPipe, @"pipe creation");
}

-(void) testPipeTypeProperty {
    NSURL* dummyURL = [NSURL URLWithString:@"http://server.com/projects/"];
    id<AGPipe> restPipe = [AGRestAdapter pipeForURL:dummyURL];
    STAssertNotNil(restPipe, @"pipe creation");
    
    STAssertEqualObjects(@"REST", restPipe.type, @"verifying the (default) type");
}

-(void) testPipeURLProperty {
    NSURL* dummyURL = [NSURL URLWithString:@"http://server.com/projects/"];
    id<AGPipe> restPipe = [AGRestAdapter pipeForURL:dummyURL];
    STAssertNotNil(restPipe, @"pipe creation");
    
    STAssertEqualObjects(@"http://server.com/projects/", restPipe.url, @"verifying the given URL");
}

// Integration tests....
-(void) testReadFromRESTfulPipe {
    
    NSURL* projectURL = [NSURL URLWithString:@"http://todo-aerogear.rhcloud.com/todo-server/projects/"];
    id<AGPipe> projectPipe = [AGRestAdapter pipeForURL:projectURL];
    
    
    [projectPipe read:^(id responseObject) {
        
        NSLog(@"Projects: %@", [responseObject description]);
        _finishedFlag = YES;
        
    } failure:^(NSError *error) {
        
        NSLog(@"Read: An error occured! \n%@", error);
    }];
    
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) testCreateAndDeleteProject {
    NSMutableDictionary* newProject = [NSMutableDictionary dictionary];
    
    // {"title":"my title","style":"project-232-96-96"}
    [newProject setValue:@"Integration Test" forKey:@"title"];
    [newProject setValue:@"project-255-255-255" forKey:@"style"];
    
    NSURL* projectURL = [NSURL URLWithString:@"http://todo-aerogear.rhcloud.com/todo-server/projects/"];
    id<AGPipe> projectPipe = [AGRestAdapter pipeForURL:projectURL];
    
    // stash the id for the created resource;
    __block id resourceId;
    
    [projectPipe save:newProject success:^(id responseObject) {
        
        NSLog(@"Create Response\n%@", [responseObject description]);
        
        resourceId = [responseObject valueForKey:@"id"];

        
        // Once created and we got the response.... let's delete it :-) !!
        [projectPipe remove:resourceId success:^(id responseObject) {
            
            NSLog(@"Delete Response\n%@", [responseObject description]);
            _finishedFlag = YES;
            
        } failure:^(NSError *error) {
            
            NSLog(@"Delete: An error occured! \n%@", error);
        }];
        
    } failure:^(NSError *error) {
        
        NSLog(@"Create: An error occured! \n%@", error);
    }];
    
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) testUpdateProject {
    NSMutableDictionary* newProject = [NSMutableDictionary dictionary];
    
    // {"title":"my title","style":"project-232-96-96"}
    [newProject setValue:@"144" forKey:@"id"];
    [newProject setValue:@"matzew: do NOT delete!" forKey:@"title"];
    [newProject setValue:@"project-255-255-255" forKey:@"style"];
    
    NSURL* projectURL = [NSURL URLWithString:@"http://todo-aerogear.rhcloud.com/todo-server/projects/"];
    id<AGPipe> projectPipe = [AGRestAdapter pipeForURL:projectURL];
    
    
    [projectPipe save:newProject success:^(id responseObject) {
        
        NSLog(@"Update Response\n%@", [responseObject description]);
        _finishedFlag = YES;
        
    } failure:^(NSError *error) {
        
        NSLog(@"Update: An error occured! \n%@", error);
    }];
    
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

@end
