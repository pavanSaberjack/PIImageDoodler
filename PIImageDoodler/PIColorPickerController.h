//
//  PIColorPickerController.h
//  PIImageDoodler
//
//  Created by Pavan Itagi on 07/03/14.
//  Copyright (c) 2014 Pavan Itagi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PIColorPickerControllerDelegate <NSObject>
- (void)colorSelected:(UIColor *)selectedColor;
@end

@interface PIColorPickerController : UIViewController
@property (nonatomic, weak) id <PIColorPickerControllerDelegate>delegate;
@property (nonatomic, strong) UIColor *currentSelectedColor;
@end
