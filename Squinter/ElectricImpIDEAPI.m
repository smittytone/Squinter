

#import "ElectricImpIDEAPI.h"


@implementation ElectricImpIDEAPI

@synthesize devices;
@synthesize models;
@synthesize deviceCode;
@synthesize agentCode;
@synthesize mainInstance;



#pragma mark - Initialization Methods

- (id)init
{
    self = [super init];
    
    if (self)
    {
		// Set up arrays

		connexions = [[NSMutableArray alloc] init];
		devices = [[NSMutableArray alloc] init];
		models = [[NSMutableArray alloc] init];
		devs = [[NSMutableArray alloc] init];
		devCount = 0;
    }
    
    return self;
}



- (void)setMainInstance:(id)object
{
	// mainInstance stores a pointer to the app delegate
	// It should be set whe IDE is first used

	mainInstance = object;
}



#pragma mark - Data Request Methods

- (void)getModels
{
	// Set up a GET request to the /models URL

	NSURLRequest *request = [self makeGETrequest:@"https://api.electricimp.com/v2/models"];
    [self launchConnection:request :0];
}



- (void)getModel:(NSString *)path
{
	// Set up a GET request to the /models/[model_ID] URL

	NSURLRequest *request = [self makeGETrequest:path];
	[self launchConnection:request :1];
}



- (void)uploadProject:(Project *)aProject forModel:(NSInteger)modelIndex
{
	// Set up a POST request to the /models/[model_ID] URL
	// Body includes JSON format storage of agent code and device code

	NSArray *keys = [NSArray arrayWithObjects:@"agent_code", @"imp_code", nil];
	
	NSString *aCodeString = aProject.projectAgentCode;
	if (aCodeString == nil) aCodeString = @"";
	
	NSString *dCodeString = aProject.projectDeviceCode;
	if (dCodeString == nil) dCodeString = @"";
	
	NSArray *values = [NSArray arrayWithObjects:aCodeString, dCodeString, nil];
	NSDictionary *body = [NSDictionary dictionaryWithObjects:values forKeys:keys];
	NSDictionary *model = [models objectAtIndex:modelIndex];
	
	NSMutableURLRequest	*request = [self makePOSTrequest:[model objectForKey:@"external_url"] :body];
	if (request) [self launchConnection:request :2];
}



- (void)getDevices
{
	// No devices to acquire? bail
	
	if (devs.count < 1) return;
	
	NSString *path = @"https://api.electricimp.com/v2/device/";
	
	for (NSString *deviceID in devs)
	{
		// Issue an request for each device in the list
		
		NSString *fetch = [path stringByAppendingString:deviceID];
		NSDictionary *dict = [NSDictionary dictionaryWithObject:@"nothing" forKey:@"nothing"];
		NSMutableURLRequest	*request = [self makePOSTrequest:fetch :dict];
		if (request) [self launchConnection:request :3];
	}
}



- (void)restartDevice:(NSInteger)deviceIndex
{
	NSDictionary *device = [devices objectAtIndex:deviceIndex];
	NSString *deviceName = [device objectForKey:@"impee_id"];
	NSString *modelName = [device objectForKey:@"model_name"];
	NSString *path = nil;
	
	for (NSUInteger i = 0 ; i < models.count ; i++)
	{
		NSDictionary *model = [models objectAtIndex:i];
		
		if ([modelName compare:[model objectForKey:@"name"]] == NSOrderedSame)
		{
			path = [model objectForKey:@"external_url"];
		}
	}
	
	if (path)
	{
		NSArray *keys = [NSArray arrayWithObjects:@"device_id", @"run", nil];
		NSArray *values = [NSArray arrayWithObjects:deviceName, @"true", nil];
		NSDictionary *dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
		NSMutableURLRequest	*request = [self makePOSTrequest:path :dict];
		if (request) [self launchConnection:request :4];
	}
}



#pragma mark - HTTP Request Construction Methods

- (NSURLRequest *)makeGETrequest:(NSString *)path
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
    return request;
}



- (NSMutableURLRequest *)makePOSTrequest:(NSString *)path :(NSDictionary *)bodyDictionary
{
    NSError *error;

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:bodyDictionary options:0 error:&error]];

	if (error)
	{
		// Couldn't construct the HTTP POST request, so warm user and return nil

		return nil;
	}
	else
	{
    	return request;
	}
}



- (NSURLRequest *)makePUTrequest:(NSString *)path
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    return request;
}



- (void)launchConnection:(id)request :(NSInteger)actionCode
{
	Connexion *aConnexion = [[Connexion alloc] init];
    aConnexion.actionCode = actionCode;
    aConnexion.receivedData = [NSMutableData dataWithCapacity:0];
    aConnexion.connexion = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (!aConnexion.connexion)
    {
        // Inform the user that the connection failed.
    }
    else
    {
        [connexions addObject:aConnexion];
    }
}



