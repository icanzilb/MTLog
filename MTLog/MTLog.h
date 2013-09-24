//
//  MTLog.h
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

#import <Foundation/Foundation.h>

//disable loggin on production
#ifdef DEBUG

#define NSLog( s, ... ) [MTLog log: \
[[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
method: [NSString stringWithUTF8String:__PRETTY_FUNCTION__] \
lineNr: [NSNumber numberWithInt:__LINE__] \
text: [NSString stringWithFormat:(s), ##__VA_ARGS__] \
] 

#endif

/**
 * In most cases you would not need to interact with the MTLog class directly. Just keep using NSLog() as normal and
 * have a look at the list of available commands you can use from within the text you supply to NSLog.
 *
 * When you call NSLog(@"... message ...") it calls behind the scene [MTLog log:method:lineNr:text:].
 * This is also the way you execute commands, for example:
 * <pre>
 * NSLog(@"_filter:MyClass.m(10,125) Log message");
 * </pre>
 * Consult README.md for a list of the available commands and examples.
 * This documentation is provided only for the ones who would like to write classes for their own log commands.
 */
@interface MTLog : NSObject

/**
 * @name Logging
 */

/**
 * Don't call this method directly, rather just use NSLog() directly and it will then
 * call this method passing the correct paramters.
 * @param fileName the file the message is logged from
 * @param method the method name where the message is logged from
 * @param lineNr the number of the line in the source code file
 * @param format the message to log, followed by a arbitrary number of arguments
 */
+ (void)log:(NSString*)fileName method:(NSString*)method lineNr:(NSNumber*)lineNr text:(NSString *)format, ...;

/**
 * @name Manipulating plugins
 */

/**
 * Adds an initialized plugin to the plugin chain
 * @param plugin an instance of a subclass of MTLogPlugin
 */
+ (void)addPlugin:(id)plugin;

/**
 * Removes a plugin instance of the plugin chain
 * @param plugin an instance of a subclass of MTLogPlugin
 */
+ (void)removePlugin:(id)plugin;

/**
 * Gets a list of all the plugins in the plugin chain that are of certain class (i.e. you can grab all filter plugins in the chain)
 * @param name the class name of the plugins to fetch
 * @return NSArray list of currently active plugins matching the provided class name
 */
+ (NSArray*)pluginsByName:(NSString*)name;

/**
 * A list of all currently active plugins
 */
@property (strong, readonly, nonatomic) NSMutableArray* enabledPlugins;

@end