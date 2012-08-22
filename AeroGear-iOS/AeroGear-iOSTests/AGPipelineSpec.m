//
//  AGPipelineSpec.m
//  AeroGear-iOS
//
//  Created by matzew on 22.08.12.
//  Copyright (c) 2012 JBoss. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "AGPipeline.h"

SPEC_BEGIN(AGPipelineSpec)

describe(@"AGPipeline", ^{
    context(@"when newly created", ^{
        
        //A pipeline object:
        __block id pipeline = nil;

        
        beforeEach(^{
            pipeline = [AGPipeline pipelineWithPipe:@"tests" url:nil];
        });
        
        
        it(@"should not be nil", ^{

            [pipeline shouldNotBeNil];
            
        });
        
    });
});

SPEC_END