//
//  MTLogPlugin.h
//  ShiftMarket
//
//  Created by Marin Todorov on 7/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MTLogEnvIndexes) {
    MTLogFileName = 0,
    MTLogClassName,
    MTLogMethodName,
    MTLogLineNumber,
    MTLogEnabledPlugins,
    MTLogRegisteredPlugins
};

@interface MTLogPlugin : NSObject

@property (assign, nonatomic) int type;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* value;
@property (strong, nonatomic) NSArray* args;

@property (assign, nonatomic) BOOL affectsFirstLogmessage;

-(instancetype)initWithName:(NSString*)name value:(NSString*)value args:(NSArray*)args;

-(NSString*)pluginID;

-(NSString*)preProcessLogMessage:(NSString*)text env:(NSArray*)env;
-(void)postProcessLogMessage:(NSString*)text env:(NSArray*)env;

@end
