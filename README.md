MTLog: an NSLog replacement for coders!
=====

Logging is essential part of debugging and I was often irritated that NSLog is not as flexible as I'd like it to be. Therefore I came around writing MTLog - the flexible logging tool that I need.

------------------------------------
Including MTLog in your project
====================================


#### Get it either as: 1) source files

1. Download the MTLog repository as a [zip file](https://github.com/icanzilb/MTLog/archive/master.zip) or clone it
2. Copy the MTLog sub-folder into your Xcode project
3. `#import "MTLog.h"` in the project **.pch** file to have MTLog working throughout all your classes


#### or 2) via Cocoa pods

1. In your project's **Podfile** add the MTLog pod:

```ruby
pod 'MTLog'
``` 

2. From the Terminal, inside the project folder, run:

```ruby
pod install
```

3. `#import "MTLog.h"` in the project **.pch** file to have MTLog working throughout all your classes

If you want to read more about CocoaPods, have a look at [this short tutorial](http://www.raywenderlich.com/12139/introduction-to-cocoapods).

------------------------------------
Using MTLog
====================================
MTLog works by adding scripting abilities to your log messages. You use NSLog as normally but you can include certain commands or add your own commands that will be executed in the text of your log messages. 

It's best if you just read through the examples below.

**NB!** Always make sure you've imported MTLog.h

## Prefix command
-------

By default fresh MTLog instances come with a default prefix for your messages. The default prefix includes the file name of the current class and the current line number (example output below):

```ObjC
NSLog(@"My log message!");
```

<pre style="background:#666;color:white;">
MyClass.m:20 &gt; My log message!
</pre>

##### _prefix:set(…)

If you want a different prefix than the default you can use the prefix command to change it:

```ObjC
NSLog(@"_prefix:set($method $line) My log message!");
NSLog(@"My second message.");
```

<pre style="background:#666;color:white;">
myMethod 20 &gt; My log message!
myMethod 21 &gt; My second message!
</pre>

**NB!**: _prefix:set(…) sets the prefix for the current log message AND for all the messages you log afterwards.

##### prefix variables
Besides text you can also use variables in your prefix that will get replaced with their values for every log message. Here's the list of available variables:

<table width="400">
<tr>
<td valign="top">
$file
</td>
<td valign="top">
The name of the current file
</td>
<tr>
<td valign="top">
$class
</td>
<td valign="top">
The current class name
</td>
<tr>
<td valign="top">
$method
</td>
<td valign="top">
The current method name
</td>
<tr>
<td valign="top">
$line
</td>
<td valign="top">
The current line number
</td>
<tr>
<td valign="top">
$counter
</td>
<td valign="top">
A counter starting from 1. It increases every time you log from the same line in the same file.
</td>
</tr>
</table>

##### _prefix:set()

If you don't want a special prefix to your log messages, just call set with no arguments:

```ObjC
NSLog(@"_prefix:set()");
```

##### _prefix:use(…)

If you want to change the prefix for the current log message ONLY you use _prefix:use(…)

```ObjC
NSLog(@"My log message!");
NSLog(@"_prefix:use($method $line) My log message!");
NSLog(@"My second message.");
```
<pre style="background:#666;color:white;">
MyClass.m:20 &gt; My log message!
myMethod 21 &gt; My log message!
MyClass.m:22 &gt; My second message!
</pre>

##### _prefix:set(default)

If you change the prefix and want to go back to the default, pass the "default" constant to the set method of the prefix command:

```ObjC
NSLog(@"_prefix:set(default)");
```


## Filter command
----

You can use the filter command to temporarily filter the log output, i.e. if you are debugging a certain method at the moment you don't want to see the output of all other log statements outside this method until you are finished.

You can use filter in several different ways.

##### _filter:MyClass.m

If you pass a file name to _filter after this log statement you will see only the output from this file.

```ObjC
YourClass.m
...
+(void)message
{
  NSLog(@"Your message!");
}

MyClass.m 
...
NSLog(@"_filter:MyClass.m");
NSLog(@"My message");
[YourClass message];
```

<pre style="background:#666;color:white;">
MyClass.m:20 &gt; My message
// "Your message" will be filtered and not show up in the output console
</pre>

##### _filter:MyClass.m(10,200)

You can filter the output by line number. Pass in a file name to _filter and as arguments provide the range of lines that should generate output to the console.

```ObjC
NSLog(@"_filter:MyClass.m(10,100)");
```

This command will allow only log statements from the lines between line 10 and line 100 to generate output to the console.

##### _filter:myMethod:withString:

You can also pass a method signature to the _filter command - then it will allow output only from the method matching this signature.

##### combined _filter commands

_filter commands you can stack up. I.e. you want to see only the output from the init method, though you have an init method in each of your classes. You can combine a filter by file name and a filter by method name.

```ObjC
NSLog(@"_filter:MyClass.m");
NSLog(@"_filter:init");
```

After this NSLog statements only logging from "init" in MyClass.m will generate output.

##### _filter:$this

Sometimes you want to see the output only of a certain line in your code and nothing more (for example if the NSLog statement is in a for loop).

```ObjC
NSLog(@"begin counting");
for (int i=1;i<=3;i++) {
  NSLog(@"_filter:$this i=%i", i);
  NSLog(@"more loop output");
}
NSLog(@"_filter:$this loop ended");
NSLog(@"last log message");
```

Once you use _filter:$this all log messages afterwards get filtered out. Except for the ones that also use _filter:$this. The output of the code above is:

<pre style="background:#666;color:white;">
MyClass.m:20 > begin counting
MyClass.m:22 > i=1
MyClass.m:22 > i=2
MyClass.m:22 > i=3
MyClass.m:25 > loop ended
</pre>

## Remove command
----

Since commands like filter affect all log messages afterwards you need a way to also deactivate them.

##### _remove:&lt;command to remove&gt;

Use "_remove:" followed by the exact command you used in first place. If we take the example from above and combine it with remove the code could look like this:

```ObjC
NSLog(@"_filter:$this Message 1");
NSLog(@"Message 2");
NSLog(@"_remove:_filter:$this");  //remove: + the command including arguments
NSLog(@"Message 3");
}
```

Since the remove command will remove the filter you will also see the last log in the output console. 

<pre style="background:#666;color:white;">
MyClass.m:20 > Message 1
MyClass.m:23 > Message 3
</pre>

In general all commands affect all logs after they get executed. Therefore you need to use _remove to deactivate them.

Some commands like _prefix:use(…) are one-shot commands therefore you don't need to use _remove for them.

## Route command
----

The route command allows you to clone the output you see in the console to a log file. That's handy if you'd like to run the app many times and then analyze the log contents for example.

##### _route:file(log.txt)

The command creates a "log.txt" in your app's Documents folder and saves all the output (while the command is active) to this file.

##### _route:file(/&lt;full path&gt;/log.txt)

If you pass in a full blown path to a file, the command will create (or overwrite) it at the location you specify.

##### _route:file(log.txt,append)

If you pass the "append" constant as a second parameter your app will keep adding content to the file (instead of overwriting it at every run). 

```ObjC
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  NSLog(@"message one");
  NSLog(@"message two");
  return YES;
}
```

<pre style="background:#666;color:white;">
--- 2013-09-14 08:36:21 +0000 ---- New log entry ----
[application:didFinishLaunchingWithOptions: 19] message one
[application:didFinishLaunchingWithOptions: 20] message two

--- 2013-09-14 08:42:01 +0000 ---- New log entry ----
[application:didFinishLaunchingWithOptions: 19] message one
[application:didFinishLaunchingWithOptions: 20] message two

</pre>

## Search command
----

Sometimes there's so much output in the console that you can't find the one line you really want to see. And further it's difficult to find where in the code is the line that produces that output and break there. The search command helps you spot certain log messages.

##### _search:clear(&lt;search term&gt;)

This command simply adds 20 empty lines before every line that contains the search term. It kind of "clears" the console when the search term appears so you can spot it easier.

```ObjC
NSLog(@"_search:clear(vacation)");
…
NSLog(@"Yupee!");
NSLog(@"I'm going on vacation!");
```

<pre style="background:#666;color:white;">
MyClass.m:20 > Yupee!

… //19 more empty lines
MyClass.m:22 > I'm going on vacation!
</pre>

##### _search:throw(&lt;search term&gt;)

Whenever the search term appears in a log message the app throws an exception and catches it so the execution is not interrupted. If you are having a breakpoint for all exceptions Xcode will break inside the search plugin, so you can debug your code up the stack.

## Register command
----

Now comes the best of all commands - the one that allows you to register new commands with MTLog. Have an idea for a command that will really help you while debuggin? Add it!

##### _register:command(CommandClassName)

You need to subclass MTLogPlugin and override some or all of the following methods (in the order of invocation):

```ObjC
// to tell MTLog how many arguments you are expecting
// for example return [0,2] - for zero, one or two args
+(NSRange)expectedNumberOfArgumentsForCommand:(NSString*)command;

// the custom plugin init- name contains the command, value is the part after the colon
// args is an array of the arguments (not trimmed of spaces)
-(instancetype)initWithName:(NSString*)name value:(NSString*)value args:(NSArray*)args;

// the method is invoked just before the plugin is added to enabled plugins list
-(void)willEnableForLog:(MTLog*)log;

// text contains the log message, you can alter it in any way and return it
// look up "env" below
-(NSString*)preProcessLogMessage:(NSString*)text env:(NSArray*)env;

// use this method to react to a command after the message is logged
// look up "env" below
-(void)postProcessLogMessage:(NSString*)text env:(NSArray*)env;
```

The "env" array contains as follows:

1. File name
2. Class name
3. Method name
4. Line number
5. List of all enabled plugins
6. List of all registered plugins

You can alter the enabled and registered plugins lists if you need to.

#### Implementing the new "smilie" command

Let's see the code for a new command called "smilie" that adds a smilie to each log message.

**PluginSmilie.h**

```ObjC
#import "MTLogPlugin.h"
@interface PluginSmilie : MTLogPlugin
@end
```

**PluginSmilie.m**

```ObjC
#import "PluginSmilie.h"
@implementation PluginSmilie
+(NSRange)expectedNumberOfArgumentsForCommand:(NSString*)command
{
  if ([command isEqualToString:@"extended"]) {
    return NSMakeRange(1, 1);
  }
  return NSMakeRange(0, 0);
}

-(NSString*)preProcessLogMessage:(NSString *)text env:(NSArray *)env
{
  if ([self.value isEqualToString:@"classic"]) {
    return [NSString stringWithFormat:@"%@ :-)", text];
  }
    
  if ([self.value isEqualToString:@"extended"]) {
    return [NSString stringWithFormat:@"%@ :%@)", text, self.args.firstObject];
  }
    
  return text;
}

@end
```

That's a complete, working command for MTLog. 

In `expectedNumberOfArgumentsForCommand:` you set that you expect between 1 and 1 arguments for the "_smilie:extend" command, and no arguments for the "_smilie:classic" command.

Then in `preProcessLogMessage:env:` you add a smilie to the text argument, which alters the message being logged.

Let's see how you can use the new command in your code:

```ObjC
#import "PluginSmilie.h"
NSLog(@"_register:smilie(PluginSmilie)");
… 
NSLog(@"Message One");
NSLog(@"_smilie:classic Message Two");
NSLog(@"Message Three");

NSLog(@"_remove:_smilie:classic");
NSLog(@"Message Four");

NSLog(@"_smilie:extended(-{)");
NSLog(@"A hipster message");
```

<pre style="background:#666;color:white;">
MyClass.m:20 > Message One
MyClass.m:21 > Message Two :-)
MyClass.m:22 > Message Three :-)
MyClass.m:25 > Message Four
MyClass.m:28 > A hipster message :-{)
</pre>

------------------------------------
Misc
====================================
Author: [Marin Todorov](http://www.touch-code-magazine.com/about/)

-------
#### License

This code is distributed under the terms and conditions of the MIT license. 

-------
#### Contribution guidelines

**NB!** If you are fixing a bug you discovered or adding a feature, please add also a unit test so I know how exactly to reproduce the bug before merging.
