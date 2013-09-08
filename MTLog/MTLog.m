//
//  MTLog.m
//
//  Created by Marin Todorov on 3/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "MTLog.h"
#import "MTLogPlugin.h"

//load all default plugins
#import "MTLogPluginRegister.h"
#import "MTLogPluginRemove.h"
#import "MTLogPluginFilter.h"
#import "MTLogPluginSearch.h"
#import "MTLogPluginRoute.h"
#import "MTLogPluginPrefix.h"

#pragma mark - MTLog
@implementation MTLog
{
    NSMutableDictionary* _registeredPlugins;
    
    NSMutableArray* _enabledPlugins;
    NSMutableArray* _pendingPlugins;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        //initialize filters
        _registeredPlugins = [@{
                                @"prefix":   [MTLogPluginPrefix class],
                                @"register": [MTLogPluginRegister class],
                                @"filter":   [MTLogPluginFilter class],
                                @"remove":   [MTLogPluginRemove class],
                                @"search":   [MTLogPluginSearch class],
                                @"route":    [MTLogPluginRoute class]
                                } mutableCopy];
        _pendingPlugins = [@[] mutableCopy];
        _enabledPlugins = [@[] mutableCopy];
        
        //set the default prefix
        [_enabledPlugins addObject:
         [[MTLogPluginPrefix alloc] initWithName:@"prefix" value:@"set" args:@[@"default"]]
         ];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)objectAtKeyedSubscript:(id <NSCopying>)key
{
    return [_registeredPlugins objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key
{
    //remove a plugin
    if (obj==nil) {
        [_registeredPlugins removeObjectForKey:key];
        return;
    }
    
    //add a plugin
    _registeredPlugins[key] = obj;
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"MTLog: \n"
            "plugins: %@\n", _enabledPlugins
            ];
}

+(void)log:(NSString*)fileName method:(NSString*)method lineNr:(NSNumber*)lineNr text:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    [[self sharedInstance] log:fileName method:(NSString*)method lineNr:lineNr text:format, args];
    va_end(args);
}

-(NSString*)parseLogMessage:(NSString*)format
{
    __block NSString* result = format;
    
    __block NSString* name = nil;
    __block NSString* value = nil;
    __block NSArray* args = nil;

    //find the filter command
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:@"^_(\\w+):([^\( ]+)(\\((.+?)?\\))?[ ]?"
                                                                      options:kNilOptions
                                                                        error:nil];
    
    [regEx enumerateMatchesInString:result options:kNilOptions range:NSMakeRange(0, result.length)
                         usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                             
                             //fetch the command
                             name = [result substringWithRange: [match rangeAtIndex:1]];
                             
                             //fetch the filter value
                             value = [result substringWithRange: [match rangeAtIndex:2]];
                             
                             NSString* argsString = nil;
                             
                             //fetch the filter arguments
                             if ([match rangeAtIndex:4].location != NSNotFound) {
                                 argsString = [result substringWithRange: [match rangeAtIndex:4]];
                                 args = [argsString componentsSeparatedByString:@","];
                             }
                             
                             //remove the filter command from the log message
                             result = [result stringByReplacingCharactersInRange:match.range withString:@""];
                             
                             *stop = YES;
                         }];
    
    if (name && value) {
        
        Class pluginClass = _registeredPlugins[name];
        if (pluginClass==nil) {
            return [NSString stringWithFormat:@"MTLog:Could not find registered class for plugin '%@'! %@", name, format];
        }
        
        id plugin = [(MTLogPlugin*)[pluginClass alloc] initWithName:name value:value args:args];
        if (plugin==nil) {
            return [NSString stringWithFormat:@"MTLog:Could not create a plugin out of the command '%@(%@)'! %@", name, [args componentsJoinedByString:@","], format];
        }
        
        if ([(MTLogPlugin*)plugin affectsFirstLogmessage]==NO) {
            [_pendingPlugins addObject: plugin];
        } else {
            [_enabledPlugins addObject: plugin];
        }
        
    }
    
    return result;
}

-(void)log:(NSString*)fileName method:(NSString*)method lineNr:(NSNumber*)lineNr text:(NSString *)format, ...
{
    __block NSString* text = format;
    
    //parse the command out of the log message
    if ([text hasPrefix:@"_"]) {
        text = [self parseLogMessage:text];
    }
    
    NSArray* prettyFuncParts;
    NSArray* env;

    //build env variables
    if (_enabledPlugins.count>0) {
        prettyFuncParts = [[method substringWithRange:NSMakeRange(2, method.length-3)] componentsSeparatedByString:@" "];
        env = @[
                fileName, prettyFuncParts.firstObject, prettyFuncParts.lastObject, lineNr, _enabledPlugins, _registeredPlugins
            ];
    }
    
    [_enabledPlugins enumerateObjectsUsingBlock:^(MTLogPlugin* plugin, NSUInteger idx, BOOL *stop) {
       text = [plugin preProcessLogMessage: text env: env];
    }];

    //print to the console
    if (text.length>0) {
        va_list args;
        va_start(args, format);
#ifdef DEBUG
        NSLogv(text, args);
#endif
        va_end(args);
    }
    
    //post processing
    [_enabledPlugins enumerateObjectsUsingBlock:^(MTLogPlugin* plugin, NSUInteger idx, BOOL *stop) {
        [plugin postProcessLogMessage: text env: env];
    }];

    //merge any pending plugins
    if ([_pendingPlugins count]>0) {
        for (id plugin in _pendingPlugins) {
            [_enabledPlugins addObject: plugin];
        }
        
        [_pendingPlugins removeAllObjects];
    }
}

@end
