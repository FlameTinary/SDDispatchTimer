//
//  SDWeakProxy.h
//
//  Created by Sheldon on 2018/9/26.
//  Copyright © 2018年 Sheldon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDWeakProxy : NSProxy

/**
 The proxy target.
 */
@property (nonatomic, weak, readonly) id target;

/**
 Creates a new weak proxy for target.
 
 @param target Target object.
 
 @return A new proxy object.
 */
- (instancetype)initWithTarget:(id)target;

/**
 Creates a new weak proxy for target.
 
 @param target Target object.
 
 @return A new proxy object.
 */
+ (instancetype)proxyWithTarget:(id)target;

@end
