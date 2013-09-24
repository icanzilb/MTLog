//
//  MTLog.m
//
//  @author Marin Todorov, http://www.touch-code-magazine.com
//

// Copyright (c) 2013 Marin Todorov, Underplot ltd.
// This code is distributed under the terms and conditions of the MIT license.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// The MIT License in plain English: http://www.touch-code-magazine.com/JSONModel/MITLicense

#import "MTLog.h"
#import "MTLogPlugin.h"

//load all default plugins
#import "MTLogPluginRegister.h"
#import "MTLogPluginRemove.h"
#import "MTLogPluginFilter.h"
#import "MTLogPluginSearch.h"
#import "MTLogPluginRoute.h"
#import "MTLogPluginPrefix.h"

@interface MTLog()
{
    NSMutableDictionary* _registeredPlugins;
    NSMutableArray* _pendingPlugins;
}

@end

#pragma mark - MTLog
@implementation MTLog

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
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
            return [NSString stringWithFormat:@"MTLog: Could not find registered class for plugin '%@'! %@", name, format];
        }
        
        id plugin = [(MTLogPlugin*)[pluginClass alloc] initWithName:name value:value args:args];
        if (plugin==nil) {
            return [NSString stringWithFormat:@"MTLog: Could not create a plugin out of the command '%@(%@)'! %@", name, [args componentsJoinedByString:@","], format];
        }
        
        if ([(MTLogPlugin*)plugin affectsFirstLogmessage]==NO) {
            [_pendingPlugins addObject: plugin];
        } else {
            if ([plugin respondsToSelector:@selector(willEnableForLog:)]) {
                [plugin performSelector:@selector(willEnableForLog:) withObject:self];
            }
            [_enabledPlugins addObject: plugin];
        }
        
    }
    
    return result;
}

-(void)log:(NSString*)fileName method:(NSString*)method lineNr:(NSNumber*)lineNr text:(NSString *)format, ...
{
    __block NSString* text = format?format:@"";
    
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
                fileName, prettyFuncParts[0], prettyFuncParts.lastObject, lineNr, _enabledPlugins, _registeredPlugins
            ];
    }

    [_enabledPlugins enumerateObjectsUsingBlock:^(MTLogPlugin* plugin, NSUInteger idx, BOOL *stop) {
        if ([plugin respondsToSelector:@selector(preProcessLogMessage:env:)]) {
            text = [plugin preProcessLogMessage: text env: env];
        }
        NSAssert(text, @"");
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
        if ([plugin respondsToSelector:@selector(postProcessLogMessage:env:)]) {
            [plugin postProcessLogMessage: text env: env];
        }
    }];

    //merge any pending plugins
    if ([_pendingPlugins count]>0) {
        for (id plugin in _pendingPlugins) {
            if ([plugin respondsToSelector:@selector(willEnableForLog:)]) {
                [plugin performSelector:@selector(willEnableForLog:) withObject:self];
            }
            [_enabledPlugins addObject: plugin];
        }
        
        [_pendingPlugins removeAllObjects];
    }
}

+(void)addPlugin:(id)plugin
{
    [[[self sharedInstance] enabledPlugins] addObject: plugin];
}

+ (void)removePlugin:(id)plugin
{
    [[[self sharedInstance] enabledPlugins] removeObject: plugin];
}

+ (NSArray*)pluginsByName:(NSString*)name
{
    NSMutableArray* result = [@[] mutableCopy];
    
    for (MTLogPlugin* plugin in [MTLog sharedInstance].enabledPlugins) {
        if ([plugin.name isEqualToString: name]) {
            [result addObject: plugin];
        }
    }
    
    return [result copy];
}

@end
