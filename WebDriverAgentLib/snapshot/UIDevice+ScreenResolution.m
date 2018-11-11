//
//  UIDevice+ScreenResolution.m
//  WebDriverAgentLib
//
//  Created by dl on 2018/11/11.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "UIDevice+ScreenResolution.h"
#import "sys/utsname.h"
#import "sys/sysctl.h"

@implementation UIDevice (ScreenResolution)

- (NSString *) deviceType {
  NSString *platformString = [self getPlatformString];
  NSDictionary *platformMap = [self platformInfoMap];
  __block NSString *result = platformString;
  [platformMap enumerateKeysAndObjectsUsingBlock:^(NSArray *key, NSDictionary *obj, BOOL * _Nonnull stop) {
    if ([key containsObject:platformString]) {
      result = obj.allKeys.firstObject;
      *stop = YES;
    }
  }];
  return result;
}

- (CGSize) screenResolution {
  if ([self isCurrentDeviceSimulator]) {
    CGFloat width = [[NSProcessInfo processInfo].environment[@"SIMULATOR_MAINSCREEN_WIDTH"] floatValue];
    CGFloat height = [[NSProcessInfo processInfo].environment[@"SIMULATOR_MAINSCREEN_HEIGHT"] floatValue];
    CGFloat scale = [[NSProcessInfo processInfo].environment[@"SIMULATOR_MAINSCREEN_SCALE"] floatValue];
    return CGSizeMake(width / scale, height / scale);
  }
  NSString *platformString = [self getPlatformString];
  NSDictionary *platformMap = [self platformInfoMap];
  __block NSString *result = NSStringFromCGSize(CGSizeMake(375.f, 667.f));
  [platformMap enumerateKeysAndObjectsUsingBlock:^(NSArray *key, NSDictionary *obj, BOOL * _Nonnull stop) {
    if ([key containsObject:platformString]) {
      result = obj.allValues.firstObject;
      *stop = YES;
    }
  }];
  return CGSizeFromString(result);
}

- (BOOL) isCurrentDeviceSimulator {
  struct utsname systemInfo;
  uname(&systemInfo);
  NSString* platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
  return [@[@"i386", @"x86_64"] containsObject:platform];
}

- (NSString *) getPlatformString {
  if ([self isCurrentDeviceSimulator]) {
    NSString *machineSwiftString = [NSProcessInfo processInfo].environment[@"SIMULATOR_MODEL_IDENTIFIER"];
    return machineSwiftString;
  } else {
    size_t size = 0;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *machineSwiftString = [NSString stringWithFormat:@"%s", machine];
    free(machine);
    return machineSwiftString;
  }
}

-(NSDictionary *) platformInfoMap {
  NSDictionary *platformMap = @{
    @[@"iPod5,1"]:                                      @{@"iPod Touch 5": @"{320,480}"},
    @[@"iPod7,1"]:                                      @{@"iPod Touch 6": @"{320,480}"},
    @[@"iPhone3,1",@"iPhone3,2",@"iPhone3,3"]:          @{@"iPhone 4": @"{320,480}"},
    @[@"iPhone4,1"]:                                    @{@"iPhone 4s": @"{320,480}"},
    @[@"iPhone5,1",@"iPhone5,2"]:                       @{@"iPhone 5": @"{320,568}"},
    @[@"iPhone5,3",@"iPhone5,4"]:                       @{@"iPhone 5c": @"{320,568}"},
    @[@"iPhone6,1",@"iPhone6,2"]:                       @{@"iPhone 5s": @"{320,568}"},
    @[@"iPhone7,2"]:                                    @{@"iPhone 6": @"{375,667}"},
    @[@"iPhone7,1"]:                                    @{@"iPhone 6 Plus": @"{414,736}"},
    @[@"iPhone8,1"]:                                    @{@"iPhone 6s": @"{375,667}"},
    @[@"iPhone8,2"]:                                    @{@"iPhone 6s Plus": @"{414,736}"},
    @[@"iPhone9,1",@"iPhone9,3"]:                       @{@"iPhone 7": @"{375,667}"},
    @[@"iPhone9,2",@"iPhone9,4"]:                       @{@"iPhone 7 Plus": @"{414,736}"},
    @[@"iPhone8,4"]:                                    @{@"iPhone SE": @"{320,568}"},
    @[@"iPhone10,1",@"iPhone10,4"]:                     @{@"iPhone 8": @"{375,667}"},
    @[@"iPhone10,2",@"iPhone10,5"]:                     @{@"iPhone 8 Plus": @"{414,736}"},
    @[@"iPhone10,3",@"iPhone10,6"]:                     @{@"iPhone X": @"{375,812}"},
    @[@"iPhone11,2"]:                                   @{@"iPhone XS": @"{375,812}"},
    @[@"iPhone11,4",@"iPhone11,6"]:                     @{@"iPhone XS Max": @"{375,896}"},
    @[@"iPhone11,8"]:                                   @{@"iPhone XR": @"{414,896}"},
//    @[@"iPad2,1",@"iPad2,2",@"iPad2,3",@"iPad2,4"]:     @{@"iPad 2": @""},
//    @[@"iPad3,1",@"iPad3,2",@"iPad3,3"]:                @{@"iPad 3": @""},
//    @[@"iPad3,4",@"iPad3,5",@"iPad3,6"]:                @{@"iPad 4": @""},
//    @[@"iPad4,1",@"iPad4,2",@"iPad4,3"]:                @{@"iPad Air": @""},
//    @[@"iPad5,3",@"iPad5,4"]:                           @{@"iPad Air 2": @""},
//    @[@"iPad6,11",@"iPad6,12"]:                         @{@"iPad 5": @""},
//    @[@"iPad7,5",@"iPad7,6"]:                           @{@"iPad 6": @""},
//    @[@"iPad2,5",@"iPad2,6",@"iPad2,7"]:                @{@"iPad Mini": @""},
//    @[@"iPad4,4",@"iPad4,5",@"iPad4,6"]:                @{@"iPad Mini 2": @""},
//    @[@"iPad4,7",@"iPad4,8",@"iPad4,9"]:                @{@"iPad Mini 3": @""},
//    @[@"iPad5,1",@"iPad5,2"]:                           @{@"iPad Mini 4": @""},
//    @[@"iPad6,3",@"iPad6,4"]:                           @{@"iPad Pro (9.7-inch)": @""},
//    @[@"iPad6,7",@"iPad6,8"]:                           @{@"iPad Pro (12.9-inch)": @""},
//    @[@"iPad7,1",@"iPad7,2"]:                           @{@"iPad Pro (12.9-inch) (2nd generation)": @""},
//    @[@"iPad7,3",@"iPad7,4"]:                           @{@"iPad Pro (10.5-inch)": @""},
//    @[@"iPad8,1",@"iPad8,2",@"iPad8,3",@"iPad8,4"]:     @{@"iPad Pro (11-inch)": @""},
//    @[@"iPad8,5",@"iPad8,6",@"iPad8,7",@"iPad8,8"]:     @{@"iPad Pro (12.9-inch) (3rd generation)": @""},
//    @[@"AudioAccessory1,1"]:                            @{@"HomePod": @""},
    @[@"i386",@"x86_64"]:                               @{@"Simulator": @"{375,667}"}
  };
  
  return platformMap;
}

@end
