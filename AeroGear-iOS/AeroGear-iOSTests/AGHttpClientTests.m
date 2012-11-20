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
#import "AGHttpClient.h"

#import "AGPipeline.h"

@interface AGHttpClientTests : SenTestCase

@end

@implementation AGHttpClientTests{
    BOOL _finishedFlag;
    AGHttpClient* restClient;
}

-(void)setUp {
    [super setUp];
    // create a shared client for the demo app:
    NSURL* testURL = [NSURL URLWithString:@"http://todo-aerogear.rhcloud.com/todo-server/"];
    restClient = [AGHttpClient clientFor:testURL];
    restClient.parameterEncoding = AFJSONParameterEncoding;
    
    _finishedFlag = NO;
}

-(void)tearDown {
    restClient = nil;
}

// Simple test, that goes to the web to see if the client works
-(void) testGetProjects {
    
    // TODO: use OCMock here in order to NOT require network access.....
    
    [restClient getPath:@"projects" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Projects: %@", responseObject);
        
        
        // signal that the test finished...
        _finishedFlag = YES;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"An error occured! \n%@", error);
        _finishedFlag = YES;
        STFail(@"Error...");
        
    } ];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

// todo: use mocking... perhaps also have this test on the integration test...
-(void) testNSNullValue {
    NSURL* baseURL = [NSURL URLWithString:@"https://todo-aerogear.rhcloud.com/todo-server/"];
    AGPipeline* pipeline = [AGPipeline pipeline:baseURL];
    
    [pipeline pipe:^(id<AGPipeConfig> config) {
        [config name:@"tags"];
        [config type:@"REST"];
    }];
    id<AGPipe> tagsPipe = [pipeline get:@"tags"];
    
    //fake Tag: id + title
    NSDictionary* fakeTag = [NSDictionary dictionaryWithObjectsAndKeys:[NSNull null], @"id", @"Fake TAG", @"title", nil];
    
    [tagsPipe save:fakeTag success:^(id responseObject) {
        _finishedFlag = YES;
    } failure:^(NSError *error) {
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

}



@end