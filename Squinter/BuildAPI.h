

//  Copyright (c) 2015 Tony Smith. All rights reserved.
//  Issued under MIT licence


#import <Foundation/Foundation.h>
#import "BuildAPIConstants.h"
#import "Connexion.h"


@interface BuildAPI : NSObject <NSURLConnectionDataDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

{
	NSMutableArray *_connexions;
	NSString *_logDevice, *_baseURL, *_currentModelID, *_logURL, *_lastStamp, *_harvey;
	BOOL _followOnFlag, _useSessionFlag;
}


// Initialization Methods

- (id)initForNSURLSession;
- (id)initForNSURLConnection;
- (void)clrk;
- (void)setk:(NSString *)harvey;

// Data Request Methods

- (void)getModels;
- (void)getModels:(BOOL)withDevices;
- (void)getDevices;
- (void)createNewModel:(NSString *)modelNam;
- (void)getCode:(NSString *)modelID;
- (void)getCodeRev:(NSString *)modelID :(NSInteger)build;
- (void)getLogsForDevice:(NSString *)deviceID :(NSString *)since :(BOOL)isStream;

// Action Methods

- (void)updateModel:(NSString *)modelID :(NSString *)key :(NSString *)value;
- (void)uploadCode:(NSString *)modelID :(NSString *)newDeviceCode :(NSString *)newAgentCode;
- (void)deleteModel:(NSString *)modelID;
- (void)assignDevice:(NSString *)deviceID toModel:(NSString *)modelID;
- (void)restartDevice:(NSString *)deviceID;
- (void)restartDevices:(NSString *)modelID;
- (void)deleteDevice:(NSString *)deviceID;
- (void)updateDevice:(NSString *)deviceID :(NSString *)key :(NSString *)value;
- (void)autoRenameDevice:(NSString *)deviceID;
- (void)processAccounts;

// Logging Methods

- (void)startLogging;
- (void)stopLogging;

// HTTP Request Construction Methods

- (NSURLRequest *)makeGETrequest:(NSString *)path;
- (NSMutableURLRequest *)makePUTrequest:(NSString *)path :(NSDictionary *)bodyDictionary;
- (NSMutableURLRequest *)makePOSTrequest:(NSString *)path :(NSDictionary *)bodyDictionary;
- (NSURLRequest *)makeDELETErequest:(NSString *)path;
- (void)setRequestAuthorization:(NSMutableURLRequest *)request;

// Connection Methods

- (void)launchConnection:(id)request :(NSInteger)actionCode;
- (void)relaunchConnection:(id)userInfo;

// NSURLSession/NSURLConnection Joint Methods

- (NSDictionary *)processConnection:(Connexion *)connexion;
- (void)processResult:(Connexion *)connexion :(NSDictionary *)data;
- (void)reportError;
- (NSInteger)checkStatus:(NSDictionary *)data;

// Base64 Methods

- (NSString *)encodeBase64String:(NSString *)plainString;
- (NSString *)decodeBase64String:(NSString *)base64String;


@property (nonatomic, strong) NSMutableArray *devices;
@property (nonatomic, strong) NSMutableArray *models;
@property (nonatomic, strong) NSMutableArray *accounts;
@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, strong) NSString *statusMessage;
@property (nonatomic, strong) NSString *deviceCode;
@property (nonatomic, strong) NSString *agentCode;


@end