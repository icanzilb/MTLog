//
//  MTLogPluginRoute.m
//  MTLogDemo
//
//  Created by Marin Todorov on 8/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "MTLogPluginRoute.h"

@implementation MTLogPluginRoute
{
    NSString* _documentsPath;
    NSString* _logFilePath;
    
    BOOL _isAppendingToLog;
}

-(void)createLogFile:(NSString*)name
{
    if (_documentsPath==nil) {
        _documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        _logFilePath = [_documentsPath stringByAppendingPathComponent: self.args.firstObject];
    }

    if ([[NSFileManager defaultManager] fileExistsAtPath: _logFilePath]==NO || _isAppendingToLog==NO) {
        [@"" writeToFile:_logFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    [self writeToLogFile:[NSString stringWithFormat:@"--- %@ ---- New log entry ----", [NSDate date]]];
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
    }
    
    return text;
}

-(void)postProcessLogMessage:(NSString *)text env:(NSArray *)env
{
    [self writeToLogFile: text];
}

@end
