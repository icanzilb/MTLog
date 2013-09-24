//
//  MTLogRegisterTests.m
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

#import "MTLogPluginSmilie.h"

@interface MTLogRegisterTests : XCTestCase

@end

@implementation MTLogRegisterTests

- (void)setUp
{
    [super setUp];

}

- (void)tearDown
{

    [super tearDown];
}

- (void)testRegister
{
    NSLog(@"_prefix:set()");
    NSMutableDictionary* reg = [MTLog lastMessageCatcher].env[5];
    [reg removeObjectForKey:@"MTLogPluginSmilie"];
    
    NSLog(@"_register:smilie(MTLogPluginSmilie)");
    NSMutableDictionary* reg1 = [MTLog lastMessageCatcher].env[5];
    XCTAssertNotNil(reg1[@"smilie"], @"Smilie plugin not found after registration");
    
    Class registeredPlugin = reg1[@"smilie"];
    XCTAssertEqualObjects([registeredPlugin description], @"MTLogPluginSmilie", @"Smilie plugin registration didn't register the correct class");

    NSLog(@"Simple message");
    XCTAssertEqualObjects([MTLog lastMessageCatcher].logMessage, @"Simple message", @"Message was adjusted when expected no adjustments");
    
    NSLog(@"_smilie:on Simple message");
    XCTAssertEqualObjects([MTLog lastMessageCatcher].logMessage, @":) Simple message", @"Smilie is not addded when the pluing should be on");
    
    //cleanup
    [reg1 removeObjectForKey:@"smilie"];
    NSMutableArray* enabled = [MTLog lastMessageCatcher].env[4];
    id match = nil;
    for (id plugin in enabled) {
        if ([plugin isKindOfClass:[MTLogPluginSmilie class]]) {
            match = plugin;
        }
    }
    
    if (match) {
        [enabled removeObject: match];
    }
    
}



@end
