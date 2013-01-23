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
#import "AGNSArray+Paging.h"

@interface AGPaginationRawTest : SenTestCase

@end

@implementation AGPaginationRawTest{
    BOOL _finishedFlag;
}

-(void)setUp {
    [super setUp];
    _finishedFlag = NO;
}

-(void)tearDown {
    
    [super tearDown];
}

-(void) testCustomAGControllerHeaders {
    
    AGPipeline *ghPipeline = [AGPipeline pipeline];
    id<AGPipe> cars = [ghPipeline pipe:^(id<AGPipeConfig> config) {
        [config setBaseURL:[NSURL URLWithString:@"http://controllerdemo-danbev.rhcloud.com/aerogear-controller-demo"]];
        [config setName:@"cars-custom"];
        
        [config setParameterProvider:@{@"offset" : @"0", @"color" : @"red", @"limit" : @5}];
        
        [config setNextIdentifier:@"AG-Links-Next"];
        [config setPreviousIdentifier:@"AG-Links-Previous"];
        [config setMetadataLocation:@"header"];
    }];
    
    __block NSMutableArray *pagedResultSet;
    
    [cars readWithParams:nil success:^(id responseObject) {
        
        NSLog(@"\n\n\n1) req: %@\n", responseObject);
        pagedResultSet = responseObject;
        
        [pagedResultSet next:^(id responseObject) {
            NSLog(@"\n\n\n2) req: %@\n", responseObject);
            
            [pagedResultSet previous:^(id responseObject) {
                NSLog(@"\n\n\n3) req: %@\n", responseObject);
                _finishedFlag = YES;
            } failure:^(NSError *error) {
                
            }];
        } failure:^(NSError *error) {
            NSLog(@"\n\n%@\n", error);
        }];
        
        //        _finishedFlag = YES;
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) testAGControllerDefaults {
    
    AGPipeline *ghPipeline = [AGPipeline pipeline];
    id<AGPipe> cars = [ghPipeline pipe:^(id<AGPipeConfig> config) {
        [config setBaseURL:[NSURL URLWithString:@"http://controllerdemo-danbev.rhcloud.com/aerogear-controller-demo"]];
        [config setName:@"cars"];
        
        [config setParameterProvider:@{@"offset" : @"0", @"color" : @"red", @"limit" : @5}];
        
    }];
    
    __block NSMutableArray *pagedResultSet;
    
    [cars readWithParams:nil success:^(id responseObject) {
        
        NSLog(@"\n\n\n1) req: %@\n", responseObject);
        pagedResultSet = responseObject;
        
        [pagedResultSet next:^(id responseObject) {
            NSLog(@"\n\n\n2) req: %@\n", responseObject);
            
            [pagedResultSet previous:^(id responseObject) {
                NSLog(@"\n\n\n3) req: %@\n", responseObject);
                _finishedFlag = YES;
            } failure:^(NSError *error) {
                
            }];
        } failure:^(NSError *error) {
            NSLog(@"\n\n%@\n", error);
        }];
        
        //        _finishedFlag = YES;
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) testGithub {
    
    AGPipeline *ghPipeline = [AGPipeline pipeline];
    id<AGPipe> gists = [ghPipeline pipe:^(id<AGPipeConfig> config) {
        [config setBaseURL:[NSURL URLWithString:@"https://api.github.com/users/matzew/"]];
        [config setName:@"gists"];
        [config setPreviousIdentifier:@"prev"];
    }];
    
    __block NSMutableArray *pagedResultSet;
    
    [gists readWithParams:@{@"page" : @"2", @"per_page" : @"1"} success:^(id responseObject) {
        
        NSLog(@"\n\n\n1) req: %@\n", responseObject);
        pagedResultSet = responseObject;
        
        [pagedResultSet next:^(id responseObject) {
            NSLog(@"\n\n\n2) req: %@\n", responseObject);
            
            [pagedResultSet previous:^(id responseObject) {
                NSLog(@"\n\n\n3) req: %@\n", responseObject);
                _finishedFlag = YES;
            } failure:^(NSError *error) {
                
            }];
        } failure:^(NSError *error) {
            NSLog(@"\n\n%@\n", error);
        }];
        
        //_finishedFlag = YES;
    } failure:^(NSError *error) {
        
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) testTwitterPaging {
    
    AGPipeline *ghPipeline = [AGPipeline pipeline];
    id<AGPipe> gists = [ghPipeline pipe:^(id<AGPipeConfig> config) {
        [config setBaseURL:[NSURL URLWithString:@"http://search.twitter.com/"]];
        [config setName:@"search.json"];
        [config setMetadataLocation:@"body"];
        [config setNextIdentifier:@"next_page"];
        [config setPreviousIdentifier:@"previous_page"];
    }];
    
    __block NSMutableArray *pagedResultSet;
    
    [gists readWithParams:@{@"q" : @"aerogear", @"page" : @"2", @"rpp" : @"1"} success:^(id responseObject) {
        
        NSLog(@"\n\n\n1) req: %@\n", responseObject);
        pagedResultSet = responseObject;
        
        [pagedResultSet next:^(id responseObject) {
            NSLog(@"\n\n\n2) req: %@\n", responseObject);
            
            // hrm... currently... I need to update the reference ....
            pagedResultSet = responseObject;
            [pagedResultSet next:^(id responseObject) {
                NSLog(@"\n\n\n3) req: %@\n", responseObject);
                _finishedFlag = YES;
            } failure:^(NSError *error) {
                
            }];
        } failure:^(NSError *error) {
            NSLog(@"\n\n%@\n", error);
        }];
        
        //        _finishedFlag = YES;
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

@end
