//
//  BuzztangWL.m
//  Buzztang
//

//

#import "BuzztangWL.h"
#import "UrlConstant.h"
#import "UserInfoBO.h"
#import "NetworkBO.h"
#import "BuzzBoardBO.h"
#import "ContactBO.h"
#import "UserProfileBO.h"
#import "WordBO.h"
#import "CallBack.h"
#import "SynonymsBO.h"
#import "NetworkFilterBO.h"
@implementation BuzztangWL


-(void)doLogInWithEmail:(NSString *)email withPassword:(NSString *)password
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:LOGINURL];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:email forKey:@"email"];
    [dict setObject:password forKey:@"password"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"doLogInWithEmail:parsedObject:%@",parsedObject.description);
            if(localError== nil)
            {
                if([[parsedObject valueForKey:@"success"] isKindOfClass:[NSString class]])
                {
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(loginFailuerWithError:)])
                    {
                        [self.callBack loginFailuerWithError:[parsedObject valueForKey:@"success"]];
                    }
                    
                }
                else
                {
                    NSDictionary *dict = [parsedObject valueForKey:@"success"];
                    NSString* token = [dict valueForKey:@"session_token"];
                    [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"session_token"];
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(loginSuccess)])
                    {
                        [self.callBack loginSuccess];
                    }
                }
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(loginFailuerWithError:)])
                {
                    [self.callBack loginFailuerWithError:localError.description];
                }
                
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(loginFailuerWithError:)])
            {
                [self.callBack loginFailuerWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
}

-(void)doSignUpWithUserName:(NSString *)userName withPassword:(NSString *)password withEmailId:(NSString *)emailId
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:SIGNUP];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:userName forKey:@"first_name"];
    [dict setObject:password forKey:@"password"];
    [dict setObject:emailId forKey:@"email_address"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"doSignUpWithUserName: parsedObject:%@",parsedObject.description);
            if(localError== nil)
            {
                
                
                if([[parsedObject valueForKey:@"user_details"] isKindOfClass:[NSString class]])
                {
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(signUpFailuerWithError:)])
                    {
                        [self.callBack signUpSuccess];
                    }
                    
                }
                else if([[parsedObject valueForKey:@"user_details"] isKindOfClass:[NSDictionary class]])
                {
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(signUpSuccess)])
                    {
                        [self.callBack signUpSuccess];
                    }
                }
                else
                {
                    NSString *msg = [parsedObject valueForKey:@"message"];
                    
                    if(msg.length)
                    {
                        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(signUpFailuerWithError:)])
                        {
                            [self.callBack signUpFailuerWithError:msg];
                        }
                    }
                    else
                    {
                        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(signUpFailuerWithError:)])
                        {
                            [self.callBack signUpFailuerWithError:@"Internal error occured."];
                        }
                        
                    }
                    
                }
                
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(signUpFailuerWithError:)])
                {
                    [self.callBack signUpFailuerWithError:localError.description];
                }
                
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(signUpFailuerWithError:)])
            {
                [self.callBack signUpFailuerWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
}

-(void)getNewPasswordWithEmailId:(NSString *)emailId{
    
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:FORGETPASSWORDURL];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:emailId forKey:@"email_address"];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (connectionError==nil) {
            
            NSError *localError = nil;
            
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            NSLog(@"getNewPasswordWithEmailId: parsedObject:%@",parsedObject.description);
            //locally any error accure or not
            if(localError== nil)
            {
                //Email Validate or not
                if([[parsedObject valueForKey:@"success"] isKindOfClass:[NSString class]])
                {
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(newPasswordFailuerWithError:)])
                    {
                        [self.callBack newPasswordFailuerWithError:[parsedObject valueForKey:@"success"]];
                    }
                    
                }
                else
                {
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(newPasswordSuccess)])
                    {
                        [self.callBack newPasswordSuccess];
                    }
                }
                //
                
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(newPasswordFailuerWithError:)])
                {
                    [self.callBack newPasswordFailuerWithError:localError.description];
                }
                
            }
            
            //
            
            
        }else{
            
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(newPasswordFailuerWithError:)])
            {
                [self.callBack newPasswordFailuerWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
        
    }];
    
    
    
}

