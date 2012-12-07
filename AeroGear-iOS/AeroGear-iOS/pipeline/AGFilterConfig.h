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

#import <Foundation/Foundation.h>
#import "AGConfig.h"

/**
 * Represents the public API to configure filtering.
 */
@protocol AGFilterConfig <AGConfig>

/**
 * Applies the limit to the configuration.
 *
 * @param limit The number of the results returned
 */
-(void) limit:(NSUInteger) limit;
    
/**
 * Applies the offset to the configuration.
 *
 * @param offset The offset in the number of the results
 */
-(void) offset:(NSUInteger) offset;

/**
 * Applies the query to the configuration.
 *
 * @param where The query to be used to filter returned results
 */
-(void) where:(NSDictionary*)where;

@end