#pragma mark - Connection Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{

}



- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    for (Connexion *aConnexion in connexions)
    {
        if (aConnexion.connexion == connection) [aConnexion.receivedData appendData:data];
    }
}



- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    Connexion *theCurrentConnexion;
    NSError *error;
    NSArray *parsedData = nil;
    
    for (Connexion *aConnexion in connexions)
    {
        if (aConnexion.connexion == connection)
        {
            theCurrentConnexion = aConnexion;
            
            if (aConnexion.receivedData)
            {
                parsedData = [NSJSONSerialization JSONObjectWithData:aConnexion.receivedData options:kNilOptions error:&error];
            }
        }
    }

    [connection cancel];
    [connexions removeObject:theCurrentConnexion];
    
    switch (theCurrentConnexion.actionCode)
    {
        case 0:
            // Get models - and get them fresh

			[models removeAllObjects];
			if (devs == nil) devs = [[NSMutableArray alloc] init];

            if (parsedData)
			{
				for (NSDictionary *model in parsedData)
		 		{
					[models addObject:model];
					
					// Get the devices dictionary from the model data

					NSArray *modelDevices = [model objectForKey:@"devices"];

					if (modelDevices.count > 0)
					{
						// The model has device(s) assigned to it, so add it to our list

						for (NSUInteger i = 0 ; i < modelDevices.count ; i++)
						{
							// Put all the device IDs from the model into a temporary array
							// Devices can only be assigned to one model, so there will be no duplication

							[devs addObject:[[modelDevices objectAtIndex:i] valueForKey:@"device_id"]];
						}
					}
				}

				// Now we're done, so trigger the next part of the appDelegate code

				[mainInstance performSelector:@selector(listModels) withObject:nil];
				
				// Get device details
				
				[self getDevices];
			}

			break;

		case 1:
			// Get a single model

			if (parsedData)
			{
				// Access the model's code storage and put the code into IDE properties

				agentCode = [(NSDictionary *)parsedData objectForKey:@"agent_code"];
				deviceCode = [(NSDictionary *)parsedData objectForKey:@"imp_code"];

				// Now we're done, so trigger the next part of the appDelegate code

				[mainInstance performSelector:@selector(modelToProjectStageTwo) withObject:nil];
			}

			break;
			
		case 2:
			// Upload a single model's code

			// Now we're done, so trigger the next part of the appDelegate code

			[mainInstance performSelector:@selector(uploadCodeStageTwo) withObject:nil];
			break;
			
		case 3:
			// Incoming data is a single device
			
			if (parsedData)
			{
				NSDictionary *aDict = [(NSDictionary *)parsedData objectForKey:@"result"];
				NSMutableDictionary *dDict = [NSMutableDictionary dictionaryWithDictionary:[aDict valueForKey:@"device"]];
				NSDictionary *mDict = [aDict valueForKey:@"model"];
				[dDict setObject:[mDict objectForKey:@"name"] forKey:@"model_name"];
 				[devices addObject:dDict];
				
				devCount++;
				if (devCount == devs.count)
				{
					// We should now have all the devices so tell the main object
					
					[mainInstance performSelector:@selector(displayDevices) withObject:nil];
				}
			}
			
        default:
            break;
    }

	theCurrentConnexion = nil;
}



- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    if (protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic || protectionSpace.authenticationMethod == NSURLAuthenticationMethodDefault)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}



- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSURLCredential *bonaFides;
    
    if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust)
    {
        bonaFides = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    }
    else
    {
		// @"d7dccb693e6fda96b2b8f45729f8d51b";

		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSString *ak = [self decodeBase64String:[defaults stringForKey:@"com.bps.squinter.ak.count"]];
        bonaFides = [NSURLCredential credentialWithUser:ak
                                               password:ak
                                            persistence:NSURLCredentialPersistenceNone];
    }
    
    [[challenge sender] useCredential:bonaFides forAuthenticationChallenge:challenge];
}



- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{

}



-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    return request;
}




- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // Inform the user of the failure
    
	NSLog([NSString stringWithFormat:@"%@", error.description]);

	[connexions removeObject:connection];
}



#pragma mark - Base64 Methods

- (NSString *)encodeBase64String:(NSString *)plainString
{
    NSData *data = [plainString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [data base64EncodedStringWithOptions:0];
    return base64String;
}



- (NSString *)decodeBase64String:(NSString *)base64String
{
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    NSString *decodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return decodedString;
}



@end