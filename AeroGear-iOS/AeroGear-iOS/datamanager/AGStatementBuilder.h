//
//  AGStatementBuilder.h
//  AeroGear-iOS
//
//  Created by Corinne Krych on 9/11/13.
//  Copyright (c) 2013 JBoss. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGStatementBuilder : NSObject

+ (AGStatementBuilder *)sharedInstance;

-(NSString *) buildInsertStatementWithData:(NSDictionary *)data forStore:(NSString *)storeName;
-(NSString *) buildCreateStatementWithData:(NSDictionary *)data forStore:(NSString *)storeName;

@end
