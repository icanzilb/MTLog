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
    
    NSURL* _urlToPostTo;
    NSString* _identifier;
    BOOL _isCreatingConnection;
    NSMutableArray* _pendingLines;
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
    
    if (_logFilePath) {
        if ([[NSFileManager defaultManager] fileExistsAtPath: _logFilePath]==NO || _isAppendingToLog==NO) {
            [@"" writeToFile:_logFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }
}

-(void)writeToLogFile:(NSString*)message
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath: _logFilePath];
    
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[[NSString stringWithFormat:@"%@\n", message] dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle closeFile];
}

-(void)postToURL:(NSString*)message forceCreateConnection:(BOOL)shouldForce
{
    if (!_urlToPostTo) return;
    
    static BOOL gotFirstResponseFromURL = NO;
    
    if (shouldForce==NO && gotFirstResponseFromURL==NO) {
        [_pendingLines addObject: message];
        return;
    }
    
    //send the request off in a bg thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_urlToPostTo];
        [request setHTTPMethod: @"POST"];
        [request setValue:@"text/plain; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

        NSString* postMessage = message;
        
        @synchronized (_pendingLines) {
            if (_pendingLines.count>0) {
                [_pendingLines addObject: message];
                postMessage = [_pendingLines componentsJoinedByString:@"\n"];
                [_pendingLines removeAllObjects];
            }
        }
        
        NSData *requestBodyData = [postMessage dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPBody = requestBodyData;
        request.timeoutInterval = 10.0;
        [request setValue:_identifier forHTTPHeaderField:@"X-MTLog-ID"];
        
        NSError* err = nil;
        NSHTTPURLResponse * response = nil;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
        
        if (response.statusCode==404 || err) {
            //disable url posting
            _urlToPostTo = nil;
        } else {
            //success
            gotFirstResponseFromURL = YES;
            if (shouldForce) {
                //flush the pending messages
                [self postToURL:@"" forceCreateConnection:NO];
            }
        }
    });
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
    
    if (_urlToPostTo==nil && [self.value isEqualToString:@"url"]) {
        if ([self.args.firstObject hasPrefix:@"http"]) {
            //url to post to
            _urlToPostTo = [NSURL URLWithString: self.args.firstObject];
            _identifier = [[NSUUID UUID] UUIDString];
            _pendingLines = [@[] mutableCopy];
            _isCreatingConnection = YES;
            [self postToURL:@"" forceCreateConnection:YES];
        }
    }
    
    return text;
}

-(void)postProcessLogMessage:(NSString *)text env:(NSArray *)env
{
    //save the log message in a file
    if (text.length>0 && _logFilePath) {
        [self writeToLogFile: text];
    }
    
    if (text.length>0 && _urlToPostTo) {
        [self postToURL:text forceCreateConnection:NO];
    }
}

@end
