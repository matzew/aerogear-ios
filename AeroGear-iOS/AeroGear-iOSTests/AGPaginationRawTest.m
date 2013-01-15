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
#import "AGHttpClient.h"
#import "AGPipeline.h"

@interface AGPaginationRawTest : SenTestCase

@end

@implementation AGPaginationRawTest{
    BOOL _finishedFlag;
    
    AGHttpClient* _restClient;
}

-(void)setUp {
    [super setUp];
    NSURL* baseURL = [NSURL URLWithString:@"http://controllerdemo-danbev.rhcloud.com/aerogear-controller-demo/"];
    
    _restClient = [AGHttpClient clientFor:baseURL];
    _restClient.parameterEncoding = AFJSONParameterEncoding;
    
    _finishedFlag = NO;
}

-(void)tearDown {
    
    [super tearDown];
}


/**
 * A static shared "pagigng context"; it stores the "AG-...-NEXT" header.
 *
 * It is static, to make sure it is valid between the different test() executions
 */
NSDictionary *pagingState;

-(void) testPagingFiveCars {
    
    // start scrolling......
    pagingState = @{@"offset" : @"1", @"limit" : @"5"};
    
    [_restClient getPath:@"cars" parameters:pagingState success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"\n\n%@\n", responseObject);
        
        
        
        /// genereate the 'next' information.... MOVE to function...., arg is the header.......
        NSString *next = [[[operation response] allHeaderFields] valueForKey:@"AG-Links-Next"];
        // get rid of the resource?
        NSRange range = [next rangeOfString:@"?"];
        next = [next substringFromIndex:range.location+1];
        // chop the query into a dictionary
        NSArray *components = [next componentsSeparatedByString:@"&"];
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        for (NSString *component in components) {
            [parameters setObject:[[component componentsSeparatedByString:@"="] objectAtIndex:1] forKey:[[component componentsSeparatedByString:@"="] objectAtIndex:0]];
        }
        
        // stash the result, to reference it for the 'next' invoke
        pagingState = parameters;
        
        
        _finishedFlag = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) testPagingFiveCarsAndNext {
    
    // now, ..... HERE is the 'next()' invoke...
    
    [_restClient getPath:@"cars" parameters:pagingState success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"\n\n%@\n", responseObject);
        _finishedFlag = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testReadWithFilter {
    AGPipeline *testPipeline = [AGPipeline pipelineWithBaseURL:[NSURL URLWithString:@"http://controllerdemo-danbev.rhcloud.com/aerogear-controller-demo/"]];
    id<AGPipe> pipe = [testPipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"cars"];
    }];
    
    
    [pipe readWithFilter:^(id<AGFilterConfig> config) {
        // hrm...
        [config setLimit:3];
        [config setOffset:0];
        
    } success:^(id responseObject) {
        NSLog(@"\n\n -- > %@", [responseObject description]);
        _finishedFlag = YES;
    } failure:^(NSError *error) {
    }];
    
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

@end
