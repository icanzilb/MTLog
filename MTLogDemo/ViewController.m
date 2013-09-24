//
//  ViewController.m
//  MTLogDemo
//
//  Created by Marin Todorov on 7/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "ViewController.h"
#import "MTLogPluginRoute.h"

@interface ViewController ()
@end

@implementation ViewController

-(IBAction)actionBasicLogMessages
{
    NSLog(@"Simple Message 1");
    NSLog(@"Current date: %@",[NSDate date]);
}

-(IBAction)actionCustomPrefix:(id)sender
{
    NSLog(@"_prefix:set([custom prefix!]) Message Log 1");
    NSLog(@"_prefix:use([$file $line]) Message Log 2");
    NSLog(@"Message Log 3");
    NSLog(@"_prefix:use()--------------------------------");
    for (int i=0;i<5;i++) {
        NSLog(@"_prefix:set($counter.) Count count count ...");
    }
    NSLog(@"_prefix:set(default)");
}

-(void)extraLogMessages
{
    NSLog(@"Message 3");
    NSLog(@"Message 4");
}

-(IBAction)actionFilter:(id)sender
{
    NSLog(@"Filter all messages outside actionFilter: method");
    
    NSLog(@"_filter:actionFilter:");
    NSLog(@"Message 1");
    NSLog(@"Message 2");
    [self extraLogMessages];
    NSLog(@"Message 5");
    NSLog(@"_remove:_filter:actionFilter:");
}

-(IBAction)actionClearOnSearchResult:(id)sender
{
    NSLog(@"_search:clear(vacation)");
    NSLog(@"Go in vacation.");
    NSLog(@"I go home.");
    NSLog(@"_remove:_search:clear(vacation)");
}

-(IBAction)actionSaveToFile:(id)sender
{
    NSLog(@"_route:file(log.txt)");
    
    NSLog(@"Message 1");
    NSLog(@"Message 2");
    
    NSString* logPath = [(MTLogPluginRoute*)[MTLog pluginsByName:@"route"].firstObject logFilePath];
    
    [[[UIAlertView alloc] initWithTitle:@"Log file saved"
                                message:[NSString stringWithFormat:@"The log file is located at %@", logPath]
                               delegate:nil
                      cancelButtonTitle:@"Close"
                      otherButtonTitles:nil] show];
    
    NSLog(@"_remove:_route:file(log.txt)");
}

-(IBAction)actionOpenGitHub:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://github.com/icanzilb/MTLog"]];
}


@end
