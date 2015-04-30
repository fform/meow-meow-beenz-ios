//
//  FFMeowViewController.m
//  MeowMeowBeenz
//
//  Created by Will Froelich on 3/7/14.
//  Copyright (c) 2014 FFORM. All rights reserved.
//

#import "FFMeowViewController.h"
#import "FFHomeViewController.h"
#import "FFDetailViewController.h"
#import "FFAccountEditViewController.h"
#import <Parse/Parse.h>
#import "FFMeowLoader.h"
#import "FFMeowRating.h"
#import "FFUserCellView.h"

const NSUInteger kUsersPerPage = 25;

@interface FFMeowViewController ()

@property (strong, nonatomic) NSMutableArray *users;
@property (atomic) NSInteger currentOffset;
@property (atomic) bool maxUsers;
@property (strong, nonatomic) FFMeowLoader *loader;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (strong, nonatomic) NSMutableDictionary *avatarCache;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (strong, nonatomic) NSMutableArray *sections;
@property (strong, nonatomic) NSArray *sectionNames;
@property (strong, nonatomic) NSArray *sectionColors;
@end

@implementation FFMeowViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentOffset = 0;
    self.maxUsers = NO;
    CGRect frame = self.view.bounds;
    
    FFMeowLoader *loader = [[FFMeowLoader alloc] initWithFrame:CGRectMake(frame.size.width/2-50, frame.size.height/2-50, 100, 100)];
    self.loader = loader;
    [self.loadingLabel setHidden:YES];
    //[self.view addSubview:self.loader];

    [self.tableView setBackgroundColor:[UIColor colorWithRed:0.718 green:0.200 blue:0.329 alpha:1.0]];

    self.users = [[NSMutableArray alloc] init];
    self.avatarCache = [[NSMutableDictionary alloc] init];
    
    
    UIRefreshControl *rfc = [[UIRefreshControl alloc] init];
    [rfc addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [rfc setTintColor:[UIColor colorWithRed:1.000 green:0.984 blue:0.792 alpha:1.0]];
    self.refreshControl = rfc;
    
    [self fetchUserData:YES];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}
-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    //NSLog(@"Meow willAppear");
    [[self navigationController] setToolbarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)logoutAction:(id)sender {
    [FFUserCellView resetAvatars];
    self.currentOffset = 0;
    self.maxUsers = NO;
    [self.delegate logUserOut];
    [self.navigationController popViewControllerAnimated:YES];

}
- (IBAction)refreshTable:(id)sender {
    [self refresh];
}
-(void)refresh{
    [self.users removeAllObjects];
    [self.tableView reloadData];
    [self fetchUserData:YES];
}


- (IBAction)editAccount:(id)sender {
    
}

- (void)fetchUserData{
    [self fetchUserData: NO];
}
- (void)fetchUserData:(bool)reset{
    
    
    if(reset){
        self.currentOffset = 0;
        self.maxUsers = NO;
        self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top);
        [self.loadingLabel setHidden:NO];
    }else{
        self.currentOffset += 1;
        if(self.maxUsers){
            NSLog(@"Max Users");
            return;
        }
    }
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query selectKeys:@[@"username", @"displayname", @"email", @"rating"]];
    [query orderByDescending:@"rating"];
    [query setLimit:kUsersPerPage];
    [query setSkip: (self.currentOffset * kUsersPerPage)];
    
    self.loader.percentLoaded = 0.4;
    [self.progressBar setProgress:0.1];
    [self.progressBar setHidden:NO];

    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if( [users count] < kUsersPerPage ){
            self.maxUsers = YES;
        }
        [self.users addObjectsFromArray:users];
        [self.progressBar setProgress:1.0 animated:YES];
        [self.loadingLabel setHidden:YES];
        [self.tableView reloadData];
        

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            //NSLog(@"hide progress");
            [self.progressBar setHidden:YES];
            [self.refreshControl endRefreshing];
        });
    }];
}



- (float)ratingForUser:(PFObject *)user{

    if(user[@"rating"] ){
       return [user[@"rating"] floatValue];
    }

    return 1;
}

#pragma mark - Table view data sourcef

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.users count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{ 
    static NSString *CellIdentifier = @"Person";


    FFUserCellView *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[FFUserCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    if(indexPath.row == [self.users count] - 10){
        [self fetchUserData];
    }
    

    PFUser *user = self.users[indexPath.row];
    NSInteger rating = 5 -[[NSNumber numberWithFloat:MAX(1,floor( [self ratingForUser:user] ))] integerValue];
    
    cell.user =  user;
    cell.userID = user.objectId;
    cell.avatarView.image = nil;
    [self getAvatarForUser:user withCell:cell];
    cell.textLabel.text = user[@"displayname"] ? user[@"displayname"] : user[@"username"];
    cell.backgroundColor = self.sectionColors[rating];
    cell.rating =floor([self ratingForUser:user]);


    return cell;
}

- (void)getAvatarForUser:(PFUser *)user withCell:(FFUserCellView *)cell
{

    static double prevCallTime = 0;
    static double prevCallOffset = 0;
    static bool wasAboveThreshold = NO;
    
    //Simple velocity calculation
    double curCallTime = CACurrentMediaTime();
    double timeDelta = curCallTime - prevCallTime;
    double curCallOffset = self.tableView.contentOffset.y;
    double offsetDelta = curCallOffset - prevCallOffset;
    double velocity = fabs(offsetDelta / timeDelta);
    prevCallTime = curCallTime;
    prevCallOffset = curCallOffset;

    
    if( velocity < 200 ){
        
        if(wasAboveThreshold){
            //NSLog(@"Was fast, now slow enough. Loading %d cells", [[self.tableView visibleCells] count]);
            wasAboveThreshold = NO;
            for( FFUserCellView *cellItem in [self.tableView visibleCells] ){
                if( [cellItem class] == [FFUserCellView class] ){
                    [cellItem loadAvatarWithFetch:YES];
                }
            }
           // NSLog(@"--- Done With Late Fetch ---");
        }else{
            [cell loadAvatarWithFetch:YES];
        }
    
    }else{
        //NSLog(@"Too fast");
        wasAboveThreshold = YES;
        [cell loadAvatarWithFetch:NO];
    }
        

}


- (UIImage *)clipImage:(UIImage *)image
{
    return image;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"detailView"]){
        FFDetailViewController *dvc = [segue destinationViewController];
        NSIndexPath *index = [self.tableView indexPathForSelectedRow];
        dvc.user = self.users[ index.row];
        
    }else{
        //NSLog(@"Probably account settings");
        
    }
    
}


@end
