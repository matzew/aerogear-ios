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

#import <Kiwi/Kiwi.h>
#import "AGPipeline.h"
#import "AGPipe.h"

SPEC_BEGIN(AGPipeSpec)

describe(@"AGPipe", ^{
    context(@"when newly created", ^{
        
        //A pipeline object:
        __block id pipeline = nil;
        
        
        beforeEach(^{
            NSURL* baseURL = [NSURL URLWithString:@"http://server.com/"];
            //pipeline = [AGPipeline pipeline];
            pipeline = [AGPipeline pipeline:baseURL];
            [pipeline add:^(id<AGPipeConfig> config) {
                [config name:@"tests"];
                [config baseURL:baseURL];
            }];

        });

        it(@"AGPipe should have an expected URL", ^{
            
            id<AGPipe> pipe = [pipeline get:@"tests"];
            [[theValue(pipe.url) shouldNot] equal:nil];
            // does it match ?
            [[pipe.url should] equal:@"http://server.com/tests"];
        });
        
        it(@"AGPipeline should allow add a new AGPipe object", ^{
            
            [pipeline add:^(id<AGPipeConfig> config) {
                [config name:@"tasks"];
            }];

            
            id<AGPipe> newPipe = [pipeline get:@"tasks"];
            NSLog(@"%@", newPipe);
            NSLog(@"%@", newPipe.url);
            
            
            [[theValue(newPipe.url) shouldNot] equal:nil];
            [[newPipe.url should] equal:@"http://server.com/tasks"];
        });

        it(@"AGPipeline should allow add a new AGPipe object with an endpoint ", ^{
            
            [pipeline add:^(id<AGPipeConfig> config) {
                [config name:@"tasks"];
                [config endpoint:@"mytasks"];
            }];

            
            id<AGPipe> newPipe = [pipeline get:@"tasks"];
            [[theValue(newPipe.url) shouldNot] equal:nil];
            [[newPipe.url should] equal:@"http://server.com/mytasks"];
        });

        it(@"AGPipeline should allow add a new AGPipe object with an endpoint and a (known) type", ^{
            
            [pipeline add:^(id<AGPipeConfig> config) {
                [config name:@"tasks"];
                [config type:@"REST"];
                [config endpoint:@"mytasks"];
            }];

            
            id<AGPipe> newPipe = [pipeline get:@"tasks"];
            [[theValue(newPipe.url) shouldNot] equal:nil];
            [[newPipe.url should] equal:@"http://server.com/mytasks"];
        });

        it(@"AGPipeline should allow add a new AGPipe object with a (known) type", ^{
            
            [pipeline add:^(id<AGPipeConfig> config) {
                [config name:@"tasks"];
                [config type:@"REST"];
            }];

            
            id<AGPipe> newPipe = [pipeline get:@"tasks"];
            [[theValue(newPipe.url) shouldNot] equal:nil];
            [[newPipe.url should] equal:@"http://server.com/tasks"];
        });

        it(@"AGPipeline should allow add a new AGPipe object with a different baseURL", ^{
            
            NSURL* newBaseURL = [NSURL URLWithString:@"http://blah.com/context"];
            [pipeline add:^(id<AGPipeConfig> config) {
                [config name:@"tasks"];
                [config baseURL:newBaseURL];
            }];
            
            
            id<AGPipe> newPipe = [pipeline get:@"tasks"];
            [[theValue(newPipe.url) shouldNot] equal:nil];
            [[newPipe.url should] equal:@"http://blah.com/context/tasks"];
        });
        
        it(@"AGPipeline should allow add a new AGPipe object with a different baseURL and an endpoint", ^{
            
            NSURL* newBaseURL = [NSURL URLWithString:@"http://blah.com/context"];
            [pipeline add:^(id<AGPipeConfig> config) {
                [config name:@"tasks"];
                [config baseURL:newBaseURL];
                [config endpoint:@"myTasks"];
            }];

            id<AGPipe> newPipe = [pipeline get:@"tasks"];
            [[theValue(newPipe.url) shouldNot] equal:nil];
            [[newPipe.url should] equal:@"http://blah.com/context/myTasks"];
        });
        
        it(@"AGPipeline should allow add a new AGPipe object with a different baseURL and an endpoint and a (known) type", ^{
            
            NSURL* newBaseURL = [NSURL URLWithString:@"http://blah.com/context"];
            [pipeline add:^(id<AGPipeConfig> config) {
                [config name:@"tasks"];
                [config baseURL:newBaseURL];
                [config endpoint:@"myTasks"];
                [config type:@"REST"];
            }];
            
            id<AGPipe> newPipe = [pipeline get:@"tasks"];
            [[theValue(newPipe.url) shouldNot] equal:nil];
            [[newPipe.url should] equal:@"http://blah.com/context/myTasks"];
        });
        
        it(@"AGPipeline should allow add a new AGPipe object with a different baseURL and a (known) type", ^{
            
            NSURL* newBaseURL = [NSURL URLWithString:@"http://blah.com/context"];
            [pipeline add:^(id<AGPipeConfig> config) {
                [config name:@"tasks"];
                [config baseURL:newBaseURL];
                [config type:@"REST"];
            }];
            

            
            id<AGPipe> newPipe = [pipeline get:@"tasks"];
            [[theValue(newPipe.url) shouldNot] equal:nil];
            [[newPipe.url should] equal:@"http://blah.com/context/tasks"];
        });

        it(@"AGPipeline should allow to add multiple AGPipe objects with different baseURLs", ^{
            
            // vanilla
            [pipeline add:^(id<AGPipeConfig> config) {
                [config name:@"tasks"];
            }];
            
            id<AGPipe> newPipe = [pipeline get:@"tasks"];
            [[theValue(newPipe.url) shouldNot] equal:nil];
            
            [[newPipe.url should] equal:@"http://server.com/tasks"];
            
            
            // new pipe, with different baseURL:
            NSURL* newBaseURL = [NSURL URLWithString:@"http://blah.com/context"];
            [pipeline add:^(id<AGPipeConfig> config) {
                [config name:@"projects"];
                [config baseURL:newBaseURL];
            }];

            
            id<AGPipe> otherPipe = [pipeline get:@"projects"];
            [[theValue(otherPipe.url) shouldNot] equal:nil];
            [[otherPipe.url should] equal:@"http://blah.com/context/projects"];
            
            
            // yet another new pipe, with another different baseURL:
            NSURL* secondBaseURL = [NSURL URLWithString:@"http://blah.com/somecontext"];
            [pipeline add:^(id<AGPipeConfig> config) {
                [config name:@"tags"];
                [config baseURL:secondBaseURL];
            }];
            
            id<AGPipe> newestPipe = [pipeline get:@"tags"];
            [[theValue(newestPipe.url) shouldNot] equal:nil];
            [[newestPipe.url should] equal:@"http://blah.com/somecontext/tags"];
            
        });
        
        it(@"AGPipeline should allow to add multiple AGPipe objects with different baseURLs and replace previous ones", ^{
            
            // vanilla
            [pipeline add:^(id<AGPipeConfig> config) {
                [config name:@"tasks"];
            }];
            
            
            id<AGPipe> newPipe = [pipeline get:@"tasks"];
            [[theValue(newPipe.url) shouldNot] equal:nil];
            
            [[newPipe.url should] equal:@"http://server.com/tasks"];
            
            
            // new pipe, with different baseURL:
            NSURL* newBaseURL = [NSURL URLWithString:@"http://blah.com/context"];
            [pipeline add:^(id<AGPipeConfig> config) {
                [config name:@"projects"];
                [config baseURL:newBaseURL];
            }];

            
            id<AGPipe> otherPipe = [pipeline get:@"projects"];
            [[theValue(otherPipe.url) shouldNot] equal:nil];
            [[otherPipe.url should] equal:@"http://blah.com/context/projects"];
            
            
            // yet another new pipe, but replace the 'tasks' pipe (even it has a different URL):
            NSURL* secondBaseURL = [NSURL URLWithString:@"http://blah.com/somecontext"];
            [pipeline add:^(id<AGPipeConfig> config) {
                [config name:@"tasks"];
                [config baseURL:secondBaseURL];
                [config endpoint:@"tags"];
            }];

            
            id<AGPipe> newestPipe = [pipeline get:@"tasks"];
            [[theValue(newestPipe.url) shouldNot] equal:nil];
            [[newestPipe.url should] equal:@"http://blah.com/somecontext/tags"];
            
        });
        
    });
});

SPEC_END