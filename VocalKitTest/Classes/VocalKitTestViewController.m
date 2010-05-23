//
//  VocalKitTestViewController.m
//  VocalKitTest
//
//  Created by Brian King on 4/29/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "GroceryListViewController.h"
#import "ServerRequest.h"
#import "SBJSON.h"
#import "VocalKitTestViewController.h"
#import "VKFliteSpeaker.h"

@implementation VocalKitTestViewController
@synthesize audioPlayer;

- (IBAction) recordOrStopPressed:(id)sender {
	if (![vk isListening]) {
		[listenButton setTitle:@"Recognize" forState:UIControlStateNormal];
		[vk startListening];
	} else {
		[listenButton setTitle:@"Listen" forState:UIControlStateNormal];
		[vk stopListening];
		[vk showListened];
		[vk postNotificationOfRecognizedText];
	}
}

/*
- (IBAction) speakPressed:(id)sender {	
	NSString *file = [NSString stringWithFormat:@"%@/test.wav", 
					  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
					  
	NSLog(@"Speakers = %@", [vkSpeaker speakers]);
	[vkSpeaker speakText:textView.text toFile:file];

	NSURL *url = [NSURL fileURLWithPath:file];
	
    NSError *error;

    self.audioPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error] autorelease];
    audioPlayer.numberOfLoops = 0;
	
	[audioPlayer play];
}
*/

- (IBAction) rejectPressed:(id)sender {
  [groceries removeLastObject];
  [textView setText:[groceries componentsJoinedByString:@"\n"]];
}

- (IBAction) donePressed:(id)sender {
  [textView resignFirstResponder];
}

- (IBAction) postPressed:(id)sender {
  // Send groceries list to server
  NSString *data = [groceries componentsJoinedByString:@","];
  ServerRequest *request = [[ServerRequest alloc] init];
  [request post:data delegate:self
   requestSelector:@selector(postCallback:)
     errorSelector:@selector(errorCallback:)];
  [request release];
  [loading startAnimating];
}

- (void)postCallback:(NSData *)data {
  NSString *response = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  NSLog(@"postCallback %@", response);
  [response release];
  [groceries removeAllObjects];
  [textView setText:@""];
  [loading stopAnimating];
}

- (void)errorCallback:(NSString *)message {
  NSLog(@"errorCallback %@", message);
  textView.text = message;
  [loading stopAnimating];
}

- (IBAction) listPressed:(id)sender {
  GroceryListViewController *controller =
    [[GroceryListViewController alloc] initWithNibName:@"GroceryListViewController" bundle:nil];
  [self presentModalViewController:controller animated:YES]; 
}

- (void)awakeFromNib {		
	// Allocate our singleton instance for the recorder & player object
	
	OSStatus error = AudioSessionInitialize(NULL, NULL, NULL, self);
	if (error) printf("ERROR INITIALIZING AUDIO SESSION! %i\n", (int)error);
	else 
	{
		UInt32 category = kAudioSessionCategory_PlayAndRecord;	
		error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
		if (error) printf("couldn't set audio category!");

		UInt32 inputAvailable = 0;
		UInt32 size = sizeof(inputAvailable);

		// we do not want to allow recording if input is not available
		error = AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &inputAvailable);
		if (error) printf("ERROR GETTING INPUT AVAILABILITY! %i\n", (int)error);
		if (!inputAvailable) {
			NSLog(@"No Input Available!");
		}

		error = AudioSessionSetActive(true); 
		if (error) printf("AudioSessionSetActive (true) failed");
	}

	//UIColor *bgColor = [[UIColor alloc] initWithRed:.39 green:.44 blue:.57 alpha:.5];
}

#pragma mark  Notification updates
- (void) recognizedTextNotification:(NSNotification*)notification {
	NSDictionary *dict = [notification userInfo];

	NSString *phrase = [dict objectForKey:VKRecognizedPhraseNotificationTextKey];

  if ([phrase isEqualToString:@""]) {
    return;
  }
  if ([phrase length] > 4 &&
      [[phrase substringToIndex:4] isEqualToString:@"BUY "]) {
    phrase = [phrase substringFromIndex:4];
  }
  NSLog(@"adding phrase %@", phrase);
  [groceries addObject:[phrase lowercaseString]]; // add to list
  
  [textView setText:[groceries componentsJoinedByString:@"\n"]];
  [rejectButton setHidden:NO];
  [postButton setHidden:NO];
	//[textView setText:phrase];  
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	vk = [[VKController alloc] initWithType:VKDecoderTypePocketSphinx 
								 configFile:[[NSBundle mainBundle] pathForResource:@"pocketsphinx" 
																			ofType:@"conf"
																	   inDirectory:@"model"]];

	[vk setConfigString:[[NSBundle mainBundle] pathForResource:@"commands"
														ofType:@"dic"
												   inDirectory:@"model/lm/groceries"]
				 forKey:@"-dict"];

	[vk setConfigString:[[NSBundle mainBundle] pathForResource:@"commands"
														ofType:@"lm"
												   inDirectory:@"model/lm/groceries"]
				 forKey:@"-lm"];
	
	

	[vk setConfigString:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"model/hmm/hub4wsj_sc_8k"]
				 forKey:@"-hmm"];	
	
	NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
	[dnc addObserver:self 
			selector:@selector(recognizedTextNotification:) 
				name:VKRecognizedPhraseNotification 
			  object:nil];
	
	vkSpeaker = [[VKFliteSpeaker alloc] init];
  
  [self.navigationController.navigationBar addSubview:loading];
  [loading startAnimating];
  
  groceries = [[NSMutableArray alloc] init];
  [rejectButton setHidden:YES];
  [postButton setHidden:YES];
  [loading setHidden:YES];
  [self.view bringSubviewToFront:loading];
  [textView resignFirstResponder];

  NSLog(@"my number %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"SBFormattedPhoneNumber"]);
}

- (BOOL)textView:(UITextView *)t shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {  
  if([text isEqualToString:@"\n"]) {
    [t resignFirstResponder];
    return NO;
  }
  return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)t {
  [t resignFirstResponder];
  return TRUE;
}

- (void)textViewDidEndEditing:(UITextView *)t {
  [t resignFirstResponder];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
  [vkSpeaker release];
  [groceries release];
  [super dealloc];
}

@end
