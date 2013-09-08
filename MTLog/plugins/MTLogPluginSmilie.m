//
//  MTLogPluginSmilie.m
//  MTLogDemo
//
//  Created by Marin Todorov on 8/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "MTLogPluginSmilie.h"

@implementation MTLogPluginSmilie

-(NSString*)preProcessLogMessage:(NSString *)text env:(NSArray *)env
{
    NSString* smilie = @[@":)", @";)", @":D"][arc4random() % 3];
    return [NSString stringWithFormat:@"%@ %@", smilie, text];
}

@end
