//
//  MTLogPluginPrefix.m
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

#import "MTLogPluginPrefix.h"
#import "MTLog.h"

@implementation MTLogPluginPrefix
{
    BOOL _initialized;
}

+(NSRange)expectedNumberOfArgumentsForCommand:(NSString*)command
{
    return NSMakeRange(0, 1);
}

-(void)willEnableForLog:(MTLog*)log
{
    if ([self.value isEqualToString:@"use"]) {
        for (MTLogPlugin* plugin in log.enabledPlugins) {
            if ([plugin isKindOfClass:[MTLogPluginPrefix class]]) {
                [(MTLogPluginPrefix*)plugin setShouldSkipCurrentMessage:YES];
            }
        }
    }
    else if ([self.value isEqualToString:@"set"]) {
        NSArray* prefixes = [MTLog pluginsByName:@"prefix"];
        if (prefixes.count>0) {
            for (id plugin in prefixes) {
                [MTLog removePlugin: plugin];
            }
        }
    }
}

-(NSString*)preProcessLogMessage:(NSString *)text env:(NSArray *)env
{
    static NSArray* variables;
    static NSMutableDictionary* counters;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        variables = @[@"$file", @"$class", @"$method", @"$line", @"$counter", @"$timestamp"];
        counters = [@{} mutableCopy];
    });
    
    //apply prefix to message
    if (self.shouldSkipCurrentMessage) {
        //skip current message in favor of a "set" command
        self.shouldSkipCurrentMessage=NO;
    } else {
        //apply prefix to the log message
        if (self.args.count>0 && text.length>0) {
            if ([@"default" isEqualToString: self.args.firstObject]) {
                text = [NSString stringWithFormat:@"%@:%@ > %@",env[MTLogFileName], env[MTLogLineNumber], text];
            } else {
                
                //parse the variables
                NSString* prefix = [self.args.firstObject copy];
                for (int i=0;i<4;i++) {
                    prefix = [prefix stringByReplacingOccurrencesOfString:variables[i] withString:[env[i] description]];
                }
                if ([prefix rangeOfString:@"$timestamp"].location!=NSNotFound) {
                    //replace timestamps
                    NSDateComponents *dc = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[NSDate date]];
                    NSString* timestamp = [NSString stringWithFormat:@"%i-%i-%i %i:%i:%i", dc.year, dc.month, dc.day, dc.hour, dc.minute, dc.second ];
                    prefix = [prefix stringByReplacingOccurrencesOfString:@"$timestamp" withString:timestamp];
                }
                text = [NSString stringWithFormat:@"%@ %@", prefix, text];
            }
        }
        
        if (text.length>0) {
            //handle any counters
            if ([text rangeOfString: @"$counter"].location != NSNotFound) {
                NSString* messageID = [NSString stringWithFormat:@"%@:%@:%@", env[MTLogFileName], env[MTLogMethodName], env[MTLogLineNumber]];
                int count = [counters[messageID] intValue]+1;
                counters[messageID] = @(count);
                text = [text stringByReplacingOccurrencesOfString:@"$counter" withString: [@(count) stringValue]];
            }
        }
        
    }
   
    return text;
}

-(void)postProcessLogMessage:(NSString *)text env:(NSArray *)env
{
    //one time prefix
    if ([self.value isEqualToString:@"use"]) {
        [env[MTLogEnabledPlugins] removeObject: self];
    }
}

@end
