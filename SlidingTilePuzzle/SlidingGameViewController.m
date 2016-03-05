//
//  SlidingGameViewController.m
//  SlidingTilePuzzle
//
//  Created by Emma Steimann on 2/25/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import "SlidingGameViewController.h"
#import "SlidingTileViewController.h"

@interface SlidingGameViewController ()
@property (nonatomic, assign) NSInteger gameBoardSize;
@property (nonatomic, assign) NSInteger tileSize;
@property (nonatomic, strong) NSArray *gameMatrix;
@property (nonatomic, assign) CGRect gameFrame;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) NSMutableArray *currentTileSet;
@property (nonatomic, strong) NSMutableArray *savedSet;
@property (nonatomic, strong) NSMutableArray *initialOrderedArray;
@property (nonatomic, strong) NSArray *vectors;


@end

@implementation SlidingGameViewController

- (instancetype)initWithFrame:(CGRect)frame andSize:(NSInteger)gameBoardSize {
  if (self == [super init]) {
    self.gameBoardSize = gameBoardSize;
    self.vectors = @[@[@1,@0],@[@0,@1],@[@-1,@0],@[@0,@-1]];
    
    // Build the frame, make sure its a evenly divisible amount
    // Divide the screen into it's appropriate X*X sizes
    
    [self createInitialOrderedArray];
    
    NSInteger roundedIntFrameWidth = (int)roundf(frame.size.width);
    if (roundedIntFrameWidth % 2 == 0) { roundedIntFrameWidth -= 1; }
    self.gameFrame = CGRectMake(0, 0, roundedIntFrameWidth, roundedIntFrameWidth);
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSwipe:)];
    self.tapGestureRecognizer.delegate = self;
    
    self.tileSize = roundedIntFrameWidth / gameBoardSize;
  }
  return self;
}


