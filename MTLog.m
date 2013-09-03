//
//  MTLog.m
//
//  Created by Marin Todorov on 3/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "MTLog.h"

static MTLog* __mtLog = nil;

#pragma mark - MTLogFilter

typedef NS_ENUM(int, MTLogFilterTypes) {
    MTLogFilterTypeFileName
};

@interface MTLogFilter : NSObject
@property (assign, nonatomic) int type;
@property (strong, nonatomic) NSString* value;
@property (strong, nonatomic) NSArray* args;
@end

@implementation MTLogFilter
@end

#pragma mark - MTLog
@implementation MTLog
{
    NSMutableDictionary* _filters;
    NSMutableDictionary* _pendingFilters;
}

+(void)load
{
#ifdef DEBUG
    if (__mtLog==nil) {
        __mtLog = [[MTLog alloc] init];
    }
#endif
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        _filters = [@{} mutableCopy];
    }
    return self;
}

+(MTLog*)sharedInstance
{
    return __mtLog;
}

+(void)log:(NSString*)fileName lineNr:(NSNumber*)lineNr text:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    [[self sharedInstance] log:fileName lineNr:lineNr text:format, args];
    va_end(args);
}

-(NSString*)parseFilter:(NSString*)format
{
    __block NSString* result = format;
    __block NSString* filterID = nil;
    __block NSString* command = nil;
    __block NSString* value = nil;
    __block NSArray* args = nil;

    MTLogFilter* filter = [[MTLogFilter alloc] init];
    
    //find the filter command
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:@"(filter|unfilter):([^\( ]+)(\\(.+?\\))?[ ]?"
                                                                      options:kNilOptions
                                                                        error:nil];

    [regEx enumerateMatchesInString:result options:kNilOptions range:NSMakeRange(0, result.length)
                         usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){

                             //fetch the command
                             command = [result substringWithRange: [match rangeAtIndex:1]];
                             
                             //fetch the filter value
                             value = [result substringWithRange: [match rangeAtIndex:2]];
                             
                             NSString* argsString = nil;
                             
                             //fetch the filter arguments
                             if ([match rangeAtIndex:3].location != NSNotFound) {
                                 argsString = [result substringWithRange: [match rangeAtIndex:4]];
                                 args = [argsString componentsSeparatedByString:@","];
                             }
                             
                             //build the filter ID
                             filterID = [NSString stringWithFormat:@"%@:%@", value, argsString];
                             
                             //remove the filter command from the log message
                             result = [result stringByReplacingCharactersInRange:match.range withString:@""];
                             
                             *stop = YES;
    }];
    
    //file filter
    if ([value hasSuffix:@".m"] || [value hasSuffix:@".mm"]) {
        
        if ([command isEqualToString:@"filter"]) {
            //add file filter
            filter.type = MTLogFilterTypeFileName;
            filter.value = value;
            filter.args = args;
            _pendingFilters[filterID] = filter;
            
        } else if ([command isEqualToString:@"unfilter"]) {
            //remove file filter
            [_filters removeObjectForKey: filterID];
            
        }
        
        return result;
    }
    
    return result;
}

-(void)log:(NSString*)fileName lineNr:(NSNumber*)lineNr text:(NSString *)format, ...
{
    if ([format hasPrefix:@"filter:"] || [format hasPrefix:@"unfilter:"]) format = [self parseFilter: format];
    
    for (MTLogFilter* filter in [_filters allValues]) {
        switch (filter.type) {
            case MTLogFilterTypeFileName:
                if ([fileName isEqualToString: filter.value]==NO) {
                    return;
                }
                break;
                
            default:
                break;
        }
    }
    
    format = [NSString stringWithFormat:@"%@:%@ > %@",fileName, lineNr, format];
    
    va_list args;
    va_start(args, format);
    NSLogv(format, args);
    va_end(args);
    
    if ([_pendingFilters count]>0) {
        [self mergePendingFilters];
    }
}

-(void)mergePendingFilters
{
    for (NSString* key in [_pendingFilters allKeys]) {
        _filters[key] = _pendingFilters[key];
        [_pendingFilters removeObjectForKey: key];
    }
}

@end
