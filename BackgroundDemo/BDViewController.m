//
//  BDViewController.m
//  Bluetooth Beacon Background Demo
//

// Configure a Raspberry Pi as a bluetooth beacon using the following commands:
// sudo hcitool -i hci0 cmd 0x08 0x0008 1F 02 01 1A 03 03 71 1E 17 FF 06 06 E2 0A 39 F4 73 F5 4B C4 A1 2F 17 D1 AD 07 A9 61 01 00 02 00 00
// sudo hcitool hci0 leadv 3

#import "BDViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface BDViewController () <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) NSMutableArray *cbArray;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) IBOutlet UILabel *majorLabel;
@property (nonatomic, strong) IBOutlet UILabel *beaconLabel;
@property (nonatomic, strong) IBOutlet UILabel *minorLabel;
@property (nonatomic, strong) IBOutlet UILabel *powerLabel;
@end

@implementation BDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cbArray = [NSMutableArray array];
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            NSLog(@"CoreBluetooth BLE hardware is powered off");
            break;
        case CBCentralManagerStatePoweredOn:
        {
            //NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
            
            NSArray<CBUUID *> *ids = @[[CBUUID UUIDWithString:@"1E71"]];
            [self.centralManager scanForPeripheralsWithServices:ids options:options];
            break;
        }
        case CBCentralManagerStateResetting:
            //NSLog(@"CoreBluetooth BLE hardware is resetting");
            break;
        case CBCentralManagerStateUnauthorized:
            //NSLog(@"CoreBluetooth BLE state is unauthorized");
            break;
        case CBCentralManagerStateUnknown:
            //NSLog(@"CoreBluetooth BLE state is unknown");
            break;
        case CBCentralManagerStateUnsupported:
            //NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    if (advertisementData && [advertisementData objectForKey:@"kCBAdvDataManufacturerData"]) {
        
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            NSLog(@"\n\n\n****** FOUND BEACON While in the Background!!! **********");
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
            notification.alertBody = @"Beacon Found While in Background!";
            notification.timeZone = [NSTimeZone defaultTimeZone];
            notification.soundName = UILocalNotificationDefaultSoundName;
            notification.applicationIconBadgeNumber = 1;
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
        else {
            NSLog(@"\n\n\n****** FOUND BEACON **********");

            NSData *adverData = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
            NSDictionary *adverDict = [self getBeaconInfoFromData:adverData];
    
            CBUUID *uuid = [adverDict objectForKey:@"uuid"];

            self.beaconLabel.text = uuid.UUIDString;
            self.majorLabel.text = [NSString stringWithFormat:@"%@", [adverDict objectForKey:@"major"]];
            self.minorLabel.text = [NSString stringWithFormat:@"%@", [adverDict objectForKey:@"minor"]];
            self.powerLabel.text = [NSString stringWithFormat:@"%@", [adverDict objectForKey:@"power"]];

            self.beaconLabel.alpha = 1;
            self.majorLabel.alpha = 1;
            self.minorLabel.alpha = 1;
            self.powerLabel.alpha = 1;
            [UIView animateWithDuration:2.0 animations:^{
                self.beaconLabel.alpha = 0;
                self.majorLabel.alpha = 0;
                self.minorLabel.alpha = 0;
                self.powerLabel.alpha = 0;
            }];
        }
    }
}

- (NSDictionary *)getBeaconInfoFromData:(NSData *)data
{
    int manufacturerLength = 2;
    int uuidLength = 16;
    int majorLength = 2;
    int minorLength = 2;
//    int powerLength = 1;
    NSRange uuidRange = NSMakeRange(manufacturerLength, uuidLength);
    NSRange majorRange = NSMakeRange(manufacturerLength + uuidLength, majorLength);
    NSRange minorRange = NSMakeRange(manufacturerLength + uuidLength + majorLength , minorLength);
//    NSRange powerRange = NSMakeRange(manufacturerLength + uuidLength + majorLength + minorLength, powerLength);
    
    Byte uuidBytes[uuidLength];
    [data getBytes:&uuidBytes range:uuidRange];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDBytes:uuidBytes];

    int16_t majorBytes;
    [data getBytes:&majorBytes range:majorRange];
    int16_t majorBytesBig = (majorBytes >> 8) | (majorBytes << 8);
    
    int16_t minorBytes;
    [data getBytes:&minorBytes range:minorRange];
    int16_t minorBytesBig = (minorBytes >> 8) | (minorBytes << 8);
    
    int8_t powerByte;
    powerByte = 0;
//    [data getBytes:&powerByte range:powerRange];
    
    return @{ @"uuid" : uuid, @"major" : @(majorBytesBig), @"minor" : @(minorBytesBig), @"power" : @(powerByte) };
}

@end