-(void)viewDidLoad {
  self.view.frame = self.gameFrame;
  [self.view setBackgroundColor:[UIColor redColor]];
  UILabel *currentWidth = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
  currentWidth.textColor = [UIColor blackColor];
  [self.view addSubview:currentWidth];
  
  [self buildTileSet];
  [self.view addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)createInitialOrderedArray {
  self.initialOrderedArray = [NSMutableArray array];
  NSInteger arraySize = self.gameBoardSize * self.gameBoardSize;
  for (NSInteger i = arraySize; i > 0; i--) {
    if (i == arraySize) {
      [self.initialOrderedArray insertObject:@0 atIndex:0];
    } else {
      [self.initialOrderedArray insertObject:[NSNumber numberWithInteger:i] atIndex:0];
    }
  }
}

- (void)buildTileSet {
  if (!self.gameMatrix) {
    [self createGameMatrix];
  }
}

- (void)createGameMatrix {
  NSMutableArray *newMatrix = [NSMutableArray arrayWithCapacity:self.gameBoardSize];
  NSMutableArray *numberArray = [[self randomizedNumberArray] mutableCopy];
  self.savedSet = [numberArray mutableCopy];
  for (int y = 0; y < self.gameBoardSize; y++) {
    newMatrix[y] = [NSMutableArray arrayWithCapacity:self.gameBoardSize];
    for (int x = 0; x < self.gameBoardSize; x++) {
      NSNumber *numberToAdd = [numberArray firstObject];
      [newMatrix[y] addObject:numberToAdd];
      [numberArray removeObjectAtIndex:0];
      
      [self loadTileWithPosition:CGPointMake(x * self.tileSize, y * self.tileSize) withNumber:numberToAdd];
    }
  }
  
  self.gameMatrix = newMatrix;
  
}

- (void)loadTileWithPosition:(CGPoint)point withNumber:(NSNumber *)number {
  if (!self.currentTileSet) { self.currentTileSet = [NSMutableArray array]; }
  
  SlidingTileViewController *newTile = [[SlidingTileViewController alloc] initWithFrame:CGRectMake(point.x, point.y, self.tileSize, self.tileSize) andNumber:number];
  
  [self addChildViewController:newTile];
  [self.view addSubview:newTile.view];
  [newTile didMoveToParentViewController:self];
  
  [self.currentTileSet addObject:newTile];
}

- (NSArray *)randomizedNumberArray {
  // Take initial ordered array, find zero and swap it around randomly 30 times
  
  NSMutableArray *randomizedArray = [self.initialOrderedArray mutableCopy];
  NSInteger zerosIndex = [randomizedArray indexOfObject:@0];
  
  for (int i =0; i < 30; i++) {
    NSUInteger row = floor(zerosIndex / self.gameBoardSize);
    NSUInteger column = zerosIndex % self.gameBoardSize;
    
    NSMutableArray *validMoves = [NSMutableArray array];
    for (NSArray *vector in self.vectors) {
      NSInteger newX = row + [vector[0] integerValue];
      NSInteger newY = column + [vector[1] integerValue];
      if (newX >= 0 && newX < self.gameBoardSize) {
        if (newY >= 0 && newY < self.gameBoardSize) {
          // Is a valid position
          NSInteger swapPossible = [self resolveRowColumnToBoard:CGPointMake(newX, newY)];
          [validMoves addObject:[NSNumber numberWithInteger:swapPossible]];
        }
      }
    }
    
    NSUInteger swapIndex = arc4random() % [validMoves count];
    
    NSInteger moveIndex = [[validMoves objectAtIndex:swapIndex] integerValue];
    NSNumber *swapNumber = [randomizedArray objectAtIndex:moveIndex];
    randomizedArray[zerosIndex] = swapNumber;
    randomizedArray[moveIndex] = @0;
    
    zerosIndex = moveIndex;
    
  }
  return randomizedArray;
}

- (NSInteger)resolveRowColumnToBoard:(CGPoint)point {
  return (point.x * self.gameBoardSize) + point.y;
}

- (void)respondToSwipe:(UISwipeGestureRecognizer *)recognizer {
  CGPoint location = [recognizer locationInView:self.view];
  UIView *view = [recognizer.view hitTest:location withEvent:nil];
  
  NSNumber *selectedTile = [NSNumber numberWithInteger:view.tag];
  
  if (![selectedTile isEqualToValue:@0]) {
    [self moveTileIfPossible:selectedTile];
    
  }
}

- (void)moveTileIfPossible:(NSNumber *)number {
  CGPoint xyLocation = [self getXYLocationInMatrix:number];
  // Check vectors
  for (NSArray *vector in self.vectors) {
    NSInteger newX = xyLocation.x + [vector[0] integerValue];
    NSInteger newY = xyLocation.y + [vector[1] integerValue];
    if (newX >= 0 && newX < self.gameBoardSize) {
      if (newY >= 0 && newY < self.gameBoardSize) {
        // Is a valid position
        if ([self.gameMatrix[newX][newY] isEqualToValue:@0]) {
          [self moveTileAt:xyLocation to:CGPointMake(newX, newY)];
        }
      }
    }
  }
}

- (void)moveTileAt:(CGPoint)pointA to:(CGPoint)pointB {
  
  NSNumber *savedAValue = self.gameMatrix[(int)pointA.x][(int)pointA.y];
  NSNumber *savedBValue = self.gameMatrix[(int)pointB.x][(int)pointB.y];

  self.gameMatrix[(int)pointB.x][(int)pointB.y] = savedAValue;
  self.gameMatrix[(int)pointA.x][(int)pointA.y] = savedBValue;
  
  NSInteger objAIndex = [self.savedSet indexOfObject:savedAValue];
  NSInteger objBIndex = [self.savedSet indexOfObject:savedBValue];
  
  
  
  if (objAIndex != -1 && objBIndex != -1) {
    SlidingTileViewController *sVcA = self.currentTileSet[objAIndex];
    CGRect sVcARect = sVcA.view.frame;
    SlidingTileViewController *sVcB = self.currentTileSet[objBIndex];
    CGRect sVcBRect = sVcB.view.frame;
    [UIView animateWithDuration:1.0f animations:^{
      [sVcA.view setFrame:CGRectMake(sVcBRect.origin.x, sVcBRect.origin.y, sVcBRect.size.width, sVcBRect.size.height)];
      [sVcB.view setFrame:CGRectMake(sVcARect.origin.x, sVcARect.origin.y, sVcARect.size.width, sVcARect.size.height)];
    }];
    
    self.currentTileSet[objAIndex] = sVcB;
    self.currentTileSet[objBIndex] = sVcA;

    self.savedSet[objAIndex] = savedBValue;
    self.savedSet[objBIndex] = savedAValue;
  }
  
  if ([self hasWon]) {
    UIAlertController *uAc = [UIAlertController alertControllerWithTitle:@"You Win!" message:@"Congratulations" preferredStyle:UIAlertControllerStyleAlert];
    [uAc addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:uAc animated:YES completion:nil];
  }
}

- (BOOL)hasWon {
  for (int i = 0; i < [self.initialOrderedArray count]; i++) {
    if (![self.savedSet[i] isEqualToNumber:self.initialOrderedArray[i]]) {
      return NO;
    }
  }
  return YES;
}

- (CGPoint)getXYLocationInMatrix:(NSNumber *)number {
  for (int y = 0; y < self.gameBoardSize; y++) {
    for (int x = 0; x < self.gameBoardSize; x++) {
      if ([self.gameMatrix[x][y] isEqualToNumber:number]) {
        return CGPointMake(x, y);
      }
    }
  }
  return CGPointMake(999, 999);
}

@end
