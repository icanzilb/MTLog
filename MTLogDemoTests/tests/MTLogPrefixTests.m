//
//  MTLogDemoTests.m
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

@interface MTLogPrefixTests : XCTestCase
@end

@implementation MTLogPrefixTests

- (void)testEmtpyPrefix
{
    //test no prefix
    NSLog(@"_prefix:set()");
    NSLog(@"Simple message");
    
    XCTAssertEqualObjects([MTLog lastMessageCatcher].logMessage, @"Simple message", @"The message logged is not equal to 'Simple message'");
}

- (void)testMethod
{
    //test method name
    NSLog(@"_prefix:set($method:)");
    NSLog(@"Simple message");
    
    XCTAssertEqualObjects([MTLog lastMessageCatcher].logMessage, @"testMethod: Simple message", @"The prefix is not set to method name");
}

-(void)testFilename
{
    //test file name + method name
    NSLog(@"_prefix:set([$file $method])");
    NSLog(@"Simple message");
    
    XCTAssertEqualObjects([MTLog lastMessageCatcher].logMessage, @"[MTLogPrefixTests.m testFilename] Simple message", @"The prefix is not set to file name + method name");
}

-(void)testClassName
{
    //test class name
    NSLog(@"_prefix:set($class)");
    NSLog(@"Simple message");
    XCTAssertEqualObjects([MTLog lastMessageCatcher].logMessage, @"MTLogPrefixTests Simple message", @"The prefix is not set to class name");
}

-(void)testCombinedPrefix
{
    
    //test file, class, method and line combined
    NSLog(@"_prefix:set($file $class $method $line)");
    int nextLineNr = __LINE__ + 1;
    NSLog(@"Simple message");
    
    NSString* expectedMessage = [NSString stringWithFormat:@"MTLogPrefixTests.m MTLogPrefixTests testCombinedPrefix %d Simple message", nextLineNr];
    XCTAssertEqualObjects([MTLog lastMessageCatcher].logMessage, expectedMessage , @"The prefix did not match the expected value");
}

-(void)testPrefixCounter
{
    //test the prefix counter
    NSLog(@"_prefix:use($counter.) Simple message");
    
    XCTAssertEqualObjects([MTLog lastMessageCatcher].logMessage, @"1. Simple message", @"The $counter did not initialize");
    
    //test repeating prefix counter
    for (int i=1;i<11;i++) {
        NSLog(@"_prefix:use($counter.) Simple message");
        NSString* message = [NSString stringWithFormat:@"%i. Simple message", i];
        XCTAssertEqualObjects([MTLog lastMessageCatcher].logMessage,
                              message,
                              @"The $counter did not count");
    }
}

-(void)testMessageCounter
{
    //test counter inside the log message
    NSLog(@"_prefix:set()");
    
    for (int i=1;i<11;i++) {
        NSLog(@"Simple message #$counter");
        NSString* message = [NSString stringWithFormat:@"Simple message #%i", i];
        XCTAssertEqualObjects([MTLog lastMessageCatcher].logMessage,
                              message,
                              @"The $counter did not count");
    }
}

- (void)setUp
{
#ifndef DEBUG
#define DEBUG 1
#endif
    
    [super setUp];
}

- (void)tearDown
{
    
    [super tearDown];
}

@end
