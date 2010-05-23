//
//  VocalKitTestViewController.h
//  VocalKitTest
//
//  Created by Brian King on 4/29/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKController.h"
//#import "VKFliteSpeaker.h"
#import <AVFoundation/AVFoundation.h>


@interface VocalKitTestViewController : UIViewController<UITextViewDelegate> {
	IBOutlet UITextView *textView;

	IBOutlet UIButton *listenButton;
//	IBOutlet UIButton *speakButton;
  IBOutlet UIButton *postButton;
  IBOutlet UIButton *rejectButton;
  IBOutlet UIBarItem *doneEditButton;
  IBOutlet UIBarItem *listButton;
  IBOutlet UIActivityIndicatorView *loading;
  
	VKController *vk;
	VKFliteSpeaker *vkSpeaker;
	
	AVAudioPlayer *audioPlayer;
  
  NSMutableArray *groceries;
}

@property (nonatomic, retain) AVAudioPlayer *audioPlayer;

- (IBAction) recordOrStopPressed:(id)sender;
//- (IBAction) speakPressed:(id)sender;
- (IBAction) postPressed:(id)sender;
- (IBAction) rejectPressed:(id)sender;
- (IBAction) donePressed:(id)sender;
- (IBAction) listPressed:(id)sender;

- (void)postCallback:(NSData *)data;
- (void)errorCallback:(NSString *)message;

@end

