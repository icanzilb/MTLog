//
//  MTLogFilterTests.m
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

#import "MTLogFilterTestsHelper.h"

@interface MTLogFilterTests : XCTestCase

@property (strong, nonatomic) MTLogFilterTestsHelper* helper;

@end

@implementation MTLogFilterTests

- (void)setUp
{
    [super setUp];
    _helper = [[MTLogFilterTestsHelper alloc] init];
}

- (void)tearDown
{
    _helper = nil;
    [super tearDown];
}

- (void)testByFileNameAndLine
{
    NSLog(@"_prefix:set()");
    
    NSString* filterCommand = [NSString stringWithFormat:@"_filter:MTLogFilterTests.m(%d,%d)", __LINE__, __LINE__ + 5];
    
    NSLog(@"%@", filterCommand);

    NSLog(@"Message 1");

    XCTAssertEqualObjects([MTLog lastMessageCatcher].logMessage, @"Message 1", @"Message 1 was not logged");

    //test for filtered message
    
    NSLog(@"Message 2");
    XCTAssertNil([MTLog lastMessageCatcher].logMessage, @"Message 2 was logged");

    //remove
    NSLog(@"_remove:%@", filterCommand);

}

- (void)testByFilename
{
    NSLog(@"_prefix:set()");
    
    NSLog(@"Message 1");
    XCTAssertEqualObjects([MTLog lastMessageCatcher].logMessage, @"Message 1", @"Message 1 was not logged");

    NSLog(@"_filter:MTLogFilterTests.m");

    //test message from the selected file
    NSLog(@"Message 2");
    XCTAssertEqualObjects([MTLog lastMessageCatcher].logMessage, @"Message 2", @"Message 2 was not logged");
    
    //test a filtered message
    [_helper log:@"Message 3"];
    
    XCTAssertNil([MTLog lastMessageCatcher].logMessage, @"Message 3 was logged instead of being filtered");

    //remove
    NSLog(@"_remove:_filter:MTLogFilterTests.m");
}

- (void)testByMethodName
{
    NSLog(@"_prefix:set()");
    
    NSLog(@"_filter:testByMethodName");
    
    //allow this method
    NSLog(@"Message 1");
    XCTAssertEqualObjects([MTLog lastMessageCatcher].logMessage, @"Message 1", @"Message 1 was not logged");
    
    [_helper log:@"Message 2"];
    XCTAssertNil([MTLog lastMessageCatcher].logMessage, @"Message 2 was logged instead of being filtered");
    
    //remove
    NSLog(@"_remove:_filter:testByMethodName");

    //allow method from another class
    NSLog(@"_filter:log:");
    
    NSLog(@"Message 1");
    XCTAssertNil([MTLog lastMessageCatcher].logMessage, @"Message 1 was logged instead of being filtered");

    //test external method with colon in the name
    [_helper log:@"Message 2"];
    XCTAssertEqualObjects([MTLog lastMessageCatcher].logMessage, @"Message 2", @"Message 2 was not logged");
    
    //remove
    NSLog(@"_remove:_filter:log:");
    
    //allow method from another class
    NSLog(@"_filter:log:withNumber:");

    //test external method with 2 colons in the name
    [_helper log:@"Message " withNumber:@3];
    XCTAssertEqualObjects([MTLog lastMessageCatcher].logMessage, @"Message 3", @"Message 3 was not logged");
    
    //remove
    NSLog(@"_remove:_filter:log:withNumber:");
}

-(void)testByThis
{
    NSLog(@"_prefix:set()");
    
    NSLog(@"Message 1");
    XCTAssertEqualObjects([MTLog lastMessageCatcher].logMessage, @"Message 1", @"Message 1 was not logged");
    
    NSLog(@"_filter:$this Message 2");
    XCTAssertEqualObjects([MTLog lastMessageCatcher].logMessage, @"Message 2", @"Message 2 was not logged");
    
    NSLog(@"Message 3");
    XCTAssertNil([MTLog lastMessageCatcher].logMessage, @"Message 3 was logged instead of being filtered");

    NSLog(@"_filter:$this Message 4");
    XCTAssertEqualObjects([MTLog lastMessageCatcher].logMessage, @"Message 4", @"Message 4 was not logged");
    
    NSLog(@"Message 5");
    XCTAssertNil([MTLog lastMessageCatcher].logMessage, @"Message 5 was logged instead of being filtered");
    
    //remove
    NSLog(@"_remove:_filter:$this");
    
    NSLog(@"Message 6");
    XCTAssertEqualObjects([MTLog lastMessageCatcher].logMessage, @"Message 6", @"Message 6 was not logged");

}

@end
