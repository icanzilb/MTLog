//
//  MTLogPluginRemove.m
//  MTLogDemo
//
//  Created by Marin Todorov on 8/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "MTLogPluginRemove.h"

@implementation MTLogPluginRemove

-(NSString*)preProcessLogMessage:(NSString *)text env:(NSArray *)env
{
    //remove the target plugin
    MTLogPlugin* plugin;
    NSArray* pluginParts = [self.value componentsSeparatedByString:@":"];
    NSString* searchID = [NSString stringWithFormat:@"%@:%@:%@", pluginParts.firstObject, pluginParts.lastObject, [self.args componentsJoinedByString:@","]];
    
    for (plugin in env[MTLogEnabledPlugins]) {
        if ([[plugin pluginID] isEqualToString:searchID]) {
            break;
        }
    }
    [env[MTLogEnabledPlugins] removeObject: plugin];
    
    //remove self
    NSMutableArray* enabledPlugins = env[MTLogEnabledPlugins];
    [enabledPlugins removeObject: self];

    //return the log message
    return text;
}

@end
