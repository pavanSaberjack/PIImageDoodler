//
//  PIDrawingScreenVC.m
//  PIImageDoodler
//
//  Created by Pavan on 19/05/17.
//  Copyright © 2017 Pavan Itagi. All rights reserved.
//

#import "PIDrawingScreenVC.h"
#import "PIColorPickerController.h"
#import "PIDrawerView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MBProgressHUD.h"

@interface PIDrawingScreenVC () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, PIColorPickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *selectedColorButton;
@property (weak, nonatomic) IBOutlet UIButton *eraseButton;
@property (weak, nonatomic) IBOutlet UIButton *drawButton;
@property (weak, nonatomic) IBOutlet PIDrawerView *drawerView;
@property (weak, nonatomic) IBOutlet UIImageView *drawViewBackground;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, strong) UIColor *selectedColor;

@end

@implementation PIDrawingScreenVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.selectedColorButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.selectedColorButton.layer setBorderWidth:5.0];
    [self.selectedColorButton.layer setCornerRadius:3.0];
    
    self.selectedColor = [UIColor redColor];
    [self.selectedColorButton setBackgroundColor:self.selectedColor];
    [self.drawerView setSelectedColor:self.selectedColor];
    
    
    [self.drawerView setDrawingMode:DrawingModePaint];
    self.drawButton.alpha = 1.0f;
    self.eraseButton.alpha = 0.5f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeBackground:(id)sender
{
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:@"Select an amazing background for your doodle"      //  Must be "nil", otherwise a blank title area will appear above our two buttons
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* button0 = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                              handler:^(UIAlertAction * action) {
                                  //  UIAlertController will automatically dismiss the view
                                  
                              }];
    
    UIAlertAction* button1 = [UIAlertAction
                              actionWithTitle:@"Take photo"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  //  The user tapped on "Take a photo"
                                  UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
                                  imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                                  imagePickerController.delegate = self;
                                  [self presentViewController:imagePickerController animated:YES completion:^{}];
                              }];
    
    UIAlertAction* button2 = [UIAlertAction
                              actionWithTitle:@"Choose Existing"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  //  The user tapped on "Choose existing"
                                  UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
                                  imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                  imagePickerController.delegate = self;
                                  [self presentViewController:imagePickerController animated:YES completion:^{}];
                              }];
    
    [alert addAction:button0];
    [alert addAction:button1];
    [alert addAction:button2];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)closePressed:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)savePressed:(UIButton *)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"Saving to your Photo album";
    
    UIGraphicsBeginImageContext(self.containerView.frame.size);
    [self.containerView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        hud.label.text = @"Saved ...";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
    });
}

- (IBAction)drawPressed:(UIButton *)sender
{
    [self.drawerView setDrawingMode:DrawingModePaint];
    
    self.drawButton.alpha = 1.0f;
    self.eraseButton.alpha = 0.5f;
}

- (IBAction)erasePressed:(UIButton *)sender
{
    [self.drawerView setDrawingMode:DrawingModeErase];
    
    self.eraseButton.alpha = 1.0f;
    self.drawButton.alpha = 0.5f;
}

- (IBAction)pickColor:(UIButton *)sender
{
    PIColorPickerController *colorPicker = [[PIColorPickerController alloc] initWithNibName:@"PIColorPickerController" bundle:nil];
    [colorPicker setDelegate:self];
    [colorPicker setCurrentSelectedColor:self.selectedColor];
    [self presentViewController:colorPicker animated:YES completion:nil];
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
#pragma mark - UIImagePickerControllerDelegate methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
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
    
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.drawViewBackground.image = img;
    
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
    [self.selectedColorButton setBackgroundColor:selectedColor];
    [self.drawerView setSelectedColor:selectedColor];
}

@end
