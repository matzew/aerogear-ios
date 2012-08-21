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

#import <Foundation/Foundation.h>

/**
 * AGPipe represents a server connection. An object of this class is responsible to
 * communicate with the server and perfoms read/write operations.
 */
@protocol AGPipe <NSObject>

/**
 * Reads all the data from the underlying server connection. The results are being returned as
 * a dictionary/map, representing the actual JSON response.
 *
 * @return a map, representing the JSON response
 */
-(NSDictionary*) read;

/**
 * Reads all the data that matches a given filter creteria from the underlying server connection.
 * The results are being returned as a dictionary/map, representing the actual JSON response.
 *
 * @param filterObject TODO some filter object..........
 * @return a map, representing the JSON response
 */
-(NSDictionary*) readWithFilter:(id)filterObject;

/**
 * Saves (or updates) a give 'JSON' map on the server;
 *
 * @param object a 'JSON' map, representing the data to save/update
 * @return the created or updated object
 */
-(id) save:(NSDictionary*) object;

/**
 * Removes an object from the underlying server connection. The
 * given key argument is used as the objects ID.
 *
 * @param key (string, integer,...) representing the 'id'
 * @return the removed object
 */
-(id) remove:(id) key;

@end