//
//  MTLog.h
//
//  Created by Marin Todorov on 3/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MTLog( s, ... ) [MTLog log: \
[[NSString stringWithUTF8String:__FILE__] lastPathComponent]\
lineNr: [NSNumber numberWithInt:__LINE__]\
text: [NSString stringWithFormat:(s), ##__VA_ARGS__]\
]\


#define NSLog( s, ... )		MTLog( s, ##__VA_ARGS__ )

@interface MTLog : NSObject

+(void)log:(NSString*)fileName lineNr:(NSNumber*)lineNr text:(NSString *)format, ...;

@end
