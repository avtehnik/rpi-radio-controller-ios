//
//  RCViewController.m
//  Radio controller
//
//  Created by av_tehnik on 9/15/13.
//  Copyright (c) 2013 vitaliy pitvalo. All rights reserved.
//

#import "RCViewController.h"
#import <RestKit/RestKit.h>
#import "RCStation.h"
#import <GCDAsyncUdpSocket.h>

@interface RCViewController ()
@property (strong, nonatomic) NSArray *stations;
@end

@implementation RCViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self loadArticles];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)loadArticles
{
    
    RKObjectMapping* articleMapping = [RKObjectMapping mappingForClass:[RCStation class]];
    [articleMapping addAttributeMappingsFromDictionary:@{
     @"name": @"name",
     @"f": @"frequency",
     @"type": @"type"
     }];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:articleMapping pathPattern:nil keyPath:@"" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    NSURL *URL = [NSURL URLWithString:@"http://192.168.1.5/stations.php"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        self.stations = mappingResult.array;
        [self.tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Operation failed with error: %@", error);
    }];
    
    [objectRequestOperation start];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    //here you check for PreCreated cell.

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    RCStation *station = [self.stations objectAtIndex:indexPath.row];
    cell.textLabel.text = [station name];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCStation *selectedValue = [self.stations objectAtIndex:indexPath.row];
    
    GCDAsyncUdpSocket *udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];

    NSArray *stringArray = [selectedValue.frequency componentsSeparatedByString:@"."];
    
    unsigned char *buffer = (unsigned char *) malloc(1);
    buffer[0] = [[stringArray objectAtIndex:0] intValue];
    buffer[1] = [[stringArray objectAtIndex:1] intValue];
    free(buffer);
    NSData *data = [NSData dataWithBytes:buffer length:1];
    
    [udpSocket sendData:data toHost:@"192.168.1.5" port:1093 withTimeout:-1 tag:1];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.stations count];
}

@end
