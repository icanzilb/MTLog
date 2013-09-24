//
//  MTLogPlugin.h
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

#ifdef TARGET_OS_MAC
#import "NSArray+FirstObject.h"
#endif

typedef NS_ENUM(NSInteger, MTLogEnvIndexes) {
    MTLogFileName = 0,
    MTLogClassName,
    MTLogMethodName,
    MTLogLineNumber,
    MTLogEnabledPlugins,
    MTLogRegisteredPlugins
};

@class MTLog;

/**
 * The MTLogPluginProtocol specifies the optional methods a plugin can implement in order
 * to process the output to the console. All methods are in fact optional.
 *
 * In a custom plugin any or all of these methods can be implemented and will be automatically
 * invoked by MTLog at the point of execution they refer to.
 */
@protocol MTLogPluginProtocol <NSObject>
@optional

/**
 * @name Reacting to the plugin being activated
 */

/**
 * Called just before the plugin is added to the list of active plugins.
 * @param log is an instance of MTLog
 */
-(void)willEnableForLog:(MTLog*)log;

/**
 * @name Reacting to debug output
 */

/**
 * MTLog passes throug the plugin the log message before printing it out to the console. Here a custom plugin can alter the output
 * or react to it somehow, BEFORE the message shows up in the console.
 * @param text the log message
 * @param env the environment of the log call (lookup README.md)
 * @return the modified or unmodified log message
 */
-(NSString*)preProcessLogMessage:(NSString*)text env:(NSArray*)env;

/**
 * MTLog calls this method on each plugn AFTER the message shows up in the console.
 * Therefore this method cannot alter anymore the message itself, but it could react to it in other ways.
 * @param text the log message
 * @param env the environment of the log call (lookup README.md)
 */
-(void)postProcessLogMessage:(NSString*)text env:(NSArray*)env;

@end

/**
 * MTLogPlugin is an <b>abstract implementation</b> of an MTLog plugin class.
 *
 * To build a custom plugin you need to subclass MTLogPlugin and implemented at least one method [MTLogPlugin expectedNumberOfArgumentsForCommand:]
 *
 * You can override the custom initializer method [MTLogPlugin initWithName:value:args:] if you want to customize the class initialization and/or you
 * can additionally implement all the methods from the MTLogPluginProtocol
 */
#pragma mark - MTLogPlugin
@interface MTLogPlugin : NSObject <MTLogPluginProtocol>

/**
 * @name Plugin information
 */

/** The name of the plugin command. 
 *
 * I.e. for "_filter:MyClass.m", value equals "filter". Set by [MTLogPlugin initWithName:value:args:] 
 */
@property (strong, nonatomic) NSString* name;

/** The specific call to the plugin command. 
 *
 * I.e. for "_filter:MyClass.m", value equals "MyClass.m". Set by [MTLogPlugin initWithName:value:args:] 
 */
@property (strong, nonatomic) NSString* value;

/** The name of the plugin command. 
 *
 * I.e. for "_filter:MyClass.m(10,20)", args is a 2 item array [10,20]. Set by [MTLogPlugin initWithName:value:args:] 
 */
@property (strong, nonatomic) NSArray* args;

/**
 * A string ID to uniquely identify a combination of plugin, command and an argument list.
 */
@property (strong, nonatomic, readonly) NSString* pluginID;

/**
 * @name Custom behaviour
 */

/**
 * Whether the plugin should affect a message immediately following the command.
 *
 * For example:
 * <pre>NSLog(@"_filter:MyClass.m My Message"); //there's a message immediately following a command
 * ...
 * NSLog(@"_filter:MyClass.m");
 * NSLog(@"My other message"); //this message is separate from the command message
 * </pre>
 */
@property (assign, nonatomic) BOOL affectsFirstLogmessage;

/**
 * @name Basic plugin methods
 */

/**
 * Returns the minimum and maximum number of expected arguments for a given command to the plugin.
 * 
 * For a full example how to implement this feature lookup README.md, section "Implementing the new "smilie" command".
 * @param command the specific call part to a command. I.e. for "_filter:MyClass.m" command is "MyClass.m"
 * @return an NSRange with the minimum and maximum number of arguments expected. If the command can take only X number of arguments return NSMakeRange(X,X)
 */
+(NSRange)expectedNumberOfArgumentsForCommand:(NSString*)command;

/**
 * @name Initialization
 */

/**
 * Creates a new instance of the plugin. Usually you do not call this method and create plugin instances yourself.
 *
 * When you log a command:
 * <pre>
 * NSLog(@"_prefix:set($class $method) Log message");
 * </pre>
 * MTLog takes care to parse the plugin name ("prefix"), the value ("set") and argument list (1 list item - "$class $method") and create plugin instance and add it ot the plugin chain. Therefore in most cases you would never need to create a plugin instance yourself.
 */
-(instancetype)initWithName:(NSString*)name value:(NSString*)value args:(NSArray*)args;

@end
