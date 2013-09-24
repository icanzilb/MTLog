//
//  MTLog+Testing.m
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

#import "MTLog+Testing.h"
#import "JRSwizzle.h"
#import "MTLogPluginOutputCatcher.h"

@implementation MTLog (Testing)

static MTLogPluginOutputCatcher* __lastMessageCatcher = nil;

+(void)load
{
    //super implementation
    [super load];
    
    //initialize the class
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //swizzle the original MTLog implementation
        NSError* err = nil;
        [MTLog jr_swizzleClassMethod: @selector(log:method:lineNr:text:)
                     withClassMethod: @selector(grabOutputLog:method:lineNr:text:)
                               error: &err];
    });
}

+(void)grabOutputLog:(NSString*)fileName method:(NSString*)method lineNr:(NSNumber*)lineNr text:(NSString *)format, ...
{
    //add a catcher to the pluing chain
    __lastMessageCatcher = [[MTLogPluginOutputCatcher alloc] initWithName:@"catcher" value:@"output" args:nil];
    [self addPlugin: __lastMessageCatcher];
    
    va_list args;
    va_start(args, format);
    [self grabOutputLog:fileName method:(NSString*)method lineNr:lineNr text:format, args];
    va_end(args);
    
    [self removePlugin: __lastMessageCatcher];
}

+(MTLogPluginOutputCatcher*)lastMessageCatcher
{
    return __lastMessageCatcher;
}

@end
