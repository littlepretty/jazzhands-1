## DIYJazzHands
#### Scratch-off images like woah.

### Basic Use

```objective-c
// Init with frame, touch target and completion selector
DIYJazzHands *scratchOff = [[DIYJazzHands alloc] initWithFrame:CGRectMake(0, 0, 100, 100) withTarget:self withAction:@selector(didScratchOff)];

// Set image
[scratchOff initContextWithImage:[UIImage imageNamed:@"gra_scratch_off_field@2x.png"]];

// Create zone for "scratching"
[scratchOff addLineAtPoint:CGPointMake(0, 0.5 * scratchOff.frame.size.height) toPoint:CGPointMake(scratchOff.frame.size.width, 0.5 * scratchOff.frame.size.height)];
    
// Add to view
[self.view addSubview:scratchOff];
```

```objective-c
- (void)didScratchOff
{
    NSLog(@"Scratch complete!");
}
```

### Methods
```objective-c
- (id)initWithFrame:(CGRect)frame withTarget:(id)aTarget withAction:(SEL)anAction;
- (void)addLineAtPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint;
- (void)initContextWithImage:(UIImage *)image;
```