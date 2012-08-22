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

#import "AGHttpClientTests.h"
#import "AGHttpClient.h"

@implementation AGHttpClientTests{
    BOOL _finishedFlag;
    AGHttpClient* restClient;
}

-(void)setUp {
    [super setUp];
    // create a shared client for the demo app:
    restClient = [AGHttpClient sharedClientFor:@"http://todo-aerogear.rhcloud.com/todo-server/"];
    restClient.parameterEncoding = AFJSONParameterEncoding;
    
    
    _finishedFlag = NO;
}

-(void)tearDown {
    restClient = nil;
}

// =================================================
// CREATE section
// =================================================
-(void) xtestPostProject {
    // the object, fairly simple...just as a data structure... no object mapping yet..
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    // {"title":"my title","style":"project-232-96-96"}
    [parameters setValue:@"Created from testcase" forKey:@"title"];
    [parameters setValue:@"project-234-255-0" forKey:@"style"];
    
    
    [restClient postPath:@"projects" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Create Project response: %@", responseObject);
        
        
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

// =================================================
// READ section
// =================================================

-(void) xtestGetProjects {
    
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

@end