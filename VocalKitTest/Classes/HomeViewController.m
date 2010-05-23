//
//  HomeViewController.m
//  VocalKitTest
//
//  Created by lucy on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CommandCell.h"
#import "HomeViewController.h"
#import "ServerRequest.h"
#import "SBJSON.h"

@implementation HomeViewController

@synthesize audioPlayer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
      NSMutableArray *storedCommands = 
        [[NSUserDefaults standardUserDefaults] objectForKey:@"commands"];
      if (storedCommands != nil) {
        commands = [[NSMutableArray alloc] initWithArray:storedCommands];
      } else {
        commands = [[NSMutableArray alloc] init];        
      }
    }
    return self;
}

- (BOOL)isSupportedCommandType:(NSString *)commandType {
  if ([commandType isEqualToString:kWeatherCommandType] ||
      [commandType isEqualToString:kCookCommandType] ||
      [commandType isEqualToString:kBuyCommandType] ||
      [commandType isEqualToString:kWatchCommandType]) {
    return YES;
  }
  return NO;
}

- (IBAction)recordPressed:(id)sender {
	if (![vk isListening]) {
    [recordButton setBackgroundImage:[UIImage imageNamed:@"rec_on.png"] forState:UIControlStateNormal];
    [listening setHidden:NO];
		[vk startListening];
	} else {
    [recordButton setBackgroundImage:[UIImage imageNamed:@"rec.png"] forState:UIControlStateNormal];
    [listening setHidden:YES];
		[vk stopListening];
		[vk showListened];
		[vk postNotificationOfRecognizedText];
	}
}

- (IBAction)undoPressed:(id)sender {
  [self removeCommand:@""];
  [commandsTable reloadData];
}

- (IBAction)settingsPressed:(id)sender {
  
}

- (void)showCommands {
  [moreText setHidden:YES];
  [commandsTable setHidden:NO];  
}

- (void)showMoreText {
  [moreText setHidden:NO];
  [commandsTable setHidden:YES];
}

- (void)addCommand:(NSString *)command {
  ServerRequest *request = [[ServerRequest alloc] init];
  [request add:command delegate:self
    requestSelector:@selector(addCommandCallback:)
    errorSelector:@selector(errorCallback:)];
  [request release];
  
  [loading setHidden:NO];
  [loading startAnimating];
}

- (void)addCommandCallback:(NSData *)data {
  NSString *response = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  NSLog(@"addCommandCallback %@", response);
  
  SBJSON *jsonParser = [SBJSON new];
	id result = [jsonParser objectWithString:response error:NULL];
  [response release];

  NSLog(@"json result %@", result);
  NSString *commandType = [result valueForKey:@"command"];
  NSString *message = [result valueForKey:@"message"];
  if ([commandType isEqualToString:kWeatherCommandType]) {
    [self showCommands];
    [self speakCommand:message];
  } if ([commandType isEqualToString:kCookCommandType]) {
    if (![message isEqualToString:@""]) {
      moreText.text = message;
      [self showMoreText];
      [self speakCommand:message];
    } else {
      [self showCommands]; 
    }
  }

  [loading stopAnimating];
  [loading setHidden:YES];
}

- (void)removeCommand:(NSString *)command {
  NSString *commandToRemove = command;
  if ([commandToRemove isEqualToString:@""]) {
    commandToRemove = [commands lastObject];
    [commands removeLastObject];
  } else {
    [commands removeObject:commandToRemove];
  }
  // TODO: Send "remove" to server
}

- (void)removeCommandCallback:(NSData *)data {
  NSString *response = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  NSLog(@"removeCommandCallback %@", response);
  [response release];
}

- (void)errorCallback:(NSString *)message {
  [self speakCommand:@"connection failure"];
}

- (void)speakCommand:(NSString *)command {
  NSString *file = [NSString stringWithFormat:@"%@/test.wav",
        [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
  
	NSLog(@"Speakers = %@", [vkSpeaker speakers]);
	[vkSpeaker speakText:command toFile:file];
  
	NSURL *url = [NSURL fileURLWithPath:file];
	
  NSError *error;
  
  UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
  AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
  
  self.audioPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error] autorelease];
  audioPlayer.numberOfLoops = 0;
	
	[audioPlayer play];
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
}

#pragma mark  Notification updates
- (void) recognizedTextNotification:(NSNotification*)notification {
	NSDictionary *dict = [notification userInfo];
  
	NSString *command = [dict objectForKey:VKRecognizedPhraseNotificationTextKey];
  
  if ([command isEqualToString:@""]) {
    return;
  }

  // HACK: hardcode zipcode
  if ([command isEqualToString:@"WEATHER"]) {
    command = [command stringByAppendingString:@" 10002"];
  } else {
    [self speakCommand:command];    
  }
  
  NSLog(@"adding command %@", command);

  [commands addObject:[command lowercaseString]];
  [self addCommand:command];
  
  [commandsTable reloadData];
}

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

  commandsTable.delegate = self;
  commandsTable.dataSource = self;
  [commandsTable reloadData];
  
  [loading setHidden:YES];
  [listening setHidden:YES];
  [self showCommands];
}


- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
    
  // Release any cached data, images, etc that aren't in use.
}

- (void)viewWillDisappear:(BOOL)animated {
  [[NSUserDefaults standardUserDefaults] setObject:commands forKey:@"commands"];  
}

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void)dealloc {
  [vkSpeaker release];
  [commands release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDelegate and UITableViewDataSource

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *ident = @"CommandCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"CommandCell"] autorelease]; 
  }
  cell.textLabel.text = [commands objectAtIndex:indexPath.row];
  return cell;
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  tableView.allowsSelection = NO;
  return [commands count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *ident = @"CommandCell";
  CommandCell *cell = (CommandCell*) [tableView dequeueReusableCellWithIdentifier:ident];
  if (cell == nil) {
    NSArray *topLevelObjects = [[NSBundle mainBundle]
                                loadNibNamed:@"CommandCell"
                                owner:nil options:nil];
    for (id currentObject in topLevelObjects) {
      if ([currentObject isKindOfClass:[UITableViewCell class]]) {
        cell = (CommandCell *) currentObject;
        break;
      }
    }
  }
  
  NSString *command = [commands objectAtIndex:indexPath.row];
  cell.label.text = [commands objectAtIndex:indexPath.row];
  NSArray *tokens = [command componentsSeparatedByString:@" "];
  NSString *imageFile;
  if ([self isSupportedCommandType:[tokens objectAtIndex:0]]) {
    imageFile = [NSString stringWithFormat:@"%@.png", [tokens objectAtIndex:0]];
  } else {
    imageFile = @"unknown.png";
  }
  cell.icon.image = [UIImage imageNamed:imageFile];
  return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  NSLog(@"committeEditingStyle");
  // If row is deleted, remove it from the list.
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    // delete your data item here
    // Animate the deletion from the table.
    [commands removeObjectAtIndex:indexPath.row];

    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
  }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES; 
}


@end