-(void)getBuzzboardData
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:BUZZBOARD];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"getBuzzboardData: parsedObject:%@",parsedObject.description);
            if(localError== nil)
            {
                BuzzBoardBO *buzzboard = [[BuzzBoardBO alloc] init];
                buzzboard.networksFromLastLogin = [parsedObject valueForKey:@"new public Networks since your last login"];
                buzzboard.totalNetwork = [parsedObject valueForKey:@"total_networks"];
                buzzboard.userNetworks = [parsedObject valueForKey:@"user_networks"];
                buzzboard.watchingNetworks = [parsedObject valueForKey:@"watching_networks"];
                buzzboard.belongsPrivateNet = [parsedObject valueForKey:@"you are belongs to private networks"];
                buzzboard.belongsPublicNet = [parsedObject valueForKey:@"you are belongs to public networks"];
                buzzboard.watchPrivateNet = [parsedObject valueForKey:@"you are watching private networks"];
                buzzboard.watchPublicNet = [parsedObject valueForKey:@"you are watching public networks"];
                
                NSArray *arrWachNetWork = [parsedObject valueForKey:@"most_watched_networks"];
                
                if(arrWachNetWork.count)
                {
                    buzzboard.arrMostWatchedNet = [[NSMutableArray alloc] init];
                    for (NSDictionary *dict  in arrWachNetWork)
                    {
                        NetworkBO * network = [[NetworkBO alloc] init];
                        
                        network.contacts = [[dict valueForKey:@"network_contacts"] stringValue];
                        network.descriptions = [dict valueForKey:@"network_description"];
                        network.imageUrl = [dict valueForKey:@"network_image_url"];
                        network.members = [[dict valueForKey:@"network_members"] stringValue];
                        network.name = [dict valueForKey:@"network_name"];
                        network.networkId = [[dict valueForKey:@"network_id"] stringValue];
                        
                        [buzzboard.arrMostWatchedNet addObject:network];
                        network = nil;
                        
                    }
                }
                
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(buzzboardDataReceivedWith:)])
                {
                    [self.callBack buzzboardDataReceivedWith:buzzboard];
                }
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(buzzboardDataFailuerWithError:)])
                {
                    [self.callBack buzzboardDataFailuerWithError:localError.description];
                }
                
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(buzzboardDataFailuerWithError:)])
            {
                [self.callBack buzzboardDataFailuerWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
}

-(void)checkLogInCredentialwith:(UserInfoBO *)userInfo
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:SOCIALLOGINCHECK];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:userInfo.emailID forKey:@"email_address"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"checkLogInCredentialwith: parsedObject:%@",parsedObject.description);
            if(localError== nil)
            {
                if([[parsedObject valueForKey:@"success"] isKindOfClass:[NSString class]])
                {
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(checkLogInCredentialSucceswith:)])
                    {
                        [self.callBack checkLogInCredentialSucceswith:nil];
                    }
                }
                else
                {
                    NSDictionary *dict = [parsedObject valueForKey:@"success"];
                    UserInfoBO *userBO = [[UserInfoBO alloc] init];
                    userBO.emailID = [dict valueForKey:@"email_address"];
                    userBO.password = [dict valueForKey:@"password"];
                    
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(checkLogInCredentialSucceswith:)])
                    {
                        [self.callBack checkLogInCredentialSucceswith:userBO];
                    }
                    
                }
                
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(checkLogInCredentialFailuerWithError:)])
                {
                    [self.callBack checkLogInCredentialFailuerWithError:localError.description];
                }
                
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(checkLogInCredentialFailuerWithError:)])
            {
                [self.callBack checkLogInCredentialFailuerWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
}

-(void)existingUserLoginWith:(UserInfoBO *)userInfo
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:SOCIALLOGIN];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:userInfo.emailID forKey:@"email_address"];
    [dict setObject:userInfo.password forKey:@"hashed_password"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError== nil)
            {
                if([[parsedObject valueForKey:@"success"] isKindOfClass:[NSString class]])
                {
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(loginFailuerWithError:)])
                    {
                        [self.callBack loginFailuerWithError:[parsedObject valueForKey:@"success"]];
                    }
                    
                }
                else
                {
                    NSDictionary *dict = [parsedObject valueForKey:@"success"];
                    NSString* token = [dict valueForKey:@"session_token"];
                    [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"session_token"];
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(loginSuccess)])
                    {
                        [self.callBack loginSuccess];
                    }
                }
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(loginFailuerWithError:)])
                {
                    [self.callBack loginFailuerWithError:localError.description];
                }
                
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(loginFailuerWithError:)])
            {
                [self.callBack loginFailuerWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
}

-(void)getNetWorkDetailWithid:(NSString *)networkID
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:NETWORKDETAIL];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    [dict setObject:networkID forKey:@"network_id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError== nil)
            {
                
                if([parsedObject valueForKey:@"success"]){
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(netWorkDetailDataFailuerWithError:)])
                    {
                        [self.callBack netWorkDetailDataFailuerWithError:[parsedObject valueForKey:@"success"]];
                    }
                    
                }
                else{
                    NetworkBO *network = [[NetworkBO alloc] init];
                    network.contacts = [[parsedObject valueForKey:@"network_contacts"] stringValue];
                    network.descriptions = [parsedObject valueForKey:@"network_description"];
                    network.imageUrl = [parsedObject valueForKey:@"network_image_url"];
                    network.members = [[parsedObject valueForKey:@"network_members"] stringValue];
                    network.name = [parsedObject valueForKey:@"network_name"];
                    
                    
                    
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(netWorkDetailDataSucceswith:)])
                    {
                        [self.callBack netWorkDetailDataSucceswith:network];
                    }
                    network = nil;
                    
                }
                
                
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(netWorkDetailDataFailuerWithError:)])
                {
                    [self.callBack netWorkDetailDataFailuerWithError:localError.description];
                }
                
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(netWorkDetailDataFailuerWithError:)])
            {
                [self.callBack netWorkDetailDataFailuerWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
}

-(void)getNetWorkWithUrl:(NSString *)urls
{
    NSError *error;
    
    NSString *strUrl = urls;
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError== nil)
            {
                if([[parsedObject valueForKey:@"success"] isKindOfClass:[NSString class]])
                {
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(myNetworkDataFailuerWithError:)])
                    {
                        [self.callBack myNetworkDataFailuerWithError:[parsedObject valueForKey:@"success"]];
                    }
                    
                }
                else{
                    NSMutableArray *arrMostWatchedNet = [[NSMutableArray alloc] init];
                    
                    if(parsedObject.count)
                    {
                        for (NSDictionary *dict  in parsedObject)
                        {
                            NetworkBO * network = [[NetworkBO alloc] init];
                            
                            network.networkId = [[dict valueForKey:@"network_id"] stringValue];
                            network.contacts = [[dict valueForKey:@"network_contacts"] stringValue];
                            network.descriptions = [dict valueForKey:@"network_description"];
                            network.imageUrl = [dict valueForKey:@"network_image_url"];
                            network.members = [[dict valueForKey:@"network_members"] stringValue];
                            network.name = [dict valueForKey:@"network_name"];
                            
                            [arrMostWatchedNet addObject:network];
                            network = nil;
                            
                        }
                    }
                    
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(myNetworkDataSucceswith:)])
                    {
                        [self.callBack myNetworkDataSucceswith:arrMostWatchedNet];
                    }
                    arrMostWatchedNet = nil;
                    
                    
                }
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(myNetworkDataFailuerWithError:)])
                {
                    [self.callBack myNetworkDataFailuerWithError:localError.description];
                }
                
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(myNetworkDataFailuerWithError:)])
            {
                [self.callBack myNetworkDataFailuerWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
}

-(void)getAvailableNetworkData
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:AVAILABLENETWORK];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError== nil)
            {
                //                NSArray *arrWachNetWork = [parsedObject valueForKey:@"most_watched_networks"];
                NSMutableArray *arrMostWatchedNet = [[NSMutableArray alloc] init];
                
                if(parsedObject.count)
                {
                    for (NSDictionary *dict  in parsedObject)
                    {
                        NetworkBO * network = [[NetworkBO alloc] init];
                        
                        network.networkId = [[dict valueForKey:@"network_id"] stringValue];
                        network.contacts = [[dict valueForKey:@"network_contacts"] stringValue];
                        network.descriptions = [dict valueForKey:@"network_description"];
                        network.imageUrl = [dict valueForKey:@"network_image_url"];
                        network.members = [[dict valueForKey:@"network_members"] stringValue];
                        network.name = [dict valueForKey:@"network_name"];
                        
                        [arrMostWatchedNet addObject:network];
                        network = nil;
                        
                    }
                }
                
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(availableNetworkDataSucceswith:)])
                {
                    [self.callBack availableNetworkDataSucceswith:arrMostWatchedNet];
                }
                arrMostWatchedNet = nil;
                
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(availableNetworkDataFailuerWithError:)])
                {
                    [self.callBack availableNetworkDataFailuerWithError:localError.description];
                }
                
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(availableNetworkDataFailuerWithError:)])
            {
                [self.callBack availableNetworkDataFailuerWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
}

-(void)getSearchResultWithCriteria:(NSString *)criteria
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:SEARCHNETWORK];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    
    [dict setObject:criteria forKey:@"criteria"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError== nil)
            {
                //                NSArray *arrWachNetWork = [parsedObject valueForKey:@"most_watched_networks"];
                NSMutableArray *arrMostWatchedNet = [[NSMutableArray alloc] init];
                
                if(parsedObject.count)
                {
                    for (NSDictionary *dict  in parsedObject)
                    {
                        NetworkBO * network = [[NetworkBO alloc] init];
                        
                        network.networkId = [[dict valueForKey:@"network_id"] stringValue];
                        network.contacts = [[dict valueForKey:@"network_contacts"] stringValue];
                        network.descriptions = [dict valueForKey:@"network_description"];
                        network.imageUrl = [dict valueForKey:@"network_image_url"];
                        network.members = [[dict valueForKey:@"network_members"] stringValue];
                        network.name = [dict valueForKey:@"network_name"];
                        
                        [arrMostWatchedNet addObject:network];
                        network = nil;
                        
                    }
                }
                
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(searchResultWithCriteriaDataSuccesWith:)])
                {
                    [self.callBack searchResultWithCriteriaDataSuccesWith:arrMostWatchedNet];
                }
                arrMostWatchedNet = nil;
                
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(searchResultWithCriteriaDataFailuerWithError:)])
                {
                    [self.callBack searchResultWithCriteriaDataFailuerWithError:localError.description];
                }
                
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(searchResultWithCriteriaDataFailuerWithError:)])
            {
                [self.callBack searchResultWithCriteriaDataFailuerWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
}
-(void)creatNetworkWithObject:(NetworkBO *)network
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:CREATENETWORK];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    [dict setObject:network.name forKey:@"buzz_name"];
    [dict setObject:network.descriptions forKey:@"buzz_description"];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError== nil)
            {
                
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(creatNetworkSucces)])
                {
                    [self.callBack creatNetworkSucces];
                }
                
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(creatNetworkFailuerWithError:)])
                {
                    [self.callBack creatNetworkFailuerWithError:localError.description];
                }
                
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(creatNetworkFailuerWithError:)])
            {
                [self.callBack creatNetworkFailuerWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
}

-(void)joinNetWorkWithObject:(NetworkBO *)network
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:JOINNETWORK];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *netId =network.networkId;
    if(netId.length==0)
    {
        netId = @"1";
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    [dict setObject:netId forKey:@"network_id"];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError== nil)
            {
                if([[parsedObject valueForKey:@"success"] isKindOfClass:[NSString class]])
                {
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(joinNetWorkFailuerWithError:)])
                    {
                        [self.callBack joinNetWorkFailuerWithError:[parsedObject valueForKey:@"success"]];
                    }
                    
                }
                else
                {
                    
                    
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(joinNetWorkSucces)])
                    {
                        [self.callBack joinNetWorkSucces];
                    }
                }
                
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(joinNetWorkFailuerWithError:)])
                {
                    [self.callBack joinNetWorkFailuerWithError:localError.description];
                }
                
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(joinNetWorkFailuerWithError:)])
            {
                [self.callBack joinNetWorkFailuerWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
}
-(void)getContactsWithNetworkId:(NSString *)networkId
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:VIEWCONTACTS];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    
    [dict setObject:networkId forKey:@"network_id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError== nil)
            {
                if([parsedObject isKindOfClass:[NSDictionary class]]){
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(contactsDataFailuerWithError:)])
                    {
                        [self.callBack contactsDataFailuerWithError:[parsedObject valueForKey:@"success"]];
                    }
                }
                else{
                    NSMutableArray *arrMostWatchedNet = [[NSMutableArray alloc] init];
                    
                    if(parsedObject.count)
                    {
                        for (NSDictionary *dict  in parsedObject)
                        {
                            ContactBO * contact = [[ContactBO alloc] init];
                            
                            id contact_idCheck = [dict valueForKey:@"contact_id"];
                            if (![contact_idCheck isKindOfClass:[NSNull class]])
                            {
                                contact.contact_id = [[dict valueForKey:@"contact_id"] stringValue];
                            }
                            
                            id email_idCheck = [dict valueForKey:@"email_id"];
                            if (![email_idCheck isKindOfClass:[NSNull class]])
                            {
                                contact.email_id = [dict valueForKey:@"email_id"];
                            }
                            
                            id first_nameCheck = [dict valueForKey:@"first_name"];
                            if (![first_nameCheck isKindOfClass:[NSNull class]])
                            {
                                contact.first_name = [dict valueForKey:@"first_name"];
                            }
                            
                            id last_nameCheck = [dict valueForKey:@"last_name"];
                            if (![last_nameCheck isKindOfClass:[NSNull class]])
                            {
                                contact.last_name = [dict valueForKey:@"last_name"];
                            }
                            
                            id fbID_Check = [dict valueForKey:@"facebook_id"];
                            if (![fbID_Check isKindOfClass:[NSNull class]] && [(NSString*)fbID_Check length]!=0)
                            {
                                NSString *facebookString = [dict valueForKey:@"facebook_id"];
                                NSArray *fbIds = [facebookString componentsSeparatedByString:@"~"];
                                if ([fbIds count]>0)
                                {
                                    NSMutableArray *ids = [[NSMutableArray alloc] init];
                                    for (int i=0; i<[fbIds count]; i++)
                                    {
                                        [ids addObject:fbIds[i]];
                                    }
                                    contact.facebookIds = [NSArray arrayWithArray:ids];
                                }
                                //else contact.facebookIds = [NSArray arrayWithObjects:facebookString,nil];
                            }
                            
                            id twID_Check = [dict valueForKey:@"twitter_id"];
                            if (![twID_Check isKindOfClass:[NSNull class]] && [(NSString*)twID_Check length]!=0)
                            {
                                NSString *twitterString = [dict valueForKey:@"twitter_id"];
                                NSArray *twIds = [twitterString componentsSeparatedByString:@"~"];
                                if ([twIds count]>0)
                                {
                                    NSMutableArray *ids = [[NSMutableArray alloc] init];
                                    for (int i=0; i<[twIds count]; i++)
                                    {
                                        [ids addObject:twIds[i]];
                                    }
                                    contact.twitterIds = [NSArray arrayWithArray:ids];
                                }
                                //else contact.twitterIds = [NSArray arrayWithObjects:twitterString,nil];
                            }
                            
                            id linkedInID_Check = [dict valueForKey:@"linkedin_id"];
                            if (![linkedInID_Check isKindOfClass:[NSNull class]] && [(NSString*)linkedInID_Check length]!=0)
                            {
                                NSString *linkedInString = [dict valueForKey:@"linkedin_id"];
                                NSArray *linkedInIds = [linkedInString componentsSeparatedByString:@"~"];
                                if ([linkedInIds count]>0)
                                {
                                    NSMutableArray *ids = [[NSMutableArray alloc] init];
                                    for (int i=0; i<[linkedInIds count]; i++)
                                    {
                                        [ids addObject:linkedInIds[i]];
                                    }
                                    contact.linkedInUrls = [NSArray arrayWithArray:ids];
                                }
                                //else contact.linkedInUrls = [NSArray arrayWithObjects:linkedInString,nil];
                            }
                            
                            id RSSfeed_Check = [dict valueForKey:@"rss_feed"];
                            if (![RSSfeed_Check isKindOfClass:[NSNull class]] && [(NSString*)RSSfeed_Check length]!=0)
                            {
                                NSString *RSSFeedString = [dict valueForKey:@"rss_feed"];
                                NSArray *RSSFeeds = [RSSFeedString componentsSeparatedByString:@"~"];
                                if ([RSSFeeds count]>0)
                                {
                                    NSMutableArray *ids = [[NSMutableArray alloc] init];
                                    for (int i=0; i<[RSSFeeds count]; i++)
                                    {
                                        NSArray *rssDetails = [RSSFeeds[i] componentsSeparatedByString:@"=>"];
                                        NSDictionary *rssFeedDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:rssDetails[0],rssDetails[1],nil] forKeys:[NSArray arrayWithObjects:@"Name",@"Url",nil]];
                                        [ids addObject:rssFeedDict];
                                    }
                                    contact.RSSfeeds = [NSArray arrayWithArray:ids];
                                }
                                /*else
                                 {
                                 NSArray *rssDetails = [RSSFeedString componentsSeparatedByString:@"=>"];
                                 NSDictionary *rssFeedDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:rssDetails[0],rssDetails[1],nil] forKeys:[NSArray arrayWithObjects:@"Name",@"Url",nil]];
                                 contact.RSSfeeds = [NSArray arrayWithObjects:rssFeedDict,nil];
                                 }*/
                            }
                            
                            id company_nameCheck = [dict valueForKey:@"company"];
                            if (![company_nameCheck isKindOfClass:[NSNull class]])
                            {
                                contact.company = [dict valueForKey:@"company"];
                            }
                            
                            id outlook_idCheck = [dict valueForKey:@"outlook_id"];
                            if (![outlook_idCheck isKindOfClass:[NSNull class]])
                            {
                                contact.outlookID = [dict valueForKey:@"outlook_id"];
                            }
                            
                            id stock_Check = [dict valueForKey:@"stock_symbol"];
                            if (![stock_Check isKindOfClass:[NSNull class]])
                            {
                                contact.stockSymbol = [dict valueForKey:@"stock_symbol"];
                            }
                            
                            [arrMostWatchedNet addObject:contact];
                            contact = nil;
                            
                        }
                    }
                    
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(contactsDataSuccesWith:)])
                    {
                        [self.callBack contactsDataSuccesWith:arrMostWatchedNet];
                    }
                    arrMostWatchedNet = nil;
                    
                    
                }
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(contactsDataFailuerWithError:)])
                {
                    [self.callBack contactsDataFailuerWithError:localError.description];
                }
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(contactsDataFailuerWithError:)])
            {
                [self.callBack contactsDataFailuerWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
}
-(void)getNewContactsWithNetworkId:(NSString *)networkID
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:VIEWCONTACTS];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    
    [dict setObject:networkID forKey:@"network_id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError== nil)
            {
                if([parsedObject isKindOfClass:[NSDictionary class]]){
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(newContactsDataFailuerWithError:)])
                    {
                        [self.callBack newContactsDataFailuerWithError:[parsedObject valueForKey:@"success"]];
                    }
                    
                }
                else{
                    NSMutableArray *arrMostWatchedNet = [[NSMutableArray alloc] init];
                    
                    if(parsedObject.count)
                    {
                        for (NSDictionary *dict  in parsedObject)
                        {
                            ContactBO * contact = [[ContactBO alloc] init];
                            
                            id email_idCheck = [dict valueForKey:@"email_id"];
                            if (![email_idCheck isKindOfClass:[NSNull class]])
                            {
                                contact.email_id = [dict valueForKey:@"email_id"];
                            }
                            
                            id first_nameCheck = [dict valueForKey:@"first_name"];
                            if (![first_nameCheck isKindOfClass:[NSNull class]])
                            {
                                contact.first_name = [dict valueForKey:@"first_name"];
                            }
                            
                            id last_nameCheck = [dict valueForKey:@"last_name"];
                            if (![last_nameCheck isKindOfClass:[NSNull class]])
                            {
                                contact.last_name = [dict valueForKey:@"last_name"];
                            }
                            
                            
                            [arrMostWatchedNet addObject:contact];
                            contact = nil;
                            
                        }
                    }
                    
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(newContactsDataSuccesWith:)])
                    {
                        [self.callBack newContactsDataSuccesWith:arrMostWatchedNet];
                    }
                    arrMostWatchedNet = nil;
                    
                    
                }
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(newContactsDataFailuerWithError:)])
                {
                    [self.callBack newContactsDataFailuerWithError:localError.description];
                }
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(newContactsDataFailuerWithError:)])
            {
                [self.callBack newContactsDataFailuerWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
}
-(void)deleteNetWorkWithObject:(NetworkBO *)network
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:DELETENETWORK];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *netId =network.networkId;
    if(netId.length==0)
    {
        netId = @"1";
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    [dict setObject:netId forKey:@"network_id"];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError== nil)
            {
                if([[parsedObject valueForKey:@"success"] isKindOfClass:[NSString class]])
                {
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteNetWorkFailuerWithError:)])
                    {
                        [self.callBack deleteNetWorkFailuerWithError:[parsedObject valueForKey:@"success"]];
                    }
                    
                }
                
                else{
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteNetWorkSucceswithMsg:)])
                    {
                        [self.callBack deleteNetWorkSucceswithMsg:[parsedObject valueForKey:@"message"]];
                    }
                }
                
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteNetWorkFailuerWithError:)])
                {
                    [self.callBack deleteNetWorkFailuerWithError:localError.description];
                }
                
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteNetWorkFailuerWithError:)])
            {
                [self.callBack deleteNetWorkFailuerWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
}

-(void)addNetworkToBuzzboardWithNetworkId:(NSString *)networkId
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:ADDNETWORKTOBUZZ];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *netId =networkId;
    if(netId.length==0)
    {
        netId = @"1";
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    [dict setObject:netId forKey:@"network_id"];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"addNetworkToBuzzboardWithNetworkIdSucces: parsedObject:%@",parsedObject.description);
            if(localError== nil)
            {
                if([[parsedObject valueForKey:@"success"] isKindOfClass:[NSString class]])
                {
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(addNetworkToBuzzboardWithNetworkIdFailuerWithError:)])
                    {
                        [self.callBack addNetworkToBuzzboardWithNetworkIdFailuerWithError:[parsedObject valueForKey:@"success"]];
                    }
                    
                }
                else{
                    
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(addNetworkToBuzzboardWithNetworkIdSucces)])
                    {
                        [self.callBack addNetworkToBuzzboardWithNetworkIdSucces];
                    }
                }
                
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(addNetworkToBuzzboardWithNetworkIdFailuerWithError:)])
                {
                    [self.callBack addNetworkToBuzzboardWithNetworkIdFailuerWithError:localError.description];
                }
                
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(addNetworkToBuzzboardWithNetworkIdFailuerWithError:)])
            {
                [self.callBack addNetworkToBuzzboardWithNetworkIdFailuerWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
}

-(void)removeNetworkFromBuzzboardWithNetworkId:(NSString *)networkId
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:REMOVENETWORKFROMBUZZ];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *netId =networkId;
    if(netId.length==0)
    {
        netId = @"1";
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    [dict setObject:netId forKey:@"network_id"];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"removeNetworkFromBuzzboardSucceswithMsg: parsedObject:%@",parsedObject.description);
            if(localError== nil)
            {
                if([[parsedObject valueForKey:@"success"] isKindOfClass:[NSString class]])
                {
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(removeNetworkFromBuzzboardFailuerWithError:)])
                    {
                        [self.callBack removeNetworkFromBuzzboardFailuerWithError:[parsedObject valueForKey:@"success"]];
                    }
                    
                }
                else
                {
                    
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(removeNetworkFromBuzzboardSucceswithMsg:)])
                    {
                        [self.callBack removeNetworkFromBuzzboardSucceswithMsg:[parsedObject valueForKey:@"message"]];
                    }
                }
                
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(removeNetworkFromBuzzboardFailuerWithError:)])
                {
                    [self.callBack removeNetworkFromBuzzboardFailuerWithError:localError.description];
                }
                
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(removeNetworkFromBuzzboardFailuerWithError:)])
            {
                [self.callBack removeNetworkFromBuzzboardFailuerWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
}
-(void)dropFromNetworkWithNetworkId:(NSString *)networkId
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:REMOVENETWORKFROMBUZZ];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *netId =networkId;
    if(netId.length==0)
    {
        netId = @"1";
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    [dict setObject:netId forKey:@"network_id"];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"removeNetworkFromBuzzboardSucceswithMsg: parsedObject:%@",parsedObject.description);
            if(localError== nil)
            {
                if([[parsedObject valueForKey:@"success"] isKindOfClass:[NSString class]])
                {
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(dropFromNetworkFailuerWithError:)])
                    {
                        [self.callBack dropFromNetworkFailuerWithError:[parsedObject valueForKey:@"success"]];
                    }
                }
                else
                {
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(dropFromNetworkSucceswithMsg:)])
                    {
                        [self.callBack dropFromNetworkSucceswithMsg:[parsedObject valueForKey:@"message"]];
                    }
                }
                
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(dropFromNetworkFailuerWithError:)])
                {
                    [self.callBack dropFromNetworkFailuerWithError:localError.description];
                }
                
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(dropFromNetworkFailuerWithError:)])
            {
                [self.callBack dropFromNetworkFailuerWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
}
-(void)addContactToBuzzboardWith:(NSString *)networkId andcontactId:(NSString *)contactId
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:ADDCONTACTTOBUZZ];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *netId =networkId;
    if(netId.length==0)
    {
        netId = @"1";
    }
    
    NSString *contId =contactId;
    if(contId.length==0)
    {
        contId = @"1";
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    [dict setObject:netId forKey:@"network_id"];
    [dict setObject:contId forKey:@"contact_id"];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"addContactToBuzzboardWith: parsedObject:%@",parsedObject.description);
            if(localError== nil)
            {
                if([[parsedObject valueForKey:@"success"] isKindOfClass:[NSString class]])
                {
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(addContactToBuzzboardFailuerWithError:)])
                    {
                        [self.callBack addContactToBuzzboardFailuerWithError:[parsedObject valueForKey:@"success"]];
                    }
                    
                }
                
                else{
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(addContactToBuzzboardSucceswithMsg:)])
                    {
                        [self.callBack addContactToBuzzboardSucceswithMsg:[parsedObject valueForKey:@"message"]];
                    }
                }
                
                
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(addContactToBuzzboardFailuerWithError:)])
                {
                    [self.callBack addContactToBuzzboardFailuerWithError:localError.description];
                }
                
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(addContactToBuzzboardFailuerWithError:)])
            {
                [self.callBack addContactToBuzzboardFailuerWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
}

-(void)removeContactToBuzzboardWith:(NSString *)networkId andcontactId:(NSString *)contactId
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:REMOVECONTACTTOBUZZ];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *netId =networkId;
    if(netId.length==0)
    {
        netId = @"1";
    }
    
    NSString *contId =contactId;
    if(contId.length==0)
    {
        contId = @"1";
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    [dict setObject:netId forKey:@"network_id"];
    [dict setObject:contId forKey:@"contact_id"];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"addNetworkToBuzzboardWithNetworkIdSucces: parsedObject:%@",parsedObject.description);
            if(localError== nil)
            {
                if([[parsedObject valueForKey:@"success"] isKindOfClass:[NSString class]])
                {
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(removeContactToBuzzboardFailuerWithError:)])
                    {
                        [self.callBack removeContactToBuzzboardFailuerWithError:[parsedObject valueForKey:@"success"]];
                    }
                    
                }
                
                else{
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(removeContactToBuzzboardSucceswithMsg:)])
                    {
                        [self.callBack removeContactToBuzzboardSucceswithMsg:[parsedObject valueForKey:@"message"]];
                    }
                }
                
                
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(removeContactToBuzzboardFailuerWithError:)])
                {
                    [self.callBack removeContactToBuzzboardFailuerWithError:localError.description];
                }
                
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(removeContactToBuzzboardFailuerWithError:)])
            {
                [self.callBack removeContactToBuzzboardFailuerWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
}



-(void)getUserProfileDetails{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:USERPROFILE];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            //            NSLog(@"getBuzzboardData: parsedObject:%@",parsedObject.description);
            
            if(localError== nil)
            {
                UserProfileBO *userProfile = [[UserProfileBO alloc] init];
                
                userProfile.firstName=[parsedObject valueForKey:@"first_name"];
                userProfile.emailAddress=[parsedObject valueForKey:@"email_address"];
                userProfile.role=[parsedObject valueForKey:@"role"];
                userProfile.timeZone=[parsedObject valueForKey:@"time_zone"];
                
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getUserProfileDetailsSuccess:)])
                {
                    [self.callBack getUserProfileDetailsSuccess:userProfile];
                    
                    
                    
                }
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getUserProfileDetailsWithError:)])
                {
                    [self.callBack getUserProfileDetailsWithError:localError.description];
                }
                
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getUserProfileDetailsWithError:)])
            {
                [self.callBack getUserProfileDetailsWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
    
    
    
}

-(void)ChangePasswordWithOldPassword:(NSString *)oldPassword withNewPassword:(NSString *)newPassword withConfirmationPassword:(NSString *)confirmationPassword{
    
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:CHANGEPASSWORD];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    
    [dict setObject:oldPassword forKey:@"old_password"];
    [dict setObject:newPassword forKey:@"new_password"];
    [dict setObject:confirmationPassword forKey:@"new_password_confirmation"];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            //            NSLog(@"getBuzzboardData: parsedObject:%@",parsedObject.description);
            
            if(localError== nil)
            {
                if([[parsedObject valueForKey:@"success"] isKindOfClass:[NSString class]])
                {
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(changePasseordWithError:)])
                    {
                        [self.callBack changePasseordWithError:[parsedObject valueForKey:@"success"]];
                    }
                    
                }
                else
                {
                    NSDictionary *dict = [parsedObject valueForKey:@"success"];
                    NSString* token = [dict valueForKey:@"hashed_password"];
                    [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"session_token"];
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(changePasseordSuccess:)])
                    {
                        [self.callBack changePasseordSuccess:@"Your password has been successfully changed"];
                    }
                }
                
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(changePasseordWithError:)])
                {
                    [self.callBack changePasseordWithError:localError.description];
                }
                
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(changePasseordWithError:)])
            {
                [self.callBack changePasseordWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
    
    
}
-(void)editUserProfileDetailsWithFirstName:(NSString *)firstName withLastName:(NSString *)lastName withAddress:(NSString *)address withTimeZone:(NSString *)timezone
{
    
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:EDITPROFILE];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    
    [dict setObject:firstName forKey:@"first_name"];
    [dict setObject:lastName forKey:@"last_name"];
    [dict setObject:address forKey:@"address"];
    [dict setObject:timezone forKey:@"time_zone_id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            //            NSLog(@"getBuzzboardData: parsedObject:%@",parsedObject.description);
            if(localError== nil)
            {
                
                if([[parsedObject valueForKey:@"success"] isKindOfClass:[NSString class]])
                {
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(editUserProfileWithError:)])
                    {
                        [self.callBack editUserProfileWithError:[parsedObject valueForKey:@"success"]];
                    }
                    
                }
                else
                {
                    NSDictionary *dict = [parsedObject valueForKey:@"success"];
                    NSString* token = [dict valueForKey:@"hashed_password"];
                    [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"session_token"];
                    
                    NSDictionary *messDict=[[NSDictionary alloc]initWithObjectsAndKeys:[dict valueForKey:@"last_name"],@"lastname",[dict valueForKey:@"address"],@"address", nil];
                    
                    
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(changePasseordSuccess:)])
                    {
                        [self.callBack editUserProfileSuccess:messDict];
                    }
                }
                
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(editUserProfileWithError:)])
                {
                    [self.callBack editUserProfileWithError:localError.description];
                }
                
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(editUserProfileWithError:)])
            {
                [self.callBack editUserProfileWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
    
}

-(void)getUserHistory{
    
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:USERHISTORY];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            //            NSLog(@"getBuzzboardData: parsedObject:%@",parsedObject.description);
            
            if(localError== nil)
            {
                
                NSMutableArray *arrHistory = [[NSMutableArray alloc] init];
                
                if(parsedObject.count)
                {
                    for (NSDictionary *dict  in parsedObject)
                    {
                        HistoryBo *history=[[HistoryBo alloc]init];
                        
                        history.buzzName = [dict valueForKey:@"buzz_name"];
                        history.fileName = [dict valueForKey:@"file_name"];
                        history.UserName = [dict valueForKey:@"first_name"];
                        history.importedTime = [dict valueForKey:@"imported_time"];
                        history.status = [dict valueForKey:@"status"];
                        
                        [arrHistory addObject:history];
                        history = nil;
                        
                    }
                }
                
                
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getUserHistorySuccess:)])
                {
                    [self.callBack getUserHistorySuccess:arrHistory];
                    
                    
                    
                }
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getUserHistoryWithError:)])
                {
                    [self.callBack getUserHistoryWithError:localError.description];
                }
                
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getUserHistoryWithError:)])
            {
                [self.callBack getUserHistoryWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
    
    
    
}
-(void)getBuzzDataWithNetworkId:(NSString *)networkId{
    
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:BUZZURL];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    
    [dict setObject:networkId forKey:@"network_id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError== nil)
            {
                if([[parsedObject valueForKey:@"buzz_network"] isKindOfClass:[NSString class]])
                {
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getBuzzDataWithError:)])
                    {
                        [self.callBack getBuzzDataWithError:[parsedObject valueForKey:@"buzz_network"]];
                    }
                    
                    
                }
                else
                {
                    NSMutableArray *arrBuzz = [[NSMutableArray alloc] init];
                    if (parsedObject.count) {
                        
                        [arrBuzz addObjectsFromArray:[parsedObject valueForKey:@"buzz_network"]];
                        
                        
                    }
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getBuzzDataSuccess:)])
                    {
                        [self.callBack getBuzzDataSuccess:arrBuzz];
                    }
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getBuzzDataSuccessContacts:)])
                    {
                        //NSLog(@"%@",[[[parsedObject valueForKey:@"contact_dropdown_list"] objectAtIndex:0] allValues]);
                        [self.callBack getBuzzDataSuccessContacts:[NSArray arrayWithArray:[[[parsedObject valueForKey:@"contact_dropdown_list"] objectAtIndex:0] allValues]]];
                    }
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getBuzzDataSuccessNetworks:)])
                    {
                        //NSLog(@"%@",[parsedObject valueForKey:@"network_dropdown_list"]);
                        [self.callBack getBuzzDataSuccessNetworks:[NSArray arrayWithArray:[[[parsedObject valueForKey:@"network_dropdown_list"] objectAtIndex:0] allValues]]];
                    }
                    //contact_dropdown_list
                    //network_dropdown_list
                    arrBuzz = nil;
                }
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getBuzzDataWithError:)])
                {
                    [self.callBack getBuzzDataWithError:localError.description];
                }
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getBuzzDataWithError:)])
            {
                [self.callBack getBuzzDataWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
}

/*Ontology managemnet*/
//All Ontology Words
-(void)getAllOntologyWordsForCurrentSession
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:ALLONTOLOGYWORDS];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //session_token
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%ld", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            //NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError == nil)
            {
                NSMutableArray *wordsArray = [[NSMutableArray alloc] init];
                for (int i=0; i<[parsedObject count]; i++)
                {
                    NSDictionary *dictionaryObject = parsedObject[i];
                    WordBO *word = [[WordBO alloc] init];
                    word.textValue = [dictionaryObject valueForKey:@"word"];
                    word.identifier = [dictionaryObject valueForKey:@"id"];
                    //Check for synonyms
                    NSArray *synonymsArray = [dictionaryObject valueForKey:@"synonyms"];
                    if ([synonymsArray count]>0)
                    {
                        NSMutableArray *wordSynonymsArray = [[NSMutableArray alloc] init];
                        for (int i=0; i<[synonymsArray count]; i++)
                        {
                            NSDictionary *synonymDataDict = synonymsArray[i];
                            SynonymsBO *synonym = [[SynonymsBO alloc] init];
                            synonym.textValue = [synonymDataDict valueForKey:@"synonym"];
                            synonym.identifier = [synonymDataDict valueForKey:@"id"];
                            [wordSynonymsArray addObject:synonym];
                        }
                        word.synonyms = [NSArray arrayWithArray:wordSynonymsArray];
                    }
                    [wordsArray addObject:word];
                }
                //Success…lets parse
                [self.callBack getAllOntolgyWordSuccess:wordsArray];
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createNewOntolgyWordWithError:)])
                {
                    [self.callBack getAllOntolgyWordError:localError.description];
                }
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createNewOntolgyWordWithError:)])
            {
                [self.callBack getAllOntolgyWordError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
}

//CreatenewOntologyWord
-(void)createNewOntologyWordWithSearchValue:(NSString *)searchStr synonyms:(NSArray *)synonymsArr andExtraWords:(NSString *)extraWordsStr
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:CREATEONTOLOGYWORD];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //session_token
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    //search_value
    [dict setObject:searchStr forKey:@"search_value"];
    //synonym_checkbox
    [dict setObject:synonymsArr forKey:@"synonym_checkbox"];
    //extra_keywords
    [dict setObject:extraWordsStr forKey:@"extra_keywords"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%ld", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError == nil)
            {
                //Success…lets parse
                [self.callBack createNewOntolgyWordSuccess:[parsedObject valueForKey:@"message"]];
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createNewOntolgyWordWithError:)])
                {
                    [self.callBack createNewOntolgyWordWithError:localError.description];
                }
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createNewOntolgyWordWithError:)])
            {
                [self.callBack createNewOntolgyWordWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
}
//Delete Ontology word
-(void)deleteOntologyWordWithID:(NSString *)ontologyWordI
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:DELETEONTOLOGYWORD];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //session_token
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    //ontology_master_id
    [dict setObject:ontologyWordI forKey:@"ontology_master_id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%ld", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError == nil)
            {
                //Success…lets parse
                [self.callBack deleteOntolgyWordSuccess:[parsedObject valueForKey:@"success"]];
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createNewOntolgyWordWithError:)])
                {
                    [self.callBack deleteOntolgyWordWithError:localError.description];
                }
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createNewOntolgyWordWithError:)])
            {
                [self.callBack deleteOntolgyWordWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
}
//Update Ontology word
-(void)updateOntologyWord:(NSString *)newOntologyWordStr WithID:(NSString *)ontologyWordID
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:UPDATEONTOLOGYWORD];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //session_token
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    //ontology_master_id
    [dict setObject:ontologyWordID forKey:@"ontology_master_id"];
    //word
    [dict setObject:newOntologyWordStr forKey:@"word"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%ld", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError == nil)
            {
                //Success…lets parse
                [self.callBack updateOntolgyWordSuccess:[parsedObject valueForKey:@"message"]];
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createNewOntolgyWordWithError:)])
                {
                    [self.callBack updateOntolgyWordSuccess:localError.description];
                }
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createNewOntolgyWordWithError:)])
            {
                [self.callBack updateOntolgyWordWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
}


//Search All Synonyms
-(void)searchSynonymsForWord:(NSString*)wordStr
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:SEARCHSYNONYMS];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //session_token
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    //search_value
    [dict setObject:wordStr forKey:@"search_value"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%ld", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError == nil)
            {
                //Success…lets parse
                if ([parsedObject valueForKey:@"synonyms"]!=nil)
                {
                    
                    [self.callBack searchSynonymsForWordSuccess:[parsedObject valueForKey:@"synonyms"]];
                }
                else
                {
                    [self.callBack searchSynonymsForWordSuccess:[parsedObject valueForKey:@"success"]];
                }
                
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createNewOntolgyWordWithError:)])
                {
                    [self.callBack searchSynonymsForWordError:localError.description];
                }
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createNewOntolgyWordWithError:)])
            {
                [self.callBack searchSynonymsForWordError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
}

//Add New Synonyms for a Ontology Word
-(void)addNewSynonyms:(NSString *)synonymsStr ForWord:(NSString *)wordID
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:ADDSYNONYM];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //session_token
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    //search_value
    [dict setObject:wordID forKey:@"ontology_master_id"];
    //search_value
    [dict setObject:synonymsStr forKey:@"extra_keywords"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%ld", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError == nil)
            {
                //Success…lets parse
                if (parsedObject.count >0)
                {
                    NSMutableArray *newlyAddedSynonyms = [[NSMutableArray alloc] init];
                    for (int i=0; i<parsedObject.count; i++)
                    {
                        NSDictionary *dataDictionay = [parsedObject[i] valueForKey:@"ontology_child"];
                        if (dataDictionay!= nil)
                        {
                            SynonymsBO *newSynonym = [[SynonymsBO alloc] init];
                            newSynonym.textValue = [dataDictionay valueForKey:@"synonym"];
                            newSynonym.identifier = [dataDictionay valueForKey:@"id"];
                            [newlyAddedSynonyms addObject:newSynonym];
                        }
                    }
                    [self.callBack addSynonymSuccess:[NSArray arrayWithArray:newlyAddedSynonyms]];
                }
                
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createNewOntolgyWordWithError:)])
                {
                    [self.callBack addSynonymError:localError.description];
                }
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createNewOntolgyWordWithError:)])
            {
                [self.callBack addSynonymError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
}

//Update a synonym for a Ontology Word
-(void)updateSynonym:(NSString *)toBeUpdatedSynonymStr withID:(NSString *)synonymID
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:UPDATESYNONYM];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //session_token
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    //synonym_id
    [dict setObject:synonymID forKey:@"synonym_id"];
    //synonym_id
    [dict setObject:toBeUpdatedSynonymStr forKey:@"synonym"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%ld", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError == nil)
            {
                //Success…lets parse
                [self.callBack updateSynonymSuccess:[parsedObject valueForKey:@"message"]];
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createNewOntolgyWordWithError:)])
                {
                    [self.callBack updateSynonymError:localError.description];
                }
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createNewOntolgyWordWithError:)])
            {
                [self.callBack updateSynonymError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
}

//Delete a synonym for a Ontology Word
-(void)deleteSynonymWithID:(NSString *)synonymID
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:DELETESYNONYM];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //session_token
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    //synonym_id
    [dict setObject:synonymID forKey:@"synonym_id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%ld", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            //NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError == nil)
            {
                //Success…lets parse
                [self.callBack deleteSynonymSuccess:[parsedObject valueForKey:@"message"]];
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createNewOntolgyWordWithError:)])
                {
                    [self.callBack deleteSynonymError:localError.description];
                }
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createNewOntolgyWordWithError:)])
            {
                [self.callBack deleteSynonymError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
}

//CreateContact
-(void)createContactWithNetworkID:(NSString *)networkID FirstName:(NSString *)fName lastName:(NSString *)lName emailAddress:(NSString *)emailID companyURL:(NSString *)companyUrl stockSymbol:(NSString *)stockSymbol outlookAddress:(NSString *)outlookID facebookURLs:(NSArray *)facebookURLs twitterIDs:(NSArray *)twitterIDs linkedInURls:(NSArray *)linkedInURLs RSSFeedNames:(NSArray *)rssFeedNames RSSFeedURLs:(NSArray *)rssFeedUrls
{
    NSLog(@"Network Id:%@",networkID);
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:CREATECONTACT];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //session_token
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    //network_id
    [dict setObject:networkID forKey:@"network_id"];
    //first_name
    [dict setObject:fName forKey:@"first_name"];
    //last_name
    [dict setObject:lName forKey:@"last_name"];
    //email_id
    [dict setObject:emailID forKey:@"email_id"];
    //company
    [dict setObject:companyUrl forKey:@"company"];
    //stock_symbol
    [dict setObject:stockSymbol forKey:@"stock_symbol"];
    //outlook_id
    [dict setObject:outlookID forKey:@"outlook_id"];
    //facebook_id
    [dict setObject:facebookURLs forKey:@"facebook_id"];
    //twitter_id
    [dict setObject:twitterIDs forKey:@"twitter_id"];
    //linkedin_id
    [dict setObject:linkedInURLs forKey:@"linkedin_id"];
    //rss_feed_name
    [dict setObject:rssFeedNames forKey:@"rss_feed_name"];
    //rss_feed_url
    [dict setObject:rssFeedUrls forKey:@"rss_feed_url"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%ld", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            //NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError == nil)
            {
                
                ContactBO *contact = [[ContactBO alloc] init];
                if ([parsedObject valueForKey:@"contact_details"]!=nil)
                {
                    NSDictionary *dict = [parsedObject valueForKey:@"contact_details"];
                    
                    
                    id contact_idCheck = [dict valueForKey:@"id"];
                    if (![contact_idCheck isKindOfClass:[NSNull class]])
                    {
                        contact.contact_id = [[dict valueForKey:@"id"] stringValue];
                    }
                    
                    id email_idCheck = [dict valueForKey:@"email_id"];
                    if (![email_idCheck isKindOfClass:[NSNull class]])
                    {
                        contact.email_id = [dict valueForKey:@"email_id"];
                    }
                    
                    id first_nameCheck = [dict valueForKey:@"first_name"];
                    if (![first_nameCheck isKindOfClass:[NSNull class]])
                    {
                        contact.first_name = [dict valueForKey:@"first_name"];
                    }
                    
                    id last_nameCheck = [dict valueForKey:@"last_name"];
                    if (![last_nameCheck isKindOfClass:[NSNull class]])
                    {
                        contact.last_name = [dict valueForKey:@"last_name"];
                    }
                    
                    id fbID_Check = [dict valueForKey:@"facebook_id"];
                    if (![fbID_Check isKindOfClass:[NSNull class]] && [(NSString*)fbID_Check length]!=0)
                    {
                        NSString *facebookString = [dict valueForKey:@"facebook_id"];
                        NSArray *fbIds = [facebookString componentsSeparatedByString:@"~"];
                        if ([fbIds count]>0)
                        {
                            NSMutableArray *ids = [[NSMutableArray alloc] init];
                            for (int i=0; i<[fbIds count]; i++)
                            {
                                [ids addObject:fbIds[i]];
                            }
                            contact.facebookIds = [NSArray arrayWithArray:ids];
                        }
                        //else contact.facebookIds = [NSArray arrayWithObjects:facebookString,nil];
                    }
                    
                    id twID_Check = [dict valueForKey:@"twitter_id"];
                    if (![twID_Check isKindOfClass:[NSNull class]] && [(NSString*)twID_Check length]!=0)
                    {
                        NSString *twitterString = [dict valueForKey:@"twitter_id"];
                        NSArray *twIds = [twitterString componentsSeparatedByString:@"~"];
                        if ([twIds count]>0)
                        {
                            NSMutableArray *ids = [[NSMutableArray alloc] init];
                            for (int i=0; i<[twIds count]; i++)
                            {
                                [ids addObject:twIds[i]];
                            }
                            contact.twitterIds = [NSArray arrayWithArray:ids];
                        }
                        //else contact.twitterIds = [NSArray arrayWithObjects:twitterString,nil];
                    }
                    
                    id linkedInID_Check = [dict valueForKey:@"linkedin_id"];
                    if (![linkedInID_Check isKindOfClass:[NSNull class]] && [(NSString*)linkedInID_Check length]!=0)
                    {
                        NSString *linkedInString = [dict valueForKey:@"linkedin_id"];
                        NSArray *linkedInIds = [linkedInString componentsSeparatedByString:@"~"];
                        if ([linkedInIds count]>0)
                        {
                            NSMutableArray *ids = [[NSMutableArray alloc] init];
                            for (int i=0; i<[linkedInIds count]; i++)
                            {
                                [ids addObject:linkedInIds[i]];
                            }
                            contact.linkedInUrls = [NSArray arrayWithArray:ids];
                        }
                        //else contact.linkedInUrls = [NSArray arrayWithObjects:linkedInString,nil];
                    }
                    
                    id RSSfeed_Check = [dict valueForKey:@"rss_feed"];
                    if (![RSSfeed_Check isKindOfClass:[NSNull class]] && [(NSString*)RSSfeed_Check length]!=0)
                    {
                        NSString *RSSFeedString = [dict valueForKey:@"rss_feed"];
                        NSArray *RSSFeeds = [RSSFeedString componentsSeparatedByString:@"~"];
                        if ([RSSFeeds count]>0)
                        {
                            NSMutableArray *ids = [[NSMutableArray alloc] init];
                            for (int i=0; i<[RSSFeeds count]; i++)
                            {
                                NSArray *rssDetails = [RSSFeeds[i] componentsSeparatedByString:@"=>"];
                                NSDictionary *rssFeedDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:rssDetails[0],rssDetails[1],nil] forKeys:[NSArray arrayWithObjects:@"Name",@"Url",nil]];
                                [ids addObject:rssFeedDict];
                            }
                            contact.RSSfeeds = [NSArray arrayWithArray:ids];
                        }
                        /*else
                         {
                         NSArray *rssDetails = [RSSFeedString componentsSeparatedByString:@"=>"];
                         NSDictionary *rssFeedDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:rssDetails[0],rssDetails[1],nil] forKeys:[NSArray arrayWithObjects:@"Name",@"Url",nil]];
                         contact.RSSfeeds = [NSArray arrayWithObjects:rssFeedDict,nil];
                         }*/
                    }
                    
                    id company_nameCheck = [dict valueForKey:@"company"];
                    if (![company_nameCheck isKindOfClass:[NSNull class]])
                    {
                        contact.company = [dict valueForKey:@"company"];
                    }
                    
                    id outlook_idCheck = [dict valueForKey:@"outlook_id"];
                    if (![outlook_idCheck isKindOfClass:[NSNull class]])
                    {
                        contact.outlookID = [dict valueForKey:@"outlook_id"];
                    }
                    
                    id stock_Check = [dict valueForKey:@"stock_symbol"];
                    if (![stock_Check isKindOfClass:[NSNull class]])
                    {
                        contact.stockSymbol = [dict valueForKey:@"stock_symbol"];
                    }
                    
                    //[arrMostWatchedNet addObject:contact];
                    //contact = nil;
                }
                else {
                    contact.contact_id = nil;
                }
                NSString *messageString;
                if ([parsedObject valueForKey:@"success"]!= nil)
                {
                    messageString = [parsedObject valueForKey:@"success"];
                }
                else
                {
                    messageString = [parsedObject valueForKey:@"message"];
                }
                [self.callBack createContactSuccess:[NSArray arrayWithObjects:messageString,contact,nil]];
                //Success…lets parse
                
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createContactWithError:)])
                {
                    [self.callBack createContactWithError:localError.description];
                }
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createContactWithError:)])
            {
                [self.callBack createContactWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
}


//UpdateContact
-(void)updateContactWithFirstName:(NSString *)fName lastName:(NSString *)lName emailAddress:(NSString *)emailID companyURL:(NSString *)companyUrl stockSymbol:(NSString *)stockSymbol outlookAddress:(NSString *)outlookID facebookURLs:(NSArray *)facebookURLs twitterIDs:(NSArray *)twitterIDs linkedInURls:(NSArray *)linkedInURLs RSSFeedNames:(NSArray *)rssFeedNames RSSFeedURLs:(NSArray *)rssFeedUrls andContactID:(NSString *)contactID
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:UPDATECONTACT];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //session_token
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    //contact_id
    [dict setObject:contactID forKey:@"contact_id"];
    //first_name
    [dict setObject:fName forKey:@"first_name"];
    //last_name
    [dict setObject:lName forKey:@"last_name"];
    //email_id
    [dict setObject:emailID forKey:@"email_id"];
    //company
    [dict setObject:companyUrl forKey:@"company"];
    //stock_symbol
    [dict setObject:stockSymbol forKey:@"stock_symbol"];
    //outlook_id
    [dict setObject:outlookID forKey:@"outlook_id"];
    //facebook_id
    [dict setObject:facebookURLs forKey:@"facebook_id"];
    //twitter_id
    [dict setObject:twitterIDs forKey:@"twitter_id"];
    //linkedin_id
    [dict setObject:linkedInURLs forKey:@"linkedin_id"];
    //rss_feed_name
    [dict setObject:rssFeedNames forKey:@"rss_feed_name"];
    //rss_feed_url
    [dict setObject:rssFeedUrls forKey:@"rss_feed_url"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];

    [request setValue:[NSString stringWithFormat:@"%ld", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            //NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError == nil)
            {
                //Success…lets parse
                ContactBO *contact = [[ContactBO alloc] init];
                if ([parsedObject valueForKey:@"contact_details"]!=nil)
                {
                    NSDictionary *dict = [parsedObject valueForKey:@"contact_details"];
                    
                    
                    id contact_idCheck = [dict valueForKey:@"id"];
                    if (![contact_idCheck isKindOfClass:[NSNull class]])
                    {
                        contact.contact_id = [[dict valueForKey:@"id"] stringValue];
                    }
                    
                    id email_idCheck = [dict valueForKey:@"email_id"];
                    if (![email_idCheck isKindOfClass:[NSNull class]])
                    {
                        contact.email_id = [dict valueForKey:@"email_id"];
                    }
                    
                    id first_nameCheck = [dict valueForKey:@"first_name"];
                    if (![first_nameCheck isKindOfClass:[NSNull class]])
                    {
                        contact.first_name = [dict valueForKey:@"first_name"];
                    }
                    
                    id last_nameCheck = [dict valueForKey:@"last_name"];
                    if (![last_nameCheck isKindOfClass:[NSNull class]])
                    {
                        contact.last_name = [dict valueForKey:@"last_name"];
                    }
                    
                    id fbID_Check = [dict valueForKey:@"facebook_id"];
                    if (![fbID_Check isKindOfClass:[NSNull class]] && [(NSString*)fbID_Check length]!=0)
                    {
                        NSString *facebookString = [dict valueForKey:@"facebook_id"];
                        NSArray *fbIds = [facebookString componentsSeparatedByString:@"~"];
                        if ([fbIds count]>0)
                        {
                            NSMutableArray *ids = [[NSMutableArray alloc] init];
                            for (int i=0; i<[fbIds count]; i++)
                            {
                                [ids addObject:fbIds[i]];
                            }
                            contact.facebookIds = [NSArray arrayWithArray:ids];
                        }
                        //else contact.facebookIds = [NSArray arrayWithObjects:facebookString,nil];
                    }
                    
                    id twID_Check = [dict valueForKey:@"twitter_id"];
                    if (![twID_Check isKindOfClass:[NSNull class]] && [(NSString*)twID_Check length]!=0)
                    {
                        NSString *twitterString = [dict valueForKey:@"twitter_id"];
                        NSArray *twIds = [twitterString componentsSeparatedByString:@"~"];
                        if ([twIds count]>0)
                        {
                            NSMutableArray *ids = [[NSMutableArray alloc] init];
                            for (int i=0; i<[twIds count]; i++)
                            {
                                [ids addObject:twIds[i]];
                            }
                            contact.twitterIds = [NSArray arrayWithArray:ids];
                        }
                        //else contact.twitterIds = [NSArray arrayWithObjects:twitterString,nil];
                    }
                    
                    id linkedInID_Check = [dict valueForKey:@"linkedin_id"];
                    if (![linkedInID_Check isKindOfClass:[NSNull class]] && [(NSString*)linkedInID_Check length]!=0)
                    {
                        NSString *linkedInString = [dict valueForKey:@"linkedin_id"];
                        NSArray *linkedInIds = [linkedInString componentsSeparatedByString:@"~"];
                        if ([linkedInIds count]>0)
                        {
                            NSMutableArray *ids = [[NSMutableArray alloc] init];
                            for (int i=0; i<[linkedInIds count]; i++)
                            {
                                [ids addObject:linkedInIds[i]];
                            }
                            contact.linkedInUrls = [NSArray arrayWithArray:ids];
                        }
                        //else contact.linkedInUrls = [NSArray arrayWithObjects:linkedInString,nil];
                    }
                    
                    id RSSfeed_Check = [dict valueForKey:@"rss_feed"];
                    if (![RSSfeed_Check isKindOfClass:[NSNull class]] && [(NSString*)RSSfeed_Check length]!=0)
                    {
                        NSString *RSSFeedString = [dict valueForKey:@"rss_feed"];
                        NSArray *RSSFeeds = [RSSFeedString componentsSeparatedByString:@"~"];
                        if ([RSSFeeds count]>0)
                        {
                            NSMutableArray *ids = [[NSMutableArray alloc] init];
                            for (int i=0; i<[RSSFeeds count]; i++)
                            {
                                NSArray *rssDetails = [RSSFeeds[i] componentsSeparatedByString:@"=>"];
                                NSDictionary *rssFeedDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:rssDetails[0],rssDetails[1],nil] forKeys:[NSArray arrayWithObjects:@"Name",@"Url",nil]];
                                [ids addObject:rssFeedDict];
                            }
                            contact.RSSfeeds = [NSArray arrayWithArray:ids];
                        }
                        /*else
                         {
                         NSArray *rssDetails = [RSSFeedString componentsSeparatedByString:@"=>"];
                         NSDictionary *rssFeedDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:rssDetails[0],rssDetails[1],nil] forKeys:[NSArray arrayWithObjects:@"Name",@"Url",nil]];
                         contact.RSSfeeds = [NSArray arrayWithObjects:rssFeedDict,nil];
                         }*/
                    }
                    
                    id company_nameCheck = [dict valueForKey:@"company"];
                    if (![company_nameCheck isKindOfClass:[NSNull class]])
                    {
                        contact.company = [dict valueForKey:@"company"];
                    }
                    
                    id outlook_idCheck = [dict valueForKey:@"outlook_id"];
                    if (![outlook_idCheck isKindOfClass:[NSNull class]])
                    {
                        contact.outlookID = [dict valueForKey:@"outlook_id"];
                    }
                    
                    id stock_Check = [dict valueForKey:@"stock_symbol"];
                    if (![stock_Check isKindOfClass:[NSNull class]])
                    {
                        contact.stockSymbol = [dict valueForKey:@"stock_symbol"];
                    }
                    
                    //[arrMostWatchedNet addObject:contact];
                    //contact = nil;
                }
                else {
                    contact.contact_id = nil;
                }
                [self.callBack updateContactSuccess:[NSArray arrayWithObjects:[parsedObject valueForKey:@"message"],contact,nil]];
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(updateContactWithError:)])
                {
                    [self.callBack updateContactWithError:localError.description];
                }
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(updateContactWithError:)])
            {
                [self.callBack updateContactWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
}

//DeleteContact
-(void)deleteContactWithContactID:(NSString *)contactID
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:DELETECONTACT];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //session_token
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    //contact_id
    [dict setObject:contactID forKey:@"contact_id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%ld", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            //NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError == nil)
            {
                //Success…lets parse
                [self.callBack deleteContactSuccess:[parsedObject valueForKey:@"message"]withDeletedContactID:[[[parsedObject valueForKey:@"contact_details"] valueForKey:@"id"] stringValue]];
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteContactWithError:)])
                {
                    [self.callBack deleteContactWithError:localError.description];
                }
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteContactWithError:)])
            {
                [self.callBack deleteContactWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
}
-(void)searchAllSynonymsForWord:(NSString*)wordStr
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:SEARCHALLSYNONYMS];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //session_token
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    //search_value
    [dict setObject:wordStr forKey:@"search_value"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%ld", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            //NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError == nil)
            {
                //Success…lets parse
                if ([parsedObject valueForKey:@"word"]!=nil)
                {
                    NSDictionary *wordDataDict = [parsedObject valueForKey:@"word"];
                    WordBO *word = [[WordBO alloc] init];
                    word.identifier = [wordDataDict valueForKey:@"id"];
                    word.textValue = [wordDataDict valueForKey:@"word"];
                    if ([parsedObject valueForKey:@"synonyms"]!=nil)
                    {
                        NSMutableArray *parsedSynonymsArray = [[NSMutableArray alloc] init];
                        NSArray *synonymsArray = [parsedObject valueForKey:@"synonyms"];
                        for (int i=0; i<[synonymsArray count]; i++)
                        {
                            NSDictionary *dataDict = synonymsArray[i];
                            SynonymsBO *synonym = [[SynonymsBO alloc] init];
                            synonym.identifier = [dataDict valueForKey:@"id"];
                            synonym.textValue = [dataDict valueForKey:@"synonym"];
                            [parsedSynonymsArray addObject:synonym];
                        }
                        word.synonyms = [NSArray arrayWithArray:parsedSynonymsArray];
                        [self.callBack searchAllSynonymsForWordSuccess:word];
                    }
                }
                
                else
                {
                    [self.callBack searchAllSynonymsForWordSuccess:[parsedObject valueForKey:@"success"]];
                }
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteContactWithError:)])
                {
                    [self.callBack searchAllSynonymsForWordError:localError.description];
                }
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteContactWithError:)])
            {
                [self.callBack searchAllSynonymsForWordError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
}
//All Network Filters
-(void)getAllNetworkFilters
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:ALLNETWORKFILTER];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //session_token
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%ld", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            //NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError == nil)
            {
                if ([[parsedObject valueForKey:@"success"] isKindOfClass:[NSString class]])
                {
                    //This is for NO Records found
                    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getAllNetworkFiltersWithError:)])
                    {
                        [self.callBack getAllNetworkFiltersWithError:[parsedObject valueForKey:@"success"]];
                    }
                    return;
                }
                //Success…lets parse
                NSMutableArray *filtersArray = [[NSMutableArray alloc] init];
                for (int i=0; i<[parsedObject count]; i++)
                {
                    NetworkFilterBO *networkFilter = [[NetworkFilterBO alloc] init];
                    NSDictionary *dataDict = parsedObject[i];
                    networkFilter.identifier = [dataDict valueForKey:@"network_id"];
                    networkFilter.name = [dataDict valueForKey:@"network_name"];
                    networkFilter.filterNames = [dataDict valueForKey:@"filter_with"];
                    NSMutableArray *filterDetailsArray = [[NSMutableArray alloc] init];
                    for (int j=0; j<[[dataDict valueForKey:@"filter_details"] count]; j++)
                    {
                        NSDictionary *wordDetailsDict = [dataDict valueForKey:@"filter_details"][j];
                        WordBO *word = [[WordBO alloc] init];
                        word.identifier = [wordDetailsDict valueForKey:@"master_id"];
                        word.textValue = [wordDetailsDict valueForKey:@"master_word"];
                        NSMutableArray *synonymsArray = [[NSMutableArray alloc] init];
                        for (int k=0; k<[[wordDetailsDict valueForKey:@"synonyms"] count]; k++)
                        {
                            NSDictionary *synDetailsDict = [wordDetailsDict valueForKey:@"synonyms"][k];
                            SynonymsBO *synonym = [[SynonymsBO alloc] init];
                            synonym.identifier = [synDetailsDict valueForKey:@"synonym_id"];
                            synonym.textValue = [synDetailsDict valueForKey:@"synonym"];
                            [synonymsArray addObject:synonym];
                        }
                        word.synonyms = [NSArray arrayWithArray:synonymsArray];
                        [filterDetailsArray addObject:word];
                    }
                    networkFilter.words = [NSArray arrayWithArray:filterDetailsArray];
                    [filtersArray addObject:networkFilter];
                }
                
                [self.callBack getAllNetworkFiltersSuccess:[NSArray arrayWithArray:filtersArray]];
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getAllNetworkFiltersWithError:)])
                {
                    [self.callBack getAllNetworkFiltersWithError:localError.description];
                }
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getAllNetworkFiltersWithError:)])
            {
                [self.callBack getAllNetworkFiltersWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
}

//Create Network Filters
-(void)createNewNetworkFilterWithMasterId:(NSString *)masterIdentifier Synonyms:(NSArray *)synonymsIDArr andNetworkID:(NSArray *)networkIDArr
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:CREATENETWORKFILTER];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //session_token
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    //master_id
    [dict setObject:masterIdentifier forKey:@"master_id"];
    //networks
    [dict setObject:networkIDArr forKey:@"networks"];
    //master_id
    [dict setObject:synonymsIDArr forKey:@"synonym_checkbox"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%ld", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            //NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError == nil)
            {
                //Success…lets parse
                [self.callBack createNetworkFilterSuccess:[parsedObject[0] valueForKey:@"message"]];
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteContactWithError:)])
                {
                    [self.callBack createNetworkFilterWithError:localError.description];
                }
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteContactWithError:)])
            {
                [self.callBack createNetworkFilterWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
}

//Update Network Filters
-(void)updateNetworkFilterWithMasterId:(NSString *)masterIdentifier Synonyms:(NSArray *)synonymsIDArr andNetworkFilterId:(NSString *)filterID
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:UPDATENETWORKFILTER];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //session_token
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    //network_id
    [dict setObject:filterID forKey:@"network_id"];
    //synonyms_check
    if (synonymsIDArr.count>0)
    {
        NSArray *synonyms = [synonymsIDArr valueForKeyPath:@"identifier"];
        [dict setObject:synonyms forKey:@"synonyms_check"];
    }
    else [dict setObject:synonymsIDArr forKey:@"synonyms_check"];
    //master_id
    [dict setObject:masterIdentifier forKey:@"master_id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%ld", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            //NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError == nil)
            {
                //Success…lets parse
                if ([parsedObject[0] valueForKey:@"message"]!=nil)
                {
                    [self.callBack updateNetworkFilterSuccess:[parsedObject[0] valueForKey:@"message"]];
                }
                else
                {
                    [self.callBack updateNetworkFilterSuccess:[parsedObject lastObject]];
                }
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteContactWithError:)])
                {
                    [self.callBack updateNetworkFilterWithError:localError.description];
                }
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteContactWithError:)])
            {
                [self.callBack updateNetworkFilterWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
}

//Delete Network Filters
-(void)deleteNetworkFilterWithNetworkFilterId:(NSString *)filterID andOptionalWordId:(NSString *)wordID
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:DELETENETWORKFILTER];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //session_token
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    //network_id
    [dict setObject:filterID forKey:@"network_id"];
    if (wordID != nil)
    {
        //master_id
        [dict setObject:wordID forKey:@"master_id"];
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%ld", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            //NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError == nil)
            {
                //Success…lets parse
                [self.callBack deleteNetworkFilterSuccess:[parsedObject valueForKey:@"message"]];
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteContactWithError:)])
                {
                    [self.callBack deleteContactWithError:localError.description];
                }
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteContactWithError:)])
            {
                [self.callBack deleteContactWithError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
}


-(void)getNetworkFilterNames
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:FILTERNETWORKS];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //session_token
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%ld", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            //NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError == nil)
            {
                //Success…lets parse
                NSMutableArray *networks = [[NSMutableArray alloc] init];
                for (int i=0; i<parsedObject.count; i++)
                {
                    NSDictionary *dataDict = parsedObject[i];
                    NetworkBO *currentNetwork = [[NetworkBO alloc] init];
                    currentNetwork.networkId = [dataDict valueForKey:@"network_id"];
                    currentNetwork.name = [dataDict valueForKey:@"network_name"];
                    [networks addObject:currentNetwork];
                }
                [self.callBack getNetworkFilterNamesSuccess:[NSArray arrayWithArray:networks]];
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getNetworkFilterNamesError:)])
                {
                    [self.callBack getNetworkFilterNamesError:localError.description];
                }
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getNetworkFilterNamesError:)])
            {
                [self.callBack getNetworkFilterNamesError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
}

-(void)editNetworkFilterWithIdentifier:(NSString *)identifier
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:EDITNETWORK];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //session_token
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    //network_id
    [dict setObject:identifier forKey:@"network_id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%ld", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            //NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError == nil)
            {
                //Success…lets parse
                NSMutableArray *synonymsArray = [[NSMutableArray alloc] init];
                for (int i=0; i<parsedObject.count; i++)
                {
                    NSMutableArray *arrayData = [[NSMutableArray alloc] initWithArray:parsedObject[i]];
                    [arrayData removeObjectAtIndex:0];
                    for (int i=0; i<arrayData.count;i++)
                    {
                        NSDictionary *dataDict = [[arrayData objectAtIndex:i] valueForKey:@"synonym"];
                        SynonymsBO *synonym = [[SynonymsBO alloc] init];
                        synonym.wordIdentifier = [dataDict valueForKey:@"master_id"];
                        synonym.identifier = [dataDict valueForKey:@"id"];
                        synonym.textValue = [dataDict valueForKey:@"synonym"];
                        [synonymsArray addObject:synonym];
                    }
                }
                [self.callBack editNetworkFilterSuccess:[NSArray arrayWithArray:synonymsArray]];
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(editNetworkFilterError:)])
                {
                    [self.callBack editNetworkFilterError:localError.description];
                }
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(editNetworkFilterError:)])
            {
                [self.callBack editNetworkFilterError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
}

-(void)getAllBuzzboardContactsForNetworkID:(NSString *)networkID
{
    NSError *error;
    
    NSString *strUrl = [NSString stringWithFormat:NETWORKSBUZZCONTACTS];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_token"] forKey:@"session_token"];
    
    [dict setObject:networkID forKey:@"network_id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError==nil)
        {
            NSError *localError = nil;
            
            NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            //NSLog(@"existingUserLoginWith: parsedObject:%@",parsedObject.description);
            if(localError== nil)
            {
                //NSLog(@"Buzz board contacts:%d",[[parsedObject valueForKey:@"details"] count]);
                
                NSArray *buzzContactsDataArray = [parsedObject valueForKey:@"details"];
                NSMutableArray *buzzBoardContacts = [[NSMutableArray alloc] init];
                
                NSArray *contactIdArray = [buzzContactsDataArray valueForKeyPath:@"id"];
                for (id obj in contactIdArray)
                {
                    [buzzBoardContacts addObject:[obj stringValue]];
                }
                
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getBuzzContactsSuccess:)])
                {
                    [self.callBack getBuzzContactsSuccess:buzzBoardContacts];
                }
                buzzBoardContacts = nil;
                
                
            }
            else
            {
                if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getBuzzContactsError:)])
                {
                    [self.callBack getBuzzContactsError:localError.description];
                }
            }
        }
        else
        {
            if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getBuzzContactsError:)])
            {
                [self.callBack getBuzzContactsError:[connectionError.userInfo valueForKey:NSLocalizedDescriptionKey]];
            }
            
        }
    }];
    
}

@end
