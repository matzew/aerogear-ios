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

/**
 AGPipe represents a server connection. An object of this class is responsible to communicate with the server in order to perform read/write operations.
 

 ## Save data 

 To store newly created objects on a _remote_ server resource you use the ```save``` method. Currently the objects are _just_ simple map objects but in the future we are looking to support more advanced(complex) frameworks, like *Core Data*.

  In the example below, the ```save``` function stores the given NSDictionary on the server, in this case on a RESTful resource. As arguments it accepts simple blocks that are invoked on _success_ or in case of an _failure_.

    // create a dictionary and set some key/value data on it:
    NSMutableDictionary* projectEntity = [NSMutableDictionary dictionary];
    [projectEntity setValue:@"Hello World" forKey:@"title"];
    // add other properties, like style etc ...

    // save the 'new' project:
    [projects save:projectEntity success:^(id responseObject) {
        // LOG the JSON response, returned from the server:
        NSLog(@"CREATE RESPONSE\n%@", [responseObject description]);
        
        // get the id of the new project, from the JSON response...
        id resourceId = [responseObject valueForKey:@"id"];

        // and update the 'object', so that it knows its ID...
        [projectEntity setValue:[resourceId stringValue] forKey:@"id"];
        
    } failure:^(NSError *error) {
        // when an error occurs... at least log it to the console..
        NSLog(@"SAVE: An error occured! \n%@", error);
    }];


 ## Update data

 The ```save``` method is also responsible for updating an 'object'. However this happens **only** when there is an 'id' property/field available:

    // change the title of the previous project 'object':
    [projectEntity setValue:@"Hello Update World!" forKey:@"title"];
    
    // and now update it on the server
    [projects save:projectEntity success:^(id responseObject) {
        // LOG the JSON response, returned from the server:
        NSLog(@"UPDATE RESPONSE\n%@", [responseObject description]);
    } failure:^(NSError *error) {
        // when an error occurs... at least log it to the console..
        NSLog(@"UPDATE: An error occured! \n%@", error);
    }];

 ## Remove data

The AGPipe also contains a ```remove``` method to delete the data on the server. It takes the map object which **must** have an 'id' property/field set, so that it knows which resource to delete:

    // Now, just remove the project:
    [projects remove:projectEntity success:^(id responseObject) {
        // LOG the JSON response, returned from the server:
        NSLog(@"DELETE RESPONSE\n%@", [responseObject description]);
    } failure:^(NSError *error) {
        // when an error occurs... at least log it to the console..
        NSLog(@"DELETE: An error occured! \n%@", error);
    }];

In this case, where we have a RESTful pipe, the API issues an HTTP DELETE request.

  ## Read all data from the server

The ```read``` method allows to (currently) read _all_ data from the server, of the underlying AGPipe:

    [projects read:^(id responseObject) {
        // LOG the JSON response, returned from the server:
        NSLog(@"READ RESPONSE\n%@", [responseObject description]);
    } failure:^(NSError *error) {
        // when an error occurs... at least log it to the console..
        NSLog(@"Read: An error occured! \n%@", error);
    }];

Since we are pointing to a RESTful endpoint, the API issues a HTTP GET request. The JSON output of the above NSLog() call looks like this:

    (
            {
            id = 8;
            style = "project-234-255-0";
            tasks =         (
            );
            title = "Created from testcase";
        },
            {
            id = 15;
            style = "project-255-255-255";
            tasks =         (
            );
            title = "Some title";
        }
    )

Of course the _collection_ behind the responseObject can be stored to a variable..

 ## Upload files
 
 The AGPipe also supports uploading of files. If the map object passed on save method, contain values that are instances of NSURL objects that point to local files, a multipart request will be constructed to perform the uplaoding. Here is an example usage:
 
 // the files to be uploaded
 NSURL *file1 = [[NSBundle mainBundle] URLForResource:@"picture1" withExtension:@"jpg"];
 NSURL *file2 = [[NSBundle mainBundle] URLForResource:@"picture2" withExtension:@"jpg"];
 
 // construct the data to sent with the files added
 NSDictionary *dict = @{@"somekey": @"somevalue", @"jboss.jpg":file1, @"jboss2.jpg":file2 };
 
 // set an (optional) progress block
 [pipe setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
 NSLog(@"Sent bytesWritten=%d totalBytesWritten=%qi of totalBytesExpectedToWrite=%qi bytes", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
 }];
 
 // upload data
 [[pipe save:dict success:^(id responseObject) {
 NSLog(@"Successfully uploaded!");
 
 } failure:^(NSError *error) {
 NSLog(@"An error has occured during upload! \n%@", error);
 }];
 
 Note the 'key' in the dictionary is used as the 'name' field in the multipart request and is required. Further, you don't need to specify the 'Content-type' or the 'filename' fields as they are automatically determined internally by the last path component of the NSURL object passed in. If the mime-type can't be determined an 'application-octet-stream' would be send instead.
 
 
 ## Time out and Cancel pending operations

 ### Timeout
 During construction of the Pipe object, you can optionally specify a timeout interval (default is 60 secs) for an operation to complete. If the time interval is exceeded with no response from the server, then the _failure_ callback is executed with an error code set to _NSURLErrorTimedOut_.

 From the todo example above:

    id<AGPipe> projects = [todo pipe:^(id<AGPipeConfig> config) {
        ... 
        [config setTimeout:20];  // set the time interval to 20 secs
    }];
 
 Note: If you are running on iOS versions < 6 and a timeout occurs on a pipe's _save_ operation, the error code is set to _NSURLErrorCancelled_.

 ### Cancel
 At any time after starting your operations, you can call ```cancel``` on the Pipe object to cancel all running Pipe operations. Doing so will invoke the pipe's _failure_ block with an error code set to  _NSURLErrorCancelled_. You can then check this code in order to perform your 'cancellation' logic .

    [projects read:^(id responseObject) {
        // LOG the JSON response, returned from the server:
        NSLog(@"READ RESPONSE\n%@", [responseObject description]);
    } failure:^(NSError *error) {
        // when an error occurs... at least log it to the console..
        NSLog(@"Read: An error occured! \n%@", error);
    }];

    // cancel the request
    [projects cancel];
 */
