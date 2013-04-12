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
    [self.scratchOff initContextWithImage:[UIImage imageNamed:@"gra_scratch_off_field@2x.png"]];
    
    // Add target lines to scratchOff
    [self.scratchOff addLineAtPoint:CGPointMake(0, 0.5 * self.scratchOff.frame.size.height) toPoint:CGPointMake(self.scratchOff.frame.size.width, 0.5 * self.scratchOff.frame.size.height)];
    
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
    NSLog(@"Scratch complete!");
    
    [UIView animateWithDuration:0.5f animations:^{
        self.scratchOff.alpha = 0.0f;
    }];
}


#pragma mark - Dealloc

- (void)releaseObjects
{
    _scratchOff = nil;
    _scratchedOff = nil;
}

- (void)dealloc
{
    [self releaseObjects];
}

@end
