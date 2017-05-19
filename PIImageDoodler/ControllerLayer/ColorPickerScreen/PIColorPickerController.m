//
//  PIColorPickerController.m
//  PIImageDoodler
//
//  Created by Pavan Itagi on 07/03/14.
//  Copyright (c) 2014 Pavan Itagi. All rights reserved.
//

#import "PIColorPickerController.h"

@interface PIColorPickerController ()
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UISlider *redColorSlider;
@property (weak, nonatomic) IBOutlet UISlider *greenColorSlider;
@property (weak, nonatomic) IBOutlet UISlider *blueColorSlider;
@property (weak, nonatomic) IBOutlet UISlider *alphaValueSlider;

@property (weak, nonatomic) IBOutlet UILabel *redColorValue;
@property (weak, nonatomic) IBOutlet UILabel *greenColorValue;
@property (weak, nonatomic) IBOutlet UILabel *blueColorValue;
@property (weak, nonatomic) IBOutlet UILabel *alphaValue;

@property (weak, nonatomic) IBOutlet UIImageView *resultColorImageView;

- (IBAction)backButtonPressed:(id)sender;

- (IBAction)redSliderMoved:(id)sender;
- (IBAction)greenSliderMoved:(id)sender;
- (IBAction)blueSliderMoved:(id)sender;
- (IBAction)alphaSliderMoved:(id)sender;

@end

@implementation PIColorPickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    const CGFloat *_components = CGColorGetComponents(self.currentSelectedColor.CGColor);
    CGFloat red     = _components[0];
    CGFloat green = _components[1];
    CGFloat blue   = _components[2];
    CGFloat alpha = _components[3];
    
    self.redColorSlider.value = red;
    self.greenColorSlider.value = green;
    self.blueColorSlider.value = blue;
    self.alphaValueSlider.value = alpha;
    
    [self.redColorValue setText:[NSString stringWithFormat:@"%.2f",red]];
    [self.greenColorValue setText:[NSString stringWithFormat:@"%.2f",green]];
    [self.blueColorValue setText:[NSString stringWithFormat:@"%.2f",blue]];
    [self.alphaValue setText:[NSString stringWithFormat:@"%.2f",alpha]];
    
    [self.resultColorImageView setBackgroundColor:self.currentSelectedColor];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods
- (void)setResultColor
{
    CGFloat r = self.redColorSlider.value;
    CGFloat g = self.greenColorSlider.value;
    CGFloat b = self.blueColorSlider.value;
    CGFloat a = self.alphaValueSlider.value;
    
    [self.resultColorImageView setBackgroundColor:[UIColor colorWithRed:r green:g blue:b alpha:a]];
    
    [self.redColorValue setText:[NSString stringWithFormat:@"%.2f",r]];
    [self.greenColorValue setText:[NSString stringWithFormat:@"%.2f",g]];
    [self.blueColorValue setText:[NSString stringWithFormat:@"%.2f",b]];
    [self.alphaValue setText:[NSString stringWithFormat:@"%.2f",a]];
}

#pragma mark - Button action methods
- (IBAction)backButtonPressed:(id)sender
{
    UIColor *color = self.resultColorImageView.backgroundColor;
    [self.delegate colorSelected:color];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)redSliderMoved:(id)sender
{
    [self setResultColor];
}

- (IBAction)greenSliderMoved:(id)sender
{
    [self setResultColor];
}

- (IBAction)blueSliderMoved:(id)sender
{
    [self setResultColor];
}

- (IBAction)alphaSliderMoved:(id)sender
{
    [self setResultColor];
}

@end
