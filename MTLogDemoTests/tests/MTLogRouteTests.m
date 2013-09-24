//
//  MTLogRouteTests.m
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

#import <XCTest/XCTest.h>

#import "MTLog+Testing.h"
#import "MTLogPluginOutputCatcher.h"

#import "MTLogPluginRoute.h"

@interface MTLogRouteTests : XCTestCase

@end

@implementation MTLogRouteTests

- (void)setUp
{
    [super setUp];
    
}

- (void)tearDown
{
    
    [super tearDown];
}

- (void)testRouteFile
{
    NSLog(@"_prefix:set()");

    NSLog(@"_route:file(log.txt)");
    
    NSLog(@"Message 1");
    NSLog(@"Message 2");
    
    NSString* logPath = [(MTLogPluginRoute*)[MTLog pluginsByName:@"route"].firstObject logFilePath];
    
    XCTAssertNotNil(logPath, @"Route plugin log file path is nil");
    
    NSString* logText = [NSString stringWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:nil];
    
    XCTAssertNotNil(logText, @"Route log file contents is emtpy or file not found");
    XCTAssertEqualObjects(logText, @"Message 1\nMessage 2\n", @"The log contents are not what was expected");
    
    NSLog(@"_remove:_route:file(log.txt)");
}

- (void)testRouteFileAppend
{
    NSLog(@"_prefix:set()");
    
    //start a new log file
    NSLog(@"_route:file(logAppend.txt)");
    
    NSLog(@"Message 1");
    NSLog(@"Message 2");

    NSLog(@"_remove:_route:file(logAppend.txt)");

    //append to the existing log file
    NSLog(@"_route:file(logAppend.txt,append)");
    
    NSLog(@"Message 3");
    NSLog(@"Message 4");
    
    NSString* logPath = [(MTLogPluginRoute*)[MTLog pluginsByName:@"route"].firstObject logFilePath];
    
    XCTAssertNotNil(logPath, @"Route plugin log file path is nil");
    
    NSString* logText = [NSString stringWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:nil];
    
    XCTAssertNotNil(logText, @"Route log file contents is emtpy or file not found");

    //test the log file contents
    NSArray* logLines = [logText componentsSeparatedByString:@"\n"];
    XCTAssertEqualObjects(logLines[0], @"Message 1", @"Line 1 is not 'Message 1'");
    XCTAssertTrue( [logLines[2] hasPrefix:@"--- 20"] , @"Line 3 is not the append separator.");
    XCTAssertEqualObjects(logLines[3], @"Message 3", @"Line 4 is not 'Message 3'");
    
    NSLog(@"_remove:_route:file(logAppend.txt)");
}

- (void)testRouteFilePrefix
{
    
}

@end
