//
//  MTLogPluginRemove.m
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

#import "MTLogPluginRemove.h"

@implementation MTLogPluginRemove

+(NSRange)expectedNumberOfArgumentsForCommand:(NSString*)command
{
    return NSMakeRange(0, 100);
}

-(NSString*)preProcessLogMessage:(NSString *)text env:(NSArray *)env
{
    //remove the target plugin
    MTLogPlugin* plugin;
    
    NSMutableArray* pluginParts = [[self.value componentsSeparatedByString:@":"] mutableCopy];
    NSString* pluginName = [pluginParts.firstObject stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    [pluginParts removeObjectAtIndex:0];
    NSString* pluginValue = [pluginParts componentsJoinedByString:@":"];
    
    NSString* searchID = [NSString stringWithFormat:@"%@:%@:%@", pluginName, pluginValue, [self.args componentsJoinedByString:@","]];
    
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
