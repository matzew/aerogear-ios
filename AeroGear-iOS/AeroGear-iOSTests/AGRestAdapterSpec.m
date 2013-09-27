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

#import <Kiwi/Kiwi.h>
#import "AGRESTPipe.h"
#import "AGHTTPMockHelper.h"

// useful macro to check iOS version
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

SPEC_BEGIN(AGRestAdapterSpec)

describe(@"AGRestAdapter", ^{
    context(@"when newly created", ^{

        __block NSString *PROJECTS = nil;
        __block NSString *PROJECT = nil;

        __block AGRESTPipe* restPipe = nil;
        __block BOOL finishedFlag;
        
        NSInteger const TIMEOUT_ERROR_CODE = SYSTEM_VERSION_LESS_THAN(@"6")? -999: -1001;
       
        beforeAll(^{
            PROJECTS = @"[{\"id\":1,\"title\":\"First Project\",\"style\":\"project-161-58-58\",\"tasks\":[]},{\"id\":                 2,\"title\":\"Second Project\",\"style\":\"project-64-144-230\",\"tasks\":[]}]";
            PROJECT = @"{\"id\":1,\"title\":\"First Project\",\"style\":\"project-161-58-58\",\"tasks\":[]}";
        });
        
        beforeEach(^{
            AGPipeConfiguration* config = [[AGPipeConfiguration alloc] init];
            [config setBaseURL:[NSURL URLWithString:@"http://server.com"]];
            [config setName:@"projects"];

            // Note: we set the timeout(sec) to a low level so that
            // we can test the timeout methods with adjusting response delay
            [config setTimeout:1];
            
            restPipe = [AGRESTPipe pipeWithConfig:config];
        });

        afterEach(^{
            // remove all handlers installed by test methods
            // to avoid any interference
            [AGHTTPMockHelper clearAllMockedRequests];

            finishedFlag = NO;
        });

        it(@"should not be nil", ^{
            [restPipe shouldNotBeNil];
        });
        
        it(@"should have an expected url", ^{
            [[restPipe.URL should] equal:[NSURL URLWithString:@"http://server.com/projects"]];
        });

        it(@"should have an expected type", ^{
            [[restPipe.type should] equal:@"REST"];
        });

        it(@"should successfully read", ^{
            // install the mock:
            [AGHTTPMockHelper mockResponse:[PROJECTS dataUsingEncoding:NSUTF8StringEncoding]];

            [restPipe read:^(id responseObject) {
                [responseObject shouldNotBeNil];
                finishedFlag = YES;

            } failure:^(NSError *error) {
                // nope
            }];

            [[expectFutureValue(theValue(finishedFlag)) shouldEventually] beYes];
        });

        it(@"should successfully save (POST)", ^{
            [AGHTTPMockHelper mockResponse:[PROJECT dataUsingEncoding:NSUTF8StringEncoding]];

            NSMutableDictionary* project = [NSMutableDictionary
                    dictionaryWithObjectsAndKeys:@"First Project", @"title",
                                                 @"project-161-58-58", @"style", nil];

            [restPipe save:project success:^(id responseObject) {
                [responseObject shouldNotBeNil];
                [[[AGHTTPMockHelper lastHTTPMethodCalled] should] equal:@"POST"];
                finishedFlag = YES;

            } failure:^(NSError *error) {
                // nope
            }];

            [[expectFutureValue(theValue(finishedFlag)) shouldEventually] beYes];
        });

        it(@"should successfully save (PUT)", ^{
            [AGHTTPMockHelper mockResponse:[PROJECT dataUsingEncoding:NSUTF8StringEncoding]];

            NSMutableDictionary* project = [NSMutableDictionary
                    dictionaryWithObjectsAndKeys:@"1", @"id", @"First Project", @"title",
                                                 @"project-161-58-58", @"style", nil];

            [restPipe save:project success:^(id responseObject) {
                [responseObject shouldNotBeNil];
                [[[AGHTTPMockHelper lastHTTPMethodCalled] should] equal:@"PUT"];
                finishedFlag = YES;
            } failure:^(NSError *error) {
                // nope
            }];

            [[expectFutureValue(theValue(finishedFlag)) shouldEventually] beYes];
        });

        it(@"should successfully remove (DELETE)", ^{
            [AGHTTPMockHelper mockResponse:[PROJECT dataUsingEncoding:NSUTF8StringEncoding]];

            NSMutableDictionary* project = [NSMutableDictionary
                    dictionaryWithObjectsAndKeys:@"1", @"id", @"First Project", @"title",
                                                 @"project-161-58-58", @"style", nil];


            [restPipe remove:project success:^(id responseObject) {
                [responseObject shouldNotBeNil];
                finishedFlag = YES;

            } failure:^(NSError *error) {
                // nope
            }];

            [[expectFutureValue(theValue(finishedFlag)) shouldEventually] beYes];
        });

        it(@"should honour timeout on save (POST)", ^{
            // here we simulate POST
            // for iOS 5 and iOS 6 the timeout should be honoured correctly
            // regardless of the iOS 5 bug

            // install the mock:
            [AGHTTPMockHelper mockResponseTimeout:[PROJECT dataUsingEncoding:NSUTF8StringEncoding]
                                           status:200
                                     responseTime:2]; // two secs delay
            NSMutableDictionary* project = [NSMutableDictionary
                    dictionaryWithObjectsAndKeys:@"First Project", @"title",
                                                 @"project-161-58-58", @"style", nil];

            [restPipe save:project success:^(id responseObject) {
                // nope

            } failure:^(NSError *error) {
                [[theValue(error.code) should] equal:theValue(TIMEOUT_ERROR_CODE)];
                finishedFlag = YES;
            }];

            [[expectFutureValue(theValue(finishedFlag)) shouldEventuallyBeforeTimingOutAfter(5)] beYes];
        });

        it(@"should honour timeout on save (PUT)", ^{
            [AGHTTPMockHelper mockResponseTimeout:[PROJECT dataUsingEncoding:NSUTF8StringEncoding]
                                           status:200
                                     responseTime:2]; // two secs delay
            NSMutableDictionary* project = [NSMutableDictionary
                    dictionaryWithObjectsAndKeys:@"1", @"id", @"First Project", @"title",
                                                 @"project-161-58-58", @"style", nil];


            [restPipe save:project success:^(id responseObject) {
                // nope
            } failure:^(NSError *error) {
                [[theValue(error.code) should] equal:theValue(TIMEOUT_ERROR_CODE)];
                finishedFlag = YES;
            }];

            [[expectFutureValue(theValue(finishedFlag)) shouldEventuallyBeforeTimingOutAfter(5)] beYes];
        });

        it(@"should read an object with integer argument", ^{
            [AGHTTPMockHelper mockResponse:[PROJECT dataUsingEncoding:NSUTF8StringEncoding]];

            [restPipe read:[NSNumber numberWithInt:1]
                    success:^(id responseObject) {
                        [responseObject shouldNotBeNil];
                        finishedFlag = YES;

                    } failure:^(NSError *error) {
                        // nope
                    }
            ];

            [[expectFutureValue(theValue(finishedFlag)) shouldEventually] beYes];
        });

        it(@"should fail to read an object with nil argument", ^{
            [restPipe read:nil
                    success:^(id responseObject) {
                        // nope
                    } failure:^(NSError *error) {
                        finishedFlag = YES;
                    }
            ];

            [[expectFutureValue(theValue(finishedFlag)) shouldEventually] beYes];
        });

        it(@"should fail to remove an object with nil argument", ^{
            [AGHTTPMockHelper mockResponse:[PROJECT dataUsingEncoding:NSUTF8StringEncoding]];

            [restPipe remove:nil success:^(id responseObject) {
                // nope
            } failure:^(NSError *error) {
                finishedFlag = YES;
            }];

            [[expectFutureValue(theValue(finishedFlag)) shouldEventually] beYes];
        });

        it(@"should accept valid types", ^{
            [[theValue([AGRESTPipe accepts:@"REST"]) should] equal:theValue(YES)];
            // TODO more types as we add
        });

        it(@"should not accept invalid types", ^{
            [[theValue([AGRESTPipe accepts:nil]) should] equal:theValue(NO)];
            [[theValue([AGRESTPipe accepts:@"bogus"]) should] equal:theValue(NO)];
            // REST lowecase should not be accepted
            [[theValue([AGRESTPipe accepts:@"rest"]) should] equal:theValue(NO)];
        });
    });
});

SPEC_END