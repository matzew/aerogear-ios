/*
 * JBoss, Home of Professional Open Source.
 * Copyright Red Hat, Inc., and individual contributors
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
#import <Foundation/Foundation.h>
#import "AGPipe.h"

@interface NSArray (AGPaging)

// a bit ugly....
@property id<AGPipe> pipe;
@property NSDictionary* parameterProvider;

/**
 * Reads the next 'page', based on the current position, of the paging result, from the server.
 *
 * @param success A block object to be executed when the request operation finishes successfully.
 * This block has no return value and takes one argument: The object created from the response
 * data of request.
 *
 * @param failure A block object to be executed when the request operation finishes unsuccessfully,
 * or that finishes successfully, but encountered an error while parsing the resonse data.
 * This block has no return value and takes one argument: The `NSError` object describing
 * the network or parsing error that occurred.
 */
-(void) next:(void (^)(id responseObject))success
     failure:(void (^)(NSError *error))failure;

/**
 * Reads the previous 'page', based on the current position, of the paging result, from the server.
 *
 * @param success A block object to be executed when the request operation finishes successfully.
 * This block has no return value and takes one argument: The object created from the response
 * data of request.
 *
 * @param failure A block object to be executed when the request operation finishes unsuccessfully,
 * or that finishes successfully, but encountered an error while parsing the resonse data.
 * This block has no return value and takes one argument: The `NSError` object describing
 * the network or parsing error that occurred.
 */
-(void) previous:(void (^)(id responseObject))success
         failure:(void (^)(NSError *error))failure;


@end
