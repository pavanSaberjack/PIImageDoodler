//
//  UIView+CustomAnimation.h
//  PIImageDoodler
//
//  Created by Pavan on 19/05/17.
//  Copyright © 2017 Pavan Itagi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CustomAnimation)

+ (void)animateAcceleratedBounceEffectWithDuration:(NSTimeInterval)duration
                                             delay:(NSTimeInterval)delay
                            usingSpringWithDamping:(CGFloat)dampingRatio
                             initialSpringVelocity:(CGFloat)velocity
                                           options:(UIViewAnimationOptions)options
                                        animations:(void (^)(void))animations
                                        completion:(void (^)(BOOL finished))completion;
@end
