//
//  MTLogPluginFilter.m
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

#import "MTLogPluginFilter.h"
#import "MTLog.h"

@implementation MTLogPluginFilter
{
    BOOL _initialized;
    
    //filter by line numbers
    int _minLine;
    int _maxLine;
    
    //filter by file+line
    NSString* _fileName;
    int _fileLineNr;
}

+(NSRange)expectedNumberOfArgumentsForCommand:(NSString*)command
{
    return NSMakeRange(0, 2);
}

-(instancetype)initWithName:(NSString*)name value:(NSString*)value args:(NSArray*)args
{
    self = [super initWithName:name value:value args:args];
    if (self) {
        self.affectsFirstLogmessage = NO;
        if ([self.value isEqualToString:@"$this"]) {
            self.affectsFirstLogmessage = YES;
        }
        if (args && args.count==2) {
            _minLine = [args[0] intValue];
            _maxLine = [args[1] intValue];
        }
    }
    return self;
}

-(void)willEnableForLog:(MTLog*)log
{
    if ([self.value isEqualToString:@"$this"]) {
        
        //if a $this filter, remove all other filters
        NSMutableArray* matches = [@[] mutableCopy];
        for (MTLogPlugin* plugin in log.enabledPlugins) {
            if ([plugin isKindOfClass:[MTLogPluginFilter class]]) {
                [matches addObject: plugin];
                break;
            }
        }
        
        if (matches.count>0) {
            for (id plugin in matches) {
                [log.enabledPlugins removeObject: plugin];
            }
        }
    }
}

-(NSString*)preProcessLogMessage:(NSString*)text env:(NSArray*)env
{
    //initialize
    if (_initialized==NO) {
        if ([self.value isEqualToString:@"$this"]) {
            _fileName = env[MTLogFileName];
            _fileLineNr = [env[MTLogLineNumber] intValue];
        }
        
        _initialized=YES;
    }
    
    // 1. filter by file name
    if ([self.value hasSuffix:@".m"] || [self.value hasSuffix:@".mm"]) {
        if ([env[MTLogFileName] isEqualToString: self.value]==NO) {
            return @"";
        } else if (_maxLine>0) {
            
            //filter by code line number
            int curLine = [env[MTLogLineNumber] intValue];
            if ( curLine < _minLine || curLine > _maxLine ) {
                return @"";
            }
        }
        
    } else {
        
        // 2. filter by $this
        if ([self.value isEqualToString:@"$this"]) {
            if ( [_fileName isEqualToString: env[MTLogFileName]]==NO || _fileLineNr != [env[MTLogLineNumber] intValue] ) {
                return @"";
            }
        } else {
            
            //3. filter by method name
            if ([env[MTLogMethodName] isEqualToString: self.value]==NO) {
                return @"";
            }
            
        }
        
    }
    
    return text;
}

@end
