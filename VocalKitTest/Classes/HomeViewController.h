//
//  HomeViewController.h
//  VocalKitTest
//
//  Created by lucy on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKController.h"
#import "VKFliteSpeaker.h"
#import <AVFoundation/AVFoundation.h>

#define kWeatherCommandType   @"weather"
#define kCookCommandType      @"cook"
#define kBuyCommandType       @"buy"
#define kWatchCommandType     @"watch"

@interface HomeViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate> {
  IBOutlet UITableView *commandsTable;
  IBOutlet UIButton *recordButton;
  IBOutlet UIButton *undoButton;
  IBOutlet UIBarItem *settingsButton;
  IBOutlet UIBarItem *backButton;
  IBOutlet UITextView *moreText;
  IBOutlet UILabel *listening;
  IBOutlet UIActivityIndicatorView *loading;
  
  NSMutableArray *commands;

	VKController *vk;
	VKFliteSpeaker *vkSpeaker;
	AVAudioPlayer *audioPlayer;
}

@property (nonatomic, retain) AVAudioPlayer *audioPlayer;


- (IBAction)recordPressed:(id)sender;
- (IBAction)undoPressed:(id)sender;
- (IBAction)settingsPressed:(id)sender;
- (IBAction)backPressed:(id)sender;

- (void)addCommand:(NSString *)command;
- (void)removeCommand:(NSString *)command;

- (void)addCommandCallback:(NSData *)data;
- (void)removeCommandCallback:(NSData *)data;
- (void)errorCallback:(NSString *)message;

- (void)speakCommand:(NSString *)command;

- (BOOL)isSupportedCommandType:(NSString *)commandType;
- (void)showCommands;
- (void)showMoreText;

@end
