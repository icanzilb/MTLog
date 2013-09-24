//
//  MTLogPluginRoute.m
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

#import "MTLogPluginRoute.h"

@implementation MTLogPluginRoute
{
    NSString* _documentsPath;
    BOOL _isAppendingToLog;
}

+(NSRange)expectedNumberOfArgumentsForCommand:(NSString*)command
{
    return NSMakeRange(1, 2);
}

-(void)createLogFile:(NSString*)name
{
    if ([name hasPrefix:@"/"]) {
        //absolute file path
        _logFilePath = name;
        
    } else {
        //relative path - create it inside the documents folder
        if (_documentsPath==nil) {
            _documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            _logFilePath = [_documentsPath stringByAppendingPathComponent: self.args.firstObject];
        }
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: _logFilePath]==NO || _isAppendingToLog==NO) {
        [@"" writeToFile:_logFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

-(void)writeToLogFile:(NSString*)message
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath: _logFilePath];
    
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[[NSString stringWithFormat:@"%@\n", message] dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle closeFile];
}

-(NSString*)preProcessLogMessage:(NSString *)text env:(NSArray *)env
{
    if (_logFilePath==nil && [self.value isEqualToString:@"file"]) {
        //parse the arguments
        if (self.args.count>1 && [@"append" isEqualToString: self.args[1]]) {
            _isAppendingToLog = YES;
        }

        //create the log file
        [self createLogFile: self.args.firstObject];
        
        //add the date of the log if appending
        if (_isAppendingToLog) {
            [self writeToLogFile:[NSString stringWithFormat:@"--- %@ ---- New log entry ----", [NSDate date]]];
        }
    }
    
    return text;
}

-(void)postProcessLogMessage:(NSString *)text env:(NSArray *)env
{
    //save the log message in a file
    if (text.length>0) {
        [self writeToLogFile: text];
    }
}

@end
