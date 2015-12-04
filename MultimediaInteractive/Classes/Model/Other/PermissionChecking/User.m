//
//  User.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/11.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import "User.h"
#import <objc/runtime.h>

@implementation User


#pragma mark - 归档 解档
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        unsigned int ivarsCount;
        Ivar *ivars = class_copyIvarList([self class], &ivarsCount);
        for (int i = 0; i < ivarsCount; i++) {
            Ivar ivar = ivars[i];
            NSString *name = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
            
            [self setValue:[aDecoder decodeObjectForKey:name] forKey:name];
            
        }
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    unsigned int ivarsCount;
    Ivar *ivars = class_copyIvarList([self class], &ivarsCount);
    for (int i = 0; i < ivarsCount; i++) {
        Ivar ivar = ivars[i];
        NSString *name = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
        
        [aCoder encodeObject:[self valueForKey:name] forKey:name];
    }
}

@end
