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
#import "AGRESTPipe.h"
@interface AGRestPipeUnitTests : SenTestCase

@end


@interface AGRESTPipe (Testing)
// exposing private methods on the testing category;
-(NSDictionary *) parseQueryInformation:(NSDictionary *)info;
-(NSDictionary *) parseWebLinkInformation:(NSString *)headerValue;
-(NSDictionary *) transformQueryString:(NSString *) value;
@end


@implementation AGRestPipeUnitTests{
    BOOL _finishedFlag;
    AGRESTPipe *restPipe;
    
    // some mock ups...
    NSDictionary *webLinkingHeaderControllerDefault;
    NSDictionary *customHeadersFromController;
    
    
}

-(void)setUp {
    [super setUp];

    // vanilla default...
    AGPipeConfiguration *cfg = [[AGPipeConfiguration alloc] init];
    restPipe = [AGRESTPipe pipeWithConfig:cfg];

    // some mock ups:
    NSString *prevNextLinks =  @"<http://controllerdemo-danbev.rhcloud.com/aerogear-controller-demo/cars?offset=1&color=red&limit=5>; rel=\"previous\",<http://controllerdemo-danbev.rhcloud.com/aerogear-controller-demo/cars?offset=11&color=red&limit=5>; rel=\"next\"";
    webLinkingHeaderControllerDefault =
    [NSDictionary dictionaryWithObjectsAndKeys:prevNextLinks, @"Link", nil];

    customHeadersFromController = @{
      @"AG-Links-Next" : @"http://controllerdemo-danbev.rhcloud.com/aerogear-controller-demo/cars-custom?offset=11&color=red&limit=5",
      @"AG-Links-Previous" : @"http://controllerdemo-danbev.rhcloud.com/aerogear-controller-demo/cars-custom?offset=1&color=red&limit=5"
    };
}

-(void)tearDown {
    restPipe = nil;
    [super tearDown];
}

// parseQueryInformation

-(void) testParseQueryInformationWithArray {
    NSDictionary *parsedInfo = [restPipe parseQueryInformation:[NSArray array]];
    STAssertNil(parsedInfo, @"Array not supported");
}

-(void) testParseQueryInformationWithNil {
    NSDictionary *parsedInfo = [restPipe parseQueryInformation:nil];
    STAssertNil(parsedInfo, @"nil passed in");
}

-(void) testParseQueryInformationWithString {
    id stringVal = @"bogus";
    NSDictionary *parsedInfo = [restPipe parseQueryInformation:stringVal];
    STAssertNil(parsedInfo, @"String not supported");
}

-(void) testParseQueryInformationWithEmptyDictionary {
    NSDictionary *parsedInfo = [restPipe parseQueryInformation:[NSDictionary dictionary]];
    STAssertNil(parsedInfo, @"empty should be nil");
}

-(void) testParseQueryInformationWithRealLink {
    AGPipeConfiguration *cfg = [[AGPipeConfiguration alloc] init];
    cfg.nextIdentifier = @"AG-Links-Next";
    cfg.previousIdentifier = @"AG-Links-Previous";
    restPipe = [AGRESTPipe pipeWithConfig:cfg];
    
    NSDictionary *parsedInfo = [restPipe parseQueryInformation:customHeadersFromController];
    STAssertTrue(parsedInfo.count == 2, @"should have previous and next link");
}

-(void) testParseQueryInformationWithPrevLink {
    AGPipeConfiguration *cfg = [[AGPipeConfiguration alloc] init];
    cfg.nextIdentifier = @"FOO-Links-Next"; //wrong identifier...
    cfg.previousIdentifier = @"AG-Links-Previous";
    restPipe = [AGRESTPipe pipeWithConfig:cfg];
    
    NSDictionary *parsedInfo = [restPipe parseQueryInformation:customHeadersFromController];
    STAssertTrue(parsedInfo.count == 1, @"should have previous values");
    
    // using internal next key:
    STAssertNil([parsedInfo valueForKey:@"AG-next-key"], @"should not be found, since we looking for a wrong key");
}

