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
    
    AGHttpClient* _restClient;
    NSURL* _baseURL;
}

-(void)setUp {
    [super setUp];
    //_baseURL = [NSURL URLWithString:@"http://localhost:8080/aerogear-controller-demo/"];
    _baseURL = [NSURL URLWithString:@"https://api.github.com/users/matzew/"];
    
    _restClient = [AGHttpClient clientFor:_baseURL];
    _restClient.parameterEncoding = AFJSONParameterEncoding;
    
    _finishedFlag = NO;
}

-(void)tearDown {
    
    [super tearDown];
}


-(void) stestReadWithParams {
    
    AGPipeline *ghPipeline = [AGPipeline pipeline];
    id<AGPipe> gists = [ghPipeline pipe:^(id<AGPipeConfig> config) {
        [config setBaseURL:[NSURL URLWithString:@"https://api.github.com/users/matzew/"]];
        [config setName:@"gists"];
    }];
    
    
    __block NSArray *pagedResultSet;

    [gists readWithParams:@{@"page" : @"2", @"per_page" : @"1"} success:^(id responseObject) {
        
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
        
        //_finishedFlag = YES;
    } failure:^(NSError *error) {
        
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) xtestTwitterPaging {
    
    AGPipeline *ghPipeline = [AGPipeline pipeline];
    id<AGPipe> gists = [ghPipeline pipe:^(id<AGPipeConfig> config) {
        [config setBaseURL:[NSURL URLWithString:@"http://search.twitter.com/"]];
        [config setName:@"search.json"];
        [config setMetadataLocation:@"body"];
    }];
    
    __block NSArray *pagedResultSet;
    
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



-(void) stestReceivingLinkHeader {

    [_restClient getPath:@"gists" parameters:@{@"page" : @"2", @"per_page" : @"1"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *pagingLinks = [NSMutableDictionary dictionary];
        NSArray *links = [[[[operation response] allHeaderFields] valueForKey:@"Link"] componentsSeparatedByString:@","];
        for (NSString *link in links) {
            NSArray *elementsPerLink = [link componentsSeparatedByString:@";"];
            
            NSURL *parsedURL;
            for (NSString *elem in elementsPerLink) {
                // funny TRIN
                NSString *tmpElem = [elem stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                // URL...
                if ([tmpElem hasPrefix:@"<"] && [tmpElem hasSuffix:@">"]) {
                    
                    // TODO.... rel. url... (could use extractQueryArgs)
                    
                    parsedURL = [NSURL URLWithString:[[tmpElem substringFromIndex:1] substringToIndex:tmpElem.length-2]]; //2 because, the first did already cut one char...
                } else if ([tmpElem hasPrefix:@"rel="]) { // only rel...
                    NSString *rel = [[tmpElem substringFromIndex:5] substringToIndex:tmpElem.length-6]; // cutting 5 + the last....
                    [pagingLinks setValue:parsedURL forKey:rel];
                } else {
                    // ignore title etc
                }
            }
        }
     
        NSLog(@"THE links map: \n\n%@\n", pagingLinks);
     
        // TODO... add a category to NSURL that returns the query string as a dictonary.... we ONLY
        // need that.....
     
     
        _finishedFlag = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

// TO BE USED for HEAD and BODY strat.
-(NSDictionary *) extractQueryArgs:(NSString *) value {
    
    NSRange range = [value rangeOfString:@"?"];
    value = [value substringFromIndex:range.location+1];
    // chop the query into a dictionary
    NSArray *components = [value componentsSeparatedByString:@"&"];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    for (NSString *component in components) {
        [parameters setObject:[[component componentsSeparatedByString:@"="] objectAtIndex:1] forKey:[[component componentsSeparatedByString:@"="] objectAtIndex:0]];
    }
    return parameters;
}

-(void) stestTwitterBits {
    
    _baseURL = [NSURL URLWithString:@"http://search.twitter.com/"];
    _restClient = [AGHttpClient clientFor:_baseURL];
    _restClient.parameterEncoding = AFJSONParameterEncoding;
    
    [_restClient getPath:@"search.json" parameters:@{@"q" : @"aerogear", @"page" : @"2", @"rpp" : @"5"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // TODO, read the KEY from config........
        NSString *nextIdentifier = @"next_page";
        NSString *prevIdentifier = @"previous_page";
        
        // buld the MAP of links....:
        NSMutableDictionary *mapOfLink = [NSMutableDictionary dictionary];
        
        [mapOfLink setValue:[self extractQueryArgs:[responseObject valueForKey:nextIdentifier]] forKey:nextIdentifier];
        [mapOfLink setValue:[self extractQueryArgs:[responseObject valueForKey:prevIdentifier]] forKey:prevIdentifier];
        
        
        NSLog(@"THE links map: \n\n%@\n", mapOfLink);
        
        _finishedFlag = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    
}



/**
 * A static shared "pagigng context"; it stores the "AG-...-NEXT" header.
 *
 * It is static, to make sure it is valid between the different test() executions
 */
NSDictionary *pagingState;

-(void) testPagingFiveCars {
    
    _baseURL = [NSURL URLWithString:@"http://localhost:8080/aerogear-controller-demo/"];
    _restClient = [AGHttpClient clientFor:_baseURL];
    _restClient.parameterEncoding = AFJSONParameterEncoding;

    
    // start scrolling......
    pagingState = @{@"offset" : @"0", @"limit" : @"5"};
    
    [_restClient getPath:@"cars" parameters:pagingState success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"\n\n%@\n", responseObject);
        
        
        
        /// genereate the 'next' information.... MOVE to function...., arg is the header.......
        NSString *next = [[[operation response] allHeaderFields] valueForKey:@"AG-Links-Next"];
        NSLog(@"HEADER: %@", next);
        
        
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
    
    // meh:
    _baseURL = [NSURL URLWithString:@"http://localhost:8080/aerogear-controller-demo/"];
    _restClient = [AGHttpClient clientFor:_baseURL];
    _restClient.parameterEncoding = AFJSONParameterEncoding;

    
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

//-(void)testReadWithFilter {
//    AGPipeline *testPipeline = [AGPipeline pipelineWithBaseURL:_baseURL];
//    id<AGPipe> pipe = [testPipeline pipe:^(id<AGPipeConfig> config) {
//        [config setName:@"cars"];
//    }];
//    
//    
//    [pipe readWithFilter:^(id<AGFilterConfig> config) {
//        // hrm...
////        [config setLimit:3];
////        [config setOffset:0];
//        
//    } success:^(id responseObject) {
//        NSLog(@"\n\n -- > %@", [responseObject description]);
//        _finishedFlag = YES;
//    } failure:^(NSError *error) {
//    }];
//    
//    
//    // keep the run loop going
//    while(!_finishedFlag) {
//        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//    }
//}

@end
