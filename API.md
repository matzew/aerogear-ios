AeroGear iOS API - DRAFT 0.1
============================

API Docs are available [here](http://aerogear.github.com/aerogear-ios/)...

The current key entry points are [AGPipeline](http://aerogear.github.com/aerogear-ios/Classes/AGPipeline.html) and [AGPipe](http://aerogear.github.com/aerogear-ios/Protocols/AGPipe.html).

Below is a simple 'Getting started' section on how-to use the API

## Create a pipeline and get access to an underlying pipe

To create a pipeline, you need to use the AGPipeline class. Below is an example: 

    // NSURL object:
    NSURL* projectsURL = [NSURL URLWithString:@"http://todo-aerogear.rhcloud.com/todo-server"];

    // create the 'todo' pipeline, which contains the 'projects' pipe:
    AGPipeline* todo = [AGPipeline pipelineWithPipe:@"projects" url:projectsURL type:@"REST"];


The AGPipeline class offers some simple 'management' APIs to work with containing AGPipe objects, which itself represents a server connection. The AGPipe API is basically an abstraction layer for _any_ server side connection. In the example above the 'projects' pipe points to an RESTful endpoint (_http://todo-aerogear.rhcloud.com/todo-server/projects_). However, technical details like RESTful APIs (e.g. HTTP PUT) are not exposed on the AGPipeline and AGPipe APIs. Below is shown how to get access to an actual pipe:

    // get access to the 'projects' pipe
    id<AGPipe> projects = [todo get:@"projects"];

## Save data 

The AGPipe offers an API to store newly created objects on a _remote_ server resource. CURRENTLY the objects are _just_ simple map objects... In the future we are looking to support more advanced(complex) frameworks, like Core Data. The 'save' method is described below:

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

Above the _save_ function stores the given NSDictionary on the server, in this case on a RESTful resource. As arguments it accepts simple blocks that are invoked on _success_ or in case of an _failure_.

## Update data

The 'save' method (like in aerogear.js) is also responsible for updating an 'object'. However this happens _only_ when there is an 'id' property/field available:

    // change the title of the previous project 'object':
    [projectEntity setValue:@"Hello Update World!" forKey:@"title"];
    
    // and now udpdate it on the server
    [projects save:projectEntity success:^(id responseObject) {
	    // LOG the JSON response, returned from the server:
        NSLog(@"UPDATE RESPONSE\n%@", [responseObject description]);
    } failure:^(NSError *error) {
        // when an error occurs... at least log it to the console..
        NSLog(@"UPDATE: An error occured! \n%@", error);
    }];

## Remove data

The AGPipe also contains a 'remove' method to delete the data on the server. It takes the value of the 'id' property, so that it knows which resource to delete:

    // get the 'id' value:
    id deleteId = [projectEntity objectForKey:@"id"];

    // Now, just remove this project:
    [projects remove:deleteId success:^(id responseObject) {
	    // LOG the JSON response, returned from the server:
	    NSLog(@"DELETE RESPONSE\n%@", [responseObject description]);
    } failure:^(NSError *error) {
        // when an error occurs... at least log it to the console..
        NSLog(@"DELETE: An error occured! \n%@", error);
    }];

In this case, where we have a RESTful pipe the API issues a HTTP DELETE request.

## Read all data from the server

The 'read' method allows to (currently) read _all_ data from the server, of the underlying AGPipe:

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
	        title = "matzew: do NOT delete!";
	    }
	)

Of course the _collection_ behind the responseObject can be stored to a variable...