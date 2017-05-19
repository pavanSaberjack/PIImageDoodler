//
//  PIDrawingScreenVC.h
//  PIImageDoodler
//
//  Created by Pavan on 19/05/17.
//  Copyright © 2017 Pavan Itagi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PIDrawingScreenVCDelegate;
@interface PIDrawingScreenVC : UIViewController
@property (nonatomic, weak) id<PIDrawingScreenVCDelegate>delegate;
@end

@protocol PIDrawingScreenVCDelegate <NSObject>

- (void)didCreatNewDrawingForDrawingScreen:(PIDrawingScreenVC *)drawingScreen;

@end
