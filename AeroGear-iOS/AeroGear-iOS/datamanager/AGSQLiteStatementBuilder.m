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

#import "AGSQLiteStatementBuilder.h"

@implementation AGSQLiteStatementBuilder

+ (AGSQLiteStatementBuilder *)sharedInstance {
    static AGSQLiteStatementBuilder *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

-(NSString *) buildSelectStatementForStore:(NSString *)storeName withPrimaryKey:(NSString *)key andPrimaryKeyValue:(NSString*)value {
    NSString *statement = nil;
    if (key && value) {
        statement =[ NSString stringWithFormat:@"select value from %@ where %@=%@", storeName, key, value];
    } else {
        statement = [NSString stringWithFormat:@"select value from %@", storeName];
    }
    return statement;
}

-(NSString *)buildInsertStatementWithData:(NSDictionary *)data forStore:(NSString *)storeName andPrimaryKey:(NSString *)key {
    NSString *statement = nil;
    
    if([data count] != 0 && storeName != nil && [storeName isKindOfClass:[NSString class]]) {
        NSEnumerator *columnNames = [data keyEnumerator];
        NSString *columnName = nil;
        NSString* primaryKeyValue = nil;
        while ((columnName = [columnNames nextObject])) {
            if([columnName isEqualToString:key]) {
                primaryKeyValue = data[columnName];
            }

        }

        NSError *error = nil;
        NSData* json = [NSJSONSerialization dataWithJSONObject:data
                                        options:NO
                                          error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
        
        statement = [[NSString alloc]initWithString:[[NSString stringWithFormat:@"insert into %@ values ", storeName] stringByAppendingString:[NSString stringWithFormat:@"(%@,'%@')", primaryKeyValue, jsonString]]];
        
    }
    return statement;
}

-(NSString *)buildUpdateStatementWithData:(NSDictionary *)data forStore:(NSString *)storeName andPrimaryKey:(NSString *)key {
    NSString *statement = nil;
    
    if([data count] != 0 && storeName != nil && [storeName isKindOfClass:[NSString class]]) {
        NSEnumerator *columnNames = [data keyEnumerator];
        NSString *columnName = nil;
        NSString* primaryKeyValue = nil;
        while ((columnName = [columnNames nextObject])) {
            if([columnName isEqualToString:key]) {
                primaryKeyValue = data[columnName];
            }
        }
        if (primaryKeyValue == nil) {
            return nil;
        }
        
        NSError *error = nil;
        NSData* json = [NSJSONSerialization dataWithJSONObject:data
                                                       options:NO
                                                         error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
        
        statement = [[NSString alloc]initWithString:[[NSMutableString stringWithFormat:@"update %@ set value = ", storeName] stringByAppendingString:[NSString stringWithFormat:@" '%@' where id = %@", jsonString, primaryKeyValue]]];
        
    }
    return statement;
}

-(NSString *)buildCreateStatementWithData:(NSDictionary *)data forStore:(NSString *)storeName andPrimaryKey:(NSString *)key {
    NSMutableString *statement = nil;
    
    if([data count] != 0 && storeName != nil && [storeName isKindOfClass:[NSString class]]) {
        statement = [NSMutableString stringWithFormat:@"create table %@ (", storeName];
        
        
        NSEnumerator *columnNames = [data keyEnumerator];
        NSString *columnName = nil;
        BOOL primaryKeyFound = NO;
        while ((columnName = [columnNames nextObject])) {
            if([columnName isEqualToString:key]) {
                [statement appendFormat:@"%@ integer primary key asc, ", columnName];
                primaryKeyFound = YES;
            }
        }
        if (!primaryKeyFound) {
           [statement appendFormat:@"%@ integer primary key asc, ", key];
        }
        [statement appendFormat:@"value text, "];
        
        [statement deleteCharactersInRange:NSMakeRange([statement length]- 2, 2)];
        [statement appendFormat:@");"];
    }
    return statement;
}

-(NSString *) buildDropStatementForStore:(NSString *)storeName {
    NSMutableString *statement = nil;
    if(storeName != nil && [storeName isKindOfClass:[NSString class]]) {
        statement = [NSMutableString stringWithFormat:@"drop table %@;", storeName];
    }
    return statement;
}

-(NSString *) buildDeleteStatementForId:(id)record forStore:(NSString *)storeName andPrimaryKey:(NSString *)key {
    NSMutableString *statement = nil;
    
    if(record != nil && storeName != nil && [storeName isKindOfClass:[NSString class]]) {
        statement = [NSMutableString stringWithFormat:@"delete from %@ where %@ = \"%@\"", storeName, key, record];
    }
    return statement;
}

@end
