/***************************************************************************
* Copyright (C) 2023 ETH Zurich
* Core AI & Digital Biomarker, Acoustic and Inflammatory Biomarkers (ADAMMA)
* Centre for Digital Health Interventions (c4dhi.org)
* 
* Authors: Patrick Langer, Francesco Feher
* 
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
* 
*         http://www.apache.org/licenses/LICENSE-2.0
* 
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
***************************************************************************/

/*

 Copyright (C) 2016 Apple Inc. All Rights Reserved.

 See LICENSE.txt for this sample’s licensing information

 

 Abstract:

 Basic demonstration of how to use the SystemConfiguration Reachablity APIs.

 */

 

#import <Foundation/Foundation.h>

#import <SystemConfiguration/SystemConfiguration.h>

#import <netinet/in.h>

 

 

typedef enum : NSInteger {

    NotReachable = 0,

    ReachableViaWiFi,

    ReachableViaWWAN

} NetworkStatus;

 

#pragma mark IPv6 Support

//Reachability fully support IPv6.  For full details, see ReadMe.md.

 

 

extern NSString *kReachabilityChangedNotification;

 

 

@interface Reachability : NSObject

 

/*!

 * Use to check the reachability of a given host name.

 */

+ (instancetype)reachabilityWithHostName:(NSString *)hostName;

 

/*!

 * Use to check the reachability of a given IP address.

 */

+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress;

 

/*!

 * Checks whether the default route is available. Should be used by applications that do not connect to a particular host.

 */

+ (instancetype)reachabilityForInternetConnection;

 

 

#pragma mark reachabilityForLocalWiFi

//reachabilityForLocalWiFi has been removed from the sample.  See ReadMe.md for more information.

//+ (instancetype)reachabilityForLocalWiFi;

 

/*!

 * Start listening for reachability notifications on the current run loop.

 */

- (BOOL)startNotifier;

- (void)stopNotifier;

 

- (NetworkStatus)currentReachabilityStatus;

 

/*!

 * WWAN may be available, but not active until a connection has been established. WiFi may require a connection for VPN on Demand.

 */

- (BOOL)connectionRequired;

 

@end