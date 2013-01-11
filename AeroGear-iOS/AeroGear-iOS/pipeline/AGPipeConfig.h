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

#import <Foundation/Foundation.h>
#import "AGConfig.h"
#import "AGAuthenticationModule.h"

/**
 * Represents the public API to configure AGPipe objects.
 */
@protocol AGPipeConfig <AGConfig>

/**
 * Applies the baseURL to the configuration.
 */
@property (strong, nonatomic) NSURL* baseURL;

/**
 * Applies the endpoint to the configuration.
 * If no endpoint is specified, the name will be used as its value.
 */
@property (copy, nonatomic) NSString* endpoint;

/**
 * Applies the recordId to the configuration.
 */
@property (copy, nonatomic) NSString* recordId;

/**
 * Applies the AGAuthenticationModule object to the configuration.
 */
@property (strong, nonatomic) id<AGAuthenticationModule> authModule;

@end
