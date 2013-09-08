//
//  MTLogPluginRegister.m
//  MTLogDemo
//
//  Created by Marin Todorov on 8/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "MTLogPluginRegister.h"

@implementation MTLogPluginRegister

-(NSString*)preProcessLogMessage:(NSString *)text env:(NSArray *)env
{
    //register the new plugin
    NSMutableDictionary* regPlugins = env[MTLogRegisteredPlugins];
    Class pluginClass = NSClassFromString(self.args.firstObject);
    if (pluginClass==nil) {
        return [NSString stringWithFormat:@"MTLog: Class '%@' not found", self.args.firstObject];
    }
    regPlugins[self.value] = pluginClass;
    
    //delete self
    NSMutableArray* enabledPlugins = env[MTLogEnabledPlugins];
    [enabledPlugins removeObject: self];
    
    //return the message
    return text;
}

@end
