//
//  PIViewController.m
//  PIImageDoodler
//
//  Created by Pavan Itagi on 07/03/14.
//  Copyright (c) 2014 Pavan Itagi. All rights reserved.
//

#import "PIViewController.h"
#import "PIDrawingScreenVC.h"
#import "PIDoodleTableViewCell.h"

static NSString *cellIdentifier = @"DoodleCellIdentifier";

@interface PIViewController () <UITableViewDelegate, UITableViewDataSource, PIDrawingScreenVCDelegate>
@property (weak, nonatomic) IBOutlet UIButton *startDrawingButton;
@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property (weak, nonatomic) IBOutlet UITableView *doodlesTableView;

@property (strong, nonatomic) NSMutableArray<Doodle *> *myDoodlesArray;
@end

@implementation PIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initialSetup];
    [self fetchLocalDataAndUpdateUI];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startDrawing:(id)sender
{
    PIDrawingScreenVC *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PIDrawingScreenVC"];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (NSMutableArray<Doodle *> *)myDoodlesArray
{
    if (!_myDoodlesArray) {
        _myDoodlesArray = [NSMutableArray array];
    }
    
    return _myDoodlesArray;
}

#pragma mark - Private Interface methods
- (void)initialSetup
{
    // Register table cells
    [self.doodlesTableView registerNib:[UINib nibWithNibName:@"PIDoodleTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
}

- (void)fetchLocalDataAndUpdateUI
{
    [self.myDoodlesArray removeAllObjects];
    [self.myDoodlesArray addObjectsFromArray:[PIDataManager getStoredDoodles]];
    [self.doodlesTableView reloadData];
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // go for Detail
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.view.frame.size.width + 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 30.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = [UIColor clearColor];
    return v;
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.myDoodlesArray.count; // Temp
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Doodle *doodleObj = self.myDoodlesArray[indexPath.row];
    UIImage *img = [UIImage imageWithContentsOfFile:[PIHelper imagePathForDoodleWithUniqueId:doodleObj.uniqueId]];
    PIDoodleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.doodleImageView.image = img;
    return cell;
}

#pragma mark - PIDrawingScreenVCDelegate methods
- (void)didCreatNewDrawingForDrawingScreen:(PIDrawingScreenVC *)drawingScreen
{
    [self fetchLocalDataAndUpdateUI];
}

@end
