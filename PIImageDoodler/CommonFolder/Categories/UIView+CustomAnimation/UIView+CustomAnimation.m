//
//  UIView+CustomAnimation.m
//  PIImageDoodler
//
//  Created by Pavan on 19/05/17.
//  Copyright © 2017 Pavan Itagi. All rights reserved.
//

#import "UIView+CustomAnimation.h"

@implementation UIView (CustomAnimation)

+ (void)animateAcceleratedBounceEffectWithDuration:(NSTimeInterval)duration
                                             delay:(NSTimeInterval)delay
                            usingSpringWithDamping:(CGFloat)dampingRatio
                             initialSpringVelocity:(CGFloat)velocity
                                           options:(UIViewAnimationOptions)options
                                        animations:(void (^)(void))animations
                                        completion:(void (^)(BOOL finished))completion
{
    if (([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)) {
        [UIView animateWithDuration:duration delay:delay usingSpringWithDamping:dampingRatio initialSpringVelocity:velocity options:options animations:animations completion:completion];
    } else {
        [UIView animateWithDuration:duration delay:delay options:options animations:animations completion:completion];
    }
}

@end
