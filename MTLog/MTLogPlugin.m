//
//  MTLogPlugin.m
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

#import "MTLogPlugin.h"

@implementation MTLogPlugin

-(instancetype)init
{
    NSAssert(NO, @"Use initWithName:value:args:");
    return nil;
}

+(NSRange)expectedNumberOfArgumentsForCommand:(NSString*)command
{
    NSAssert(NO, @"Override +(NSRange)expectedNumberOfArguments in '%@'", [self class]);
    return NSMakeRange(0, 0);
}

-(instancetype)initWithName:(NSString*)name value:(NSString*)value args:(NSArray*)args
{
    //validate
    if (value.length < 1 ||
        args.count < [[self class] expectedNumberOfArgumentsForCommand: value].location ||
        args.count > [[self class] expectedNumberOfArgumentsForCommand: value].length) {
        
        NSLog(@"MTLog: Wrong number of arguments provided for plugin: %@ value: %@ arguments: %@", name, value, args);
        
        return nil;
    }
    
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

@end
