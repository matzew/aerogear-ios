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

#import <Kiwi/Kiwi.h>
#import "AGPipeline.h"
#import "AGPipe.h"

SPEC_BEGIN(AGPipelineSpec)

describe(@"AGPipeline", ^{
    context(@"when newly created", ^{
        
        //A pipeline object:
        __block id pipeline = nil;

        
        beforeEach(^{
            NSURL* baseURL = [NSURL URLWithString:@"http://server.com/"];
            pipeline = [AGPipeline pipelineWithPipe:@"tests" baseURL:baseURL];
        });
        
        
        it(@"should not be nil", ^{
            [pipeline shouldNotBeNil];
        });

        it(@"should have a pipe", ^{
            id pipe = [pipeline get:@"tests"];
            [[theValue(pipe) shouldNot] equal:nil];
        });
        
        it(@"should have an expected URL", ^{
            
            NSURL* testURL = [NSURL URLWithString:@"http://server.com/tests"];
            
            id<AGPipe> pipe = [pipeline get:@"tests"];
            [[theValue(pipe.url) shouldNot] equal:nil];
            
            // does it match ?
            [[pipe.url should] equal:testURL.absoluteString];
        });
        
    });
});

SPEC_END