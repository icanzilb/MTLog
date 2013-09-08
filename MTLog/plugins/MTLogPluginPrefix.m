//
//  MTLogPluginPrefix.m
//  MTLogDemo
//
//  Created by Marin Todorov on 8/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "MTLogPluginPrefix.h"

@implementation MTLogPluginPrefix
{
    BOOL _initialized;
}

-(NSString*)preProcessLogMessage:(NSString *)text env:(NSArray *)env
{
    static NSArray* variables;
    static NSMutableDictionary* counters;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        variables = @[@"$file",@"$class",@"$method", @"$line", @"$counter"];
        counters = [@{} mutableCopy];
    });
    
    //delete other prefix plugins
    if (_initialized == NO) {
        id match;
        for (id plugin in env[MTLogEnabledPlugins]) {
            if ([plugin isKindOfClass:[MTLogPluginPrefix class]]) {
                if (plugin!=self) {
                    match = plugin;
                }
                break;
            }
        }
        if (match) {
            [env[MTLogEnabledPlugins] removeObject: match];
        }
        _initialized = YES;
    }
    
    //apply prefix to message
    if (self.args.count>0 && text.length>0) {
        if ([@"default" isEqualToString: self.args.firstObject]) {
            text = [NSString stringWithFormat:@"%@:%@ > %@",env[MTLogFileName], env[MTLogLineNumber], text];
        } else {
            
            if ([text rangeOfString: @"$counter"].location != NSNotFound) {
                NSString* messageID = [NSString stringWithFormat:@"%@:%@:%@", env[MTLogFileName], env[MTLogMethodName], env[MTLogLineNumber]];
                int count = [counters[messageID] intValue]+1;
                counters[messageID] = @(count);
                text = [text stringByReplacingOccurrencesOfString:@"$counter" withString: [@(count) stringValue]];
            }
            
            NSString* prefix = [self.args.firstObject copy];
            for (int i=0;i<4;i++) {
                prefix = [prefix stringByReplacingOccurrencesOfString:variables[i] withString:[env[i] description]];
            }
            text = [NSString stringWithFormat:@"%@ %@", prefix, text];
        }
    }
    
    return text;
}

-(void)postProcessLogMessage:(NSString *)text env:(NSArray *)env
{
    if (self.args.count==0) {
        [env[MTLogEnabledPlugins] removeObject: self];
    }
}

@end
