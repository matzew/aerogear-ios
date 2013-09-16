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

#import <Kiwi/Kiwi.h>
#import "AGSQLiteStatementBuilder.h"

SPEC_BEGIN(AGSQLiteStatementSpec)

describe(@"AGSQLiteStatementBuilder", ^{
    context(@"builds a create statement", ^{

        __block AGSQLiteStatementBuilder *builder = nil;
        __block NSString *createStatement = nil;
        __block NSDictionary *data = nil;
        
        beforeEach(^{
            builder = [AGSQLiteStatementBuilder sharedInstance];
            data = @{@"id" : @"1",
                     @"name" : @"David",
                     @"city" : @"New York",
                     @"salary" : @"1000"};

        });
        
        it(@"should be nil with empty data", ^{
            createStatement = [builder buildCreateStatementWithData:nil forStore:@"myTable" andPrimaryKey:@"id"];
            [createStatement shouldBeNil];
        });

        it(@"with string dictionary should return SQL create statement with text columns ", ^{
            createStatement = [builder buildCreateStatementWithData:data forStore:@"myTable" andPrimaryKey:@"id"];
            [createStatement shouldNotBeNil];
            [[createStatement should] equal:@"create table myTable (name text, id integer primary key asc, salary text, city text);"];
        });
        
        it(@"with mixed type dictionary should return SQL create statement with text columns ", ^{
            data = @{@"id" : @"1",
                     @"name" : @"David",
                     @"city" : @YES,
                     @"salary" : [NSNumber numberWithInt:2100]};
            createStatement = [builder buildCreateStatementWithData:data forStore:@"myTable" andPrimaryKey:@"id"];
            [createStatement shouldNotBeNil];
            [[createStatement should] equal:@"create table myTable (name text, id integer primary key asc, salary text, city text);"];
        });
    });
    
    context(@"builds an insert statement", ^{

        __block AGSQLiteStatementBuilder *builder = nil;
        __block NSString *statement = nil;
        __block NSDictionary *data = nil;
        
        beforeEach(^{
            builder = [AGSQLiteStatementBuilder sharedInstance];
            data = @{@"id" : @"1",
                     @"name" : @"David",
                     @"city" : @"New York",
                     @"salary" : @"1000"};
            
        });
        
        it(@"should be nil with empty data", ^{
            statement = [builder buildInsertStatementWithData:nil forStore:@"myTable" andPrimaryKey:@"id"];
            [statement shouldBeNil];
        });
        
        it(@"with string dictionary should return SQL insert statement with text values ", ^{
            statement = [builder buildInsertStatementWithData:data forStore:@"myTable" andPrimaryKey:@"id"];
            [statement shouldNotBeNil];
            [[statement should] equal:@"insert into myTable values (\"David\", 1, \"1000\", \"New York\");"];
        });
        
        it(@"with mixed type dictionary should return SQL create statement with text values ", ^{
            data = @{@"id" : @"1",
                     @"name" : @"David",
                     @"city" : @YES,
                     @"salary" : [NSNumber numberWithInt:2100]};
            statement = [builder buildInsertStatementWithData:data forStore:@"myTable" andPrimaryKey:@"id"];
            [statement shouldNotBeNil];
            [[statement should] equal:@"insert into myTable values (\"David\", 1, \"2100\", \"1\");"];
        });
    });
    
    context(@"builds an drop statement", ^{
        
        __block AGSQLiteStatementBuilder *builder = nil;
        __block NSString *statement = nil;
        
        beforeEach(^{
            builder = [AGSQLiteStatementBuilder sharedInstance];
        });
        
        it(@"should be nil with empty data", ^{
            statement = [builder buildDropStatementForStore:nil];
            [statement shouldBeNil];
        });
        
        it(@"should have valid SQL syntax", ^{
            statement = [builder buildDropStatementForStore:@"myTable"];
            [statement shouldNotBeNil];
            [[statement should] equal:@"drop table myTable;"];
        });
    });
    
    
    context(@"builds an delete statement", ^{
        
        __block AGSQLiteStatementBuilder *builder = nil;
        __block NSString *statement = nil;
        
        beforeEach(^{
            builder = [AGSQLiteStatementBuilder sharedInstance];
        });
        
        it(@"should be nil with empty data", ^{
            statement = [builder buildDeleteStatementForId:@"1" forStore:nil andPrimaryKey:@"id"];
            [statement shouldBeNil];
        });
        
        it(@"should have valid SQL syntax", ^{
            statement = [builder buildDropStatementForStore:@"myTable"];
            [statement shouldNotBeNil];
            [[statement should] equal:@"drop table myTable;"];
        });
    });
});

SPEC_END