//
//  MTLogSearchTests.m
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

#import "MTLogPluginSearch.h"

@interface MTLogSearchTests : XCTestCase

@end

@implementation MTLogSearchTests

- (void)setUp
{
    [super setUp];

}

- (void)tearDown
{

    [super tearDown];
}

- (void)testSearchThrow
{
    NSLog(@"_prefix:set()");
    
    NSLog(@"_search:throw(vacation)");
    
    for (int i=0;i<5;i++) {
        NSLog(@"I go to vacation"); //should be a match
        NSLog(@"I come back home");
    }
    
    NSMutableArray* enabled = [MTLog lastMessageCatcher].env[4];
    MTLogPluginSearch* search = nil;
    for (id plugin in enabled) {
        if ([plugin isKindOfClass:[MTLogPluginSearch class]]) {
            search = plugin;
        }
    }
    
    XCTAssertEqual(5, search.resultsCount, @"Search did not find 5 times 'vacation'");
    
    NSLog(@"_remove:_search:throw(vacation)");
}

- (void)testSearchClear
{
    NSLog(@"_prefix:set()");
    
    NSLog(@"_search:clear(vacation)");
    NSLog(@"Go in vacation.");
    XCTAssertTrue( [MTLog lastMessageCatcher].logMessage.length > 20 , @"The message was not altered, but is a search result");

    NSLog(@"I go home.");
    XCTAssertTrue( [MTLog lastMessageCatcher].logMessage.length == 10 , @"The message was altered, but it's not a search result");
    
    NSLog(@"_remove:_search:clear(vacation)");
}

@end
