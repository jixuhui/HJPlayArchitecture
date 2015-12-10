//
//  HJMultipleProxyBehavior.m
//  HJADemo
//
//  Created by jixuhui on 15/12/10.
//  Copyright © 2015年 Hubbert. All rights reserved.
//

#import "HJMultipleProxyBehavior.h"
#import <objc/runtime.h>

//转发目标类
@interface NoneClass : NSObject
@end

@implementation NoneClass
+(void)load
{
    NSLog(@"NoneClass _cmd: %@", NSStringFromSelector(_cmd));
}

- (void) noneClassMethod
{
    NSLog(@"_cmd: %@", NSStringFromSelector(_cmd));
}
@end

@interface HJMultipleProxyBehavior()

@property (nonatomic, strong) NSPointerArray *weakRefTargets;

@end

@implementation HJMultipleProxyBehavior

//全局函数
void dynamicMethodIMP(id self, SEL _cmd)
{
    NSLog(@"doesn't have resolveThisMethodDynamically,use me(dynamicMethodIMP)!");
}

//类函数
+ (BOOL) resolveInstanceMethod:(SEL)aSEL
{
    if (aSEL == NSSelectorFromString(@"resolveThisMethodDynamically"))
    {
        class_addMethod([self class], aSEL, (IMP) dynamicMethodIMP, "v@:");
        return YES;
    }
    return [super resolveInstanceMethod:aSEL];
}

//将消息转出某对象
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    NSLog(@"MyTestObject _cmd: %@", NSStringFromSelector(_cmd));
    
    NoneClass *none = [[NoneClass alloc] init];
    if ([none respondsToSelector: aSelector]) {
        return none;
    }
    
    return [super forwardingTargetForSelector: aSelector];
}

- (void)setDelegateTargets:(NSArray *)delegateTargets{
    self.weakRefTargets = [NSPointerArray weakObjectsPointerArray];
    for (id delegate in delegateTargets) {
        [self.weakRefTargets addPointer:(__bridge void *)delegate];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector{
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    for (id target in self.weakRefTargets) {
        if ([target respondsToSelector:aSelector]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSMethodSignature *sig = [super methodSignatureForSelector:aSelector];
    if (!sig) {
        for (id target in self.weakRefTargets) {
            if ((sig = [target methodSignatureForSelector:aSelector])) {
                break;
            }
        }
    }
    
    return sig;
}

//转发方法调用给所有delegate
- (void)forwardInvocation:(NSInvocation *)anInvocation{
    for (id target in self.weakRefTargets) {
        if ([target respondsToSelector:anInvocation.selector]) {
            [anInvocation invokeWithTarget:target];
        }
    }
}

- (void)doesNotRecognizeSelector:(SEL)aSelector{
    [super doesNotRecognizeSelector:aSelector];
    NSLog(@"The last resort!");
}

@end
