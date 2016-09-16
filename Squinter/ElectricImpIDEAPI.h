
#import <Foundation/Foundation.h>
#import "Constants.h"
#import "Connexion.h"
#import "Project.h"


@interface ElectricImpIDEAPI : NSObject <NSURLConnectionDataDelegate>

{
    NSMutableArray *connexions;
	NSMutableArray *devs;
	NSUInteger devCount;
    NSString *baseURL;
	SEL returnSelector;
}


- (void)setMainInstance:(id)object;

- (void)getModels;
- (void)getModel:(NSString *)path;
- (void)uploadProject:(Project *)aProject forModel:(NSInteger)modelIndex;
- (void)getDevices;
- (void)restartDevice:(NSInteger)deviceIndex;

- (NSURLRequest *)makeGETrequest:(NSString *)path;
- (NSURLRequest *)makePUTrequest:(NSString *)path;
- (NSMutableURLRequest *)makePOSTrequest:(NSString *)path :(NSDictionary *)bodyDictionary;


- (void)launchConnection:(id)request :(NSInteger)actionCode;

- (NSString *)decodeBase64String:(NSString *)base64String;
- (NSString *)encodeBase64String:(NSString *)plainString;


@property (nonatomic, strong) NSMutableArray *devices;
@property (nonatomic, strong) NSMutableArray *models;
@property (nonatomic, strong) NSString *agentCode;
@property (nonatomic, strong) NSString *deviceCode;
@property (nonatomic, strong) id mainInstance;

@end