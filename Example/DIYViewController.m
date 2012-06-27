//
//  DIYViewController.m
//  DIYJazzHands
//
//  Created by Jonathan Beilin on 6/26/12.
//  Copyright (c) 2012 DIY, Co. All rights reserved.
//

#import "DIYViewController.h"

@interface DIYViewController ()

@end

@implementation DIYViewController

@synthesize scratchOff = _scratchOff;
@synthesize scratchedOff = _scratchedOff;

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    // Add background image for scratchoff
    self.scratchedOff = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gra_scratched_off_field@2x.png"]];
    self.scratchedOff.frame = CGRectMake(196, 244, 199, 44);
    
    // Add scratchoff
    self.scratchOff = [[DIYJazzHands alloc] initWithFrame:self.scratchedOff.frame withTarget:self withAction:@selector(didScratchOff)];
//    self.scratchOff.bgColor = [UIColor grayColor];
//    self.scratchOff.touchColor = [UIColor clearColor];
    self.scratchOff.touchSize = 10;
    [self.scratchOff initContext];
    
    [self.view addSubview:self.scratchedOff];
    [self.view addSubview:self.scratchOff];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseObjects];
}

#pragma mark - JazzHands

- (void)didScratchOff
{
    NSLog(@"Scratch");
}


#pragma mark - Dealloc

- (void)releaseObjects
{
    [self.scratchOff release]; _scratchOff = nil;
    [self.scratchedOff release]; _scratchedOff = nil;
}

- (void)dealloc
{
    [self releaseObjects];
    [super dealloc];
}

@end
