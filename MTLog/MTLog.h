//
//  MTLog.h
//
//  Created by Marin Todorov on 3/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

//disable loggin on production
#ifdef DEBUG

#define MTLog( s, ... ) [MTLog log: \
[[NSString stringWithUTF8String:__FILE__] lastPathComponent]\
method: [NSString stringWithUTF8String:__PRETTY_FUNCTION__] \
lineNr: [NSNumber numberWithInt:__LINE__]\
text: [NSString stringWithFormat:(s), ##__VA_ARGS__]\
]

#define NSLog( s, ... )		MTLog( s, ##__VA_ARGS__ )

#endif

@interface MTLog : NSObject

+(void)log:(NSString*)fileName method:(NSString*)method lineNr:(NSNumber*)lineNr text:(NSString *)format, ...;

- (id)objectAtKeyedSubscript:(id <NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

@end