//
//  SlidingGameContainerViewController.m
//  SlidingTilePuzzle
//
//  Created by Emma Steimann on 2/25/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import "SlidingGameContainerViewController.h"
#import "SlidingGameViewController.h"

@interface SlidingGameContainerViewController ()
@property (nonatomic, assign) BOOL gameIsLoaded;
@property (nonatomic, assign) NSInteger currentSize;
@property (nonatomic, strong) SlidingGameViewController *sGvC;
@property (nonatomic, strong) UILabel *sizeLabel;

@end

@implementation SlidingGameContainerViewController {
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.currentSize = 4;
  if (!_gameIsLoaded) {
    [self loadGame];
  }
  
  UIStepper *stepper = [[UIStepper alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
  stepper.value = self.currentSize;
  [stepper setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.width + 40)];
  [stepper addTarget:self action:@selector(stepChanged:) forControlEvents:UIControlEventValueChanged];

  [self.view addSubview:stepper];
  
  _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
  _sizeLabel.text = [NSString stringWithFormat:@"%ld", _currentSize];
  [_sizeLabel sizeToFit];
  [_sizeLabel setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.width + 80)];
  [self.view addSubview:_sizeLabel];

}

- (void)loadGame {
  self.sGvC = [[SlidingGameViewController alloc] initWithFrame:self.view.frame andSize:self.currentSize];
  
  [self addChildViewController:self.sGvC];
  [self.view addSubview:self.sGvC.view];
  [self.sGvC didMoveToParentViewController:self];
  _gameIsLoaded = YES;
}

- (void)stepChanged:(UIStepper *)sender {
  if (sender.value > 1) {
    self.currentSize = sender.value;
    [self.sGvC willMoveToParentViewController:nil];
    [self.sGvC.view removeFromSuperview];
    [self.sGvC removeFromParentViewController];
    _sizeLabel.text = [NSString stringWithFormat:@"%ld", _currentSize];
    [_sizeLabel sizeToFit];
    [self loadGame];
  }
}

@end