-(void) testParseQueryInformationWithNextLink {
    AGPipeConfiguration *cfg = [[AGPipeConfiguration alloc] init];
    cfg.nextIdentifier = @"AG-Links-Next";
    cfg.previousIdentifier = @"FOO-Links-Previous"; // wrong identifier...
    restPipe = [AGRESTPipe pipeWithConfig:cfg];
    
    NSDictionary *parsedInfo = [restPipe parseQueryInformation:customHeadersFromController];
    STAssertTrue(parsedInfo.count == 1, @"should have next values");
    
    // using internal prev key:
    STAssertNil([parsedInfo valueForKey:@"AG-prev-key"], @"should not be found, since we looking for a wrong key");
}

-(void) testParseQueryInformationWithNoLink {
    AGPipeConfiguration *cfg = [[AGPipeConfiguration alloc] init];
    cfg.nextIdentifier = @"FOO-Links-Next";
    cfg.previousIdentifier = @"FOO-Links-Previous";
    restPipe = [AGRESTPipe pipeWithConfig:cfg];
    
    NSDictionary *parsedInfo = [restPipe parseQueryInformation:customHeadersFromController];
    STAssertTrue(parsedInfo.count == 0, @"should have no values");
    
    // using internal next key:
    STAssertNil([parsedInfo valueForKey:@"AG-next-key"], @"should not be found, since we looking for a wrong key");
    STAssertNil([parsedInfo valueForKey:@"AG-prev-key"], @"should not be found, since we looking for a wrong key");
}


// parseWebLinkInformation

-(void) testParseWebLinkInformationWithRealLink {
    NSDictionary *parsedInfo = [restPipe parseWebLinkInformation:[webLinkingHeaderControllerDefault valueForKey:@"Link"]];
    STAssertTrue(parsedInfo.count == 2, @"should have previous and next link");
}

-(void) testParseWebLinkInformationWithPreviousLink {
    
    AGPipeConfiguration *cfg = [[AGPipeConfiguration alloc] init];
    cfg.nextIdentifier = @"ag-foo"; //wrong...
    restPipe = [AGRESTPipe pipeWithConfig:cfg];

    NSDictionary *parsedInfo = [restPipe parseWebLinkInformation:[webLinkingHeaderControllerDefault valueForKey:@"Link"]];
    STAssertTrue(parsedInfo.count == 1, @"should have previous link");
}

-(void) testParseWebLinkInformationWithNextLink {
    AGPipeConfiguration *cfg = [[AGPipeConfiguration alloc] init];
    cfg.previousIdentifier = @"ag-foo"; //wrong...
    restPipe = [AGRESTPipe pipeWithConfig:cfg];

    NSDictionary *parsedInfo = [restPipe parseWebLinkInformation:[webLinkingHeaderControllerDefault valueForKey:@"Link"]];
    STAssertTrue(parsedInfo.count == 1, @"should have next link");
}

-(void) testParseWebLinkInformationWithNoLink {
    AGPipeConfiguration *cfg = [[AGPipeConfiguration alloc] init];
    cfg.nextIdentifier = @"ag-foo"; //wrong...
    cfg.previousIdentifier = @"ag-foo"; //wrong...
    restPipe = [AGRESTPipe pipeWithConfig:cfg];

    NSDictionary *parsedInfo = [restPipe parseWebLinkInformation:[webLinkingHeaderControllerDefault valueForKey:@"Link"]];
    STAssertTrue(parsedInfo.count == 0, @"should have no link");
}

// query parser

-(void) testTransformQueryStringWithNil {
    NSDictionary *parsedQuery = [restPipe transformQueryString:nil];
    STAssertTrue(parsedQuery.count==0, @"empty dictionary");
}

-(void) testTransformQueryStringWithTwoArgs {
    // like from NSURL.query
    NSDictionary *parsedQuery = [restPipe transformQueryString:@"foo=1&bar=2"];
    STAssertTrue(parsedQuery.count==2, @"2 elements");
}

-(void) testTransformQueryStringWithTwoArgsAndResource {
    // returned from the controller
    NSDictionary *parsedQuery = [restPipe transformQueryString:@"cars?foo=1&bar=2"];
    STAssertTrue(parsedQuery.count==2, @"2 elements");
}

-(void) testTransformQueryStringWithTwoArgsAndLeadingQuestionmark {
    // header parasms
    NSDictionary *parsedQuery = [restPipe transformQueryString:@"?foo=1&bar=2"];
    STAssertTrue(parsedQuery.count==2, @"2 elements");
}

@end
