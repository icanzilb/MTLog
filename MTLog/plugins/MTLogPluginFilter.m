//
//  MTLogPluginFilter.m
//  MTLogDemo
//
//  Created by Marin Todorov on 7/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "MTLogPluginFilter.h"

@implementation MTLogPluginFilter
{
    int _minLine;
    int _maxLine;
}

-(instancetype)initWithName:(NSString*)name value:(NSString*)value args:(NSArray*)args
{
    self = [super initWithName:name value:value args:args];
    if (self) {
        self.affectsFirstLogmessage = NO;
        if (args && args.count==2) {
            _minLine = [args[0] intValue];
            _maxLine = [args[1] intValue];
        }
    }
    return self;
}

-(NSString*)preProcessLogMessage:(NSString*)text env:(NSArray*)env
{
    //filter by file name
    if ([self.value hasSuffix:@".m"] || [self.value hasSuffix:@".mm"]) {
        if ([env[MTLogFileName] isEqualToString: self.value]==NO) {
            return nil;
        } else if (_maxLine>0) {
            
            //filter by code line number
            int curLine = [env[MTLogLineNumber] intValue];
            if ( curLine < _minLine || curLine > _maxLine ) {
                return nil;
            }
        }
    }
    
    //filter by method name
    else {
        if ([env[MTLogMethodName] isEqualToString: self.value]==NO) {
            return nil;
        }
    }
    
    return text;
}

@end
