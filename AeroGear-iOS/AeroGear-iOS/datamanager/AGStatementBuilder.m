//
//  AGStatementBuilder.m
//  AeroGear-iOS
//
//  Created by Corinne Krych on 9/11/13.
//  Copyright (c) 2013 JBoss. All rights reserved.
//

#import "AGStatementBuilder.h"

@implementation AGStatementBuilder

+ (AGStatementBuilder *)sharedInstance {
    static AGStatementBuilder *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

-(NSString *)buildInsertStatementWithData:(NSDictionary *)data forStore:(NSString *)storeName {
    NSMutableString *statement;
    
    if([data count] != 0) {
        statement = [NSMutableString stringWithFormat:@"insert into %@ values (\"", storeName];
    }
    
    NSEnumerator *columnNames = [data keyEnumerator];
    NSString *columnName = nil;
    
    while ((columnName = [columnNames nextObject])) {
        [statement appendFormat:@"%@\", ", data[columnName]];
    }
    
    [statement deleteCharactersInRange:NSMakeRange([statement length]-2, 2)];
    [statement appendFormat:@");"];
    return statement;
}

-(NSString *)buildCreateStatementWithData:(NSDictionary *)data forStore:(NSString *)storeName {
    NSMutableString *statement;
    
    if([data count] != 0) {
        statement = [NSMutableString stringWithFormat:@"create table %@ (", storeName];
    }
    
    NSEnumerator *columnNames = [data keyEnumerator];
    NSString *columnName = nil;
    
    while ((columnName = [columnNames nextObject])) {
        [statement appendFormat:@"%@ text, ", data[columnName]];
    }
    
    [statement deleteCharactersInRange:NSMakeRange([statement length]-2, 2)];
    [statement appendFormat:@");"];
    return statement;
}


@end
