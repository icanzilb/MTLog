//
//  MTLogPluginSearch.m
//  MTLogDemo
//
//  Created by Marin Todorov on 8/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "MTLogPluginSearch.h"

@implementation MTLogPluginSearch

-(NSString*)preProcessLogMessage:(NSString *)text env:(NSArray *)env
{
    if ([text rangeOfString: self.args.firstObject].location != NSNotFound) {
        if ([self.value isEqualToString:@"clear"]) {
            NSMutableString* string = [@"" mutableCopy];
            for (int i=0;i<20;i++) {
                [string appendString:@" \n"];
            }
            NSLog(@"%@", [string copy]);
        }
    }
    
    return [NSString stringWithFormat:@"%@\n", text];
}

-(void)postProcessLogMessage:(NSString *)text env:(NSArray *)env
{
    if ([text rangeOfString: self.args.firstObject].location != NSNotFound) {
        if ([self.value isEqualToString:@"throw"]) {
            @try {
                @throw [NSException exceptionWithName:self.value reason:text userInfo:nil];
            }
            @catch (NSException *exception) {
                //
            }
        }
    }
}

@end
