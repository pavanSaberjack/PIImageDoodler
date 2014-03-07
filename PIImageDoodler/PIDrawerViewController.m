//
//  PIDrawerViewController.m
//  PIImageDoodler
//
//  Created by Pavan Itagi on 07/03/14.
//  Copyright (c) 2014 Pavan Itagi. All rights reserved.
//

#import "PIDrawerViewController.h"
#import "PIDrawerView.h"
#import "PIColorPickerController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface PIDrawerViewController () <UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, PIColorPickerControllerDelegate>
@property (weak, nonatomic) IBOutlet PIDrawerView *drawerView;
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *pickImageButton;
@property (weak, nonatomic) IBOutlet UIButton *pickColorButton;
@property (weak, nonatomic) IBOutlet UIButton *pickEraserButton;
@property (weak, nonatomic) IBOutlet UIButton *writeButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (nonatomic, strong) UIColor *selectedColor;

- (IBAction)pickImageButtonPressed:(id)sender;
- (IBAction)pickColorButtonPressed:(id)sender;
- (IBAction)pickEraserButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)writeButtonPressed:(id)sender;
@end

@implementation PIDrawerViewController

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
    
    [self.pickColorButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.pickColorButton.layer setBorderWidth:5.0];
    [self.pickColorButton.layer setCornerRadius:3.0];
    
    self.selectedColor = [UIColor redColor];
    [self.pickColorButton setBackgroundColor:self.selectedColor];
    [self.drawerView setSelectedColor:self.selectedColor];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Action methods
- (IBAction)pickImageButtonPressed:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Pick" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Pick From Library",nil];
    [actionSheet showInView:self.view];
}

- (IBAction)pickColorButtonPressed:(id)sender
{
    PIColorPickerController *colorPicker = [[PIColorPickerController alloc] initWithNibName:@"PIColorPickerController" bundle:nil];
    [colorPicker setDelegate:self];
    [colorPicker setCurrentSelectedColor:self.selectedColor];
    [self.navigationController pushViewController:colorPicker animated:YES];
}

- (IBAction)pickEraserButtonPressed:(id)sender
{
    [self.drawerView setDrawingMode:DrawingModeErase];
}

- (IBAction)saveButtonPressed:(id)sender
{
    
}

- (IBAction)writeButtonPressed:(id)sender
{
    [self.drawerView setDrawingMode:DrawingModePaint];
}

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = self;
    [self presentViewController:mediaUI animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = nil;
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    else
    {
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
        {
            image = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        }
    }
    
    self.backGroundImageView.image = image;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PIColorPickerControllerDelegate methods
- (void)colorSelected:(UIColor *)selectedColor
{
    self.selectedColor = selectedColor;
    [self.pickColorButton setBackgroundColor:selectedColor];    
    [self.drawerView setSelectedColor:selectedColor];
}
@end
