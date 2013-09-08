//
//  MTLogPlugin.m
//  ShiftMarket
//
//  Created by Marin Todorov on 7/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "MTLogPlugin.h"

@implementation MTLogPlugin

-(instancetype)init
{
    NSAssert(NO, @"Use initWithName:value:args:");
    return nil;
}

-(instancetype)initWithName:(NSString*)name value:(NSString*)value args:(NSArray*)args
{
    self = [super init];
    if (self) {
        self.name = name;
        self.value = value;
        self.args = args;
        self.affectsFirstLogmessage = YES;
    }
    return self;
}

-(NSString*)pluginID
{
    return [NSString stringWithFormat:@"%@:%@:%@", self.name, self.value, [self.args componentsJoinedByString:@","]];
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"%@: %@(%@)", [[self class] description], _value, [_args componentsJoinedByString:@","]];
}

-(NSString*)preProcessLogMessage:(NSString*)text env:(NSArray*)env
{
    return text;
}

-(void)postProcessLogMessage:(NSString*)text env:(NSArray*)env
{
}

@end
