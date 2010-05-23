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

@interface HomeViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
  IBOutlet UITableView *commandsTable;
  IBOutlet UIButton *recordButton;
  IBOutlet UIButton *undoButton;
  IBOutlet UIBarItem *settingsButton;
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

- (void)addCommand:(NSString *)command;
- (void)removeCommand:(NSString *)command;

- (void)addCommandCallback:(NSData *)data;
- (void)removeCommandCallback:(NSData *)data;
- (void)errorCallback:(NSString *)message;

- (void)speakCommand:(NSString *)command;

@end