@protocol AGPipe <NSObject>

/**
 * Returns the type of the underlying 'pipe implementation'.
 */
@property (nonatomic, readonly) NSString* type;

/**
 * Returns the url string of the underlying 'pipe implementation'.
 */
@property (nonatomic, readonly) NSURL* URL;

/**
 * Reads all the data from the underlying server connection.
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
-(void) read:(void (^)(id responseObject))success
     failure:(void (^)(NSError *error))failure;

/**
 * Read specific object from the underlying server connection.
 *
 * @param value The value of the recordId. See property [AGPipeConfig recordId].
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
-(void) read:(id)value
     success:(void (^)(id responseObject))success
     failure:(void (^)(NSError *error))failure;

/**
 * Reads all the data that matches a given parameter provider from the underlying server connection.
 *
 * @param parameterProvider A dictionary containing all the parameters and their values, that are 
 * passed to the server. If no parameterProvider is given, the defaults from the `AGPipeConfig` 
 * are used.
 *
 * @param success A block object to be executed when the request operation finishes successfully.
 * This block has no return value and takes one argument: The object created from the response
 * data of request.
 *
 * @param failure A block object to be executed when the request operation finishes unsuccessfully,
 * or that finishes successfully, but encountered an error while parsing the response data.
 * This block has no return value and takes one argument: The `NSError` object describing
 * the network or parsing error that occurred.
 */
-(void) readWithParams:(NSDictionary*)parameterProvider
               success:(void (^)(id responseObject))success
               failure:(void (^)(NSError *error))failure;


/**
 * Saves (or updates) a given object from the underlying server connection.
 *
 * @param object a 'JSON' map, representing the data to save/update. If the map contains values
 * of NSURL objects that point to local files, a multipart request will be constructed to upload the
 * files to the server. To track progress of the upload, call [AGPipe setUploadProgressBlock:].
 *
 * @param success A block object to be executed when the request operation finishes successfully.
 * This block has no return value and takes one argument: The object created from the response
 * data of request.
 *
 * @param failure A block object to be executed when the request operation finishes unsuccessfully,
 * or that finishes successfully, but encountered an error while parsing the response data.
 * This block has no return value and takes one argument: The `NSError` object describing
 * the network or parsing error that occurred.
 */
-(void) save:(NSDictionary*) object
     success:(void (^)(id responseObject))success
     failure:(void (^)(NSError *error))failure;

/**
 * Removes an object from the underlying server connection.
 *
 *
 * @param object a 'JSON' map, representing the data to remove. Note the map must have the
 * 'recordId' key set. See property [AGPipeConfig recordId].
 *
 * @param success A block object to be executed when the request operation finishes successfully.
 * This block has no return value and takes one argument: The object created from the response
 * data of request.
 *
 * @param failure A block object to be executed when the request operation finishes unsuccessfully,
 * or that finishes successfully, but encountered an error while parsing the response data.
 * This block has no return value and takes one argument: The `NSError` object describing
 * the network or parsing error that occurred.
 */
-(void) remove:(NSDictionary*) object
       success:(void (^)(id responseObject))success
       failure:(void (^)(NSError *error))failure;

/**
 * Cancel all running pipe operations. Doing so will invoke the pipe's 'failure' block with an error
 * code set to NSURLErrorCancelled so that you can perform your 'cancellation' logic.
 *
 * Note: Calling cancel has no effect on the server, so if you do a save or remove and then
 * call cancel, that action will still take place on the the server.
 *
 */
-(void) cancel;

/**
 * Sets a progress status callback that is invoked during uploading of a file(s).
 *
 * @param block The block accepts three arguments: the number of bytes written in the latest write,
 * the total bytes written for this connection, and the total bytes expected to be written during
 * the request determined by the length of the HTTP body.
 *
 * NOTE. The block can be called several times and is always executed on the main thread.
 */
- (void) setUploadProgressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)) block;

@end