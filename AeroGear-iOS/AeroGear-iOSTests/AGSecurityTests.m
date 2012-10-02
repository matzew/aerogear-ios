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

#import <SenTestingKit/SenTestingKit.h>
#import "AGHttpClient.h"

@interface AGSecurityTests : SenTestCase

@end

@implementation AGSecurityTests{
    BOOL _finishedFlag;
    AGHttpClient* restClient;
}

-(void) testPotentialSecurityAPI {
    
    NSURL* testURL = [NSURL URLWithString:@"https://todoauth-aerogear.rhcloud.com/todo-server/"];
    restClient = [AGHttpClient clientFor:testURL];
    restClient.parameterEncoding = AFJSONParameterEncoding;
    
    NSDictionary* loginPayload = [NSDictionary dictionaryWithObjectsAndKeys:@"john",@"username",@"123",@"password", nil];
    
    
    [restClient postPath:@"auth/login" parameters:loginPayload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // log the Auth-Token and the Status code:
        NSString* authToken = [[[operation response] allHeaderFields] valueForKey:@"Auth-Token"];
        NSLog(@"\nAuth-Token: %@", authToken);
        NSLog(@"\nStatus Code: %d", [[operation response] statusCode]);

        // set the token.....
        [restClient setDefaultHeader:@"Auth-Token" value:authToken];
        
        // after a successful login, let's request one of the 'service endpoints':
        [restClient getPath:@"projects" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            
            // log the Status code and the GET response...
            NSLog(@"\nStatus Code: %d", [[operation response] statusCode]);
            NSLog(@"\nRESPONSE: %@", [responseObject description]);

            
            // next... let's log out....
            [restClient postPath:@"auth/logout" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                // log the Status code and the GET response...
                NSLog(@"\nStatus Code: %d", [[operation response] statusCode]);
                NSLog(@"\nRESPONSE: %@", [responseObject description]);

                // finally ... signal that the test finished...
                _finishedFlag = YES;
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"\nAn error occured! \n\n%@\n\n", error);
                _finishedFlag = YES;
                //STFail(@"Error...");
                
            }];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"\nAn error occured! \n\n%@\n\n", error);
            _finishedFlag = YES;
            //STFail(@"Error...");
            
        } ];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"\nAn error occured! \n\n%@\n\n", error);
        _finishedFlag = YES;
        //STFail(@"Error...");
        
    } ];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    
}

@end
