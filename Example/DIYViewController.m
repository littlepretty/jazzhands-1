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

@synthesize scratchoff = _scratchoff;

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
    self.scratchoff = [[DIYJazzHands alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withTarget:self withAction:@selector(didScratchOff)];
    self.scratchoff.bgColor = [UIColor grayColor];
    self.scratchoff.touchColor = [UIColor clearColor];
    self.scratchoff.touchSize = 10;
    [self.scratchoff initContext];
    
    [self.view addSubview:self.scratchoff];
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
    [self.scratchoff release]; _scratchoff = nil;
}

- (void)dealloc
{
    [self releaseObjects];
    [super dealloc];
}

@end
