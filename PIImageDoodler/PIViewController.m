//
//  PIViewController.m
//  PIImageDoodler
//
//  Created by Pavan Itagi on 07/03/14.
//  Copyright (c) 2014 Pavan Itagi. All rights reserved.
//

#import "PIViewController.h"
#import "PIDrawerViewController.h"

@interface PIViewController ()
@property (weak, nonatomic) IBOutlet UIButton *startDrawingButton;

- (IBAction)startDrawing:(id)sender;
@end

@implementation PIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startDrawing:(id)sender
{
    PIDrawerViewController *drawerController = [[PIDrawerViewController alloc] initWithNibName:@"PIDrawerViewController" bundle:nil];
    [self.navigationController pushViewController:drawerController animated:YES];
}

@end
