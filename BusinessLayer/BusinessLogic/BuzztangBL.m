//
//  BuzztangBL.m
//  Buzztang
//

//

#import "BuzztangBL.h"
#import "BuzztangWL.h"
#import "AppDelegate.h"
#import "StringConstant.h"

#define APPDELEGATE ((AppDelegate *)[[UIApplication sharedApplication]delegate])

@implementation BuzztangBL


-(void)doLogInWithEmail:(NSString *)email withPassword:(NSString *)password
{
	if(APPDELEGATE.isServerReachable)
	{
		BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
		buzztangWL.callBack = self;
		[buzztangWL doLogInWithEmail:email withPassword:password];
		buzztangWL = nil;
	}
	else
	{
		[self loginFailuerWithError:NoInternateConnextionMsg];
	}
}


-(void)loginSuccess
{
	if(self.callBack != nil  && [self.callBack respondsToSelector:@selector(loginSuccess)])
	{
		[self.callBack loginSuccess];
	}
}
-(void)loginFailuerWithError:(NSString *)error
{

	if(self.callBack != nil && [self.callBack respondsToSelector:@selector(loginFailuerWithError:)])
	{
		[self.callBack loginFailuerWithError:[self getErrorMsgWith:error]];
	}
}


-(void)doSignUpWithUserName:(NSString *)userName withPassword:(NSString *)password withEmailId:(NSString *)emailId
{
	if(APPDELEGATE.isServerReachable)
	{
		BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
		buzztangWL.callBack = self;
		[buzztangWL doSignUpWithUserName:userName withPassword:password withEmailId:emailId];
		buzztangWL = nil;
	}
	else
	{
		[self signUpFailuerWithError:NoInternateConnextionMsg];
	}
}

-(void)signUpSuccess
{
	if(self.callBack != nil  && [self.callBack respondsToSelector:@selector(signUpSuccess)])
	{
		[self.callBack signUpSuccess];
	}

}
-(void)signUpFailuerWithError:(NSString *)error
{
	if(self.callBack != nil && [self.callBack respondsToSelector:@selector(signUpFailuerWithError:)])
	{
		[self.callBack signUpFailuerWithError:[self getErrorMsgWith:error]];
	}

}
-(void)getNewPasswordWithEmailId:(NSString *)emailId{
    
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL getNewPasswordWithEmailId:emailId];
        buzztangWL = nil;
    }
    else
    {
        [self newPasswordFailuerWithError:NoInternateConnextionMsg];
    }
    
}


-(void)newPasswordSuccess
{
    if(self.callBack != nil  && [self.callBack respondsToSelector:@selector(newPasswordSuccess)])
    {
        [self.callBack newPasswordSuccess];
    }
    
}
-(void)newPasswordFailuerWithError:(NSString *)error{
    
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(newPasswordFailuerWithError:)])
    {
        [self.callBack newPasswordFailuerWithError:[self getErrorMsgWith:error]];
    }
    
}

-(void)getBuzzboardData
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL getBuzzboardData];
        buzztangWL = nil;
    }
    else
    {
        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(buzzboardDataFailuerWithError:)])
        {
            [self.callBack buzzboardDataFailuerWithError:NoInternateConnextionMsg];
        }
    }
    
}
-(void)buzzboardDataReceivedWith:(BuzzBoardBO *)buzzboard
{
    if(self.callBack != nil &&  [self.callBack respondsToSelector:@selector(buzzboardDataReceivedWith:)])
    {
        [self.callBack buzzboardDataReceivedWith:buzzboard];
    }
    
}
-(void)buzzboardDataFailuerWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(buzzboardDataFailuerWithError:)])
    {
        [self.callBack buzzboardDataFailuerWithError:[self getErrorMsgWith:error]];
    }
}


-(void)checkLogInCredentialwith:(UserInfoBO *)userInfo
{
    userBO = userInfo;
    
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL checkLogInCredentialwith:userInfo];
        buzztangWL = nil;
    }
    else
    {
        [self checkLogInCredentialFailuerWithError:NoInternateConnextionMsg];
    }

}

-(void)checkLogInCredentialSucceswith:(UserInfoBO *)userInfo;

{
    if(userInfo){
        [self existingUserLoginWith:userInfo];
    }
    else{
        
        [self doSignUpWithUserName:userBO.userName withPassword:userBO.password withEmailId:userBO.emailID];
    }
}


-(void)checkLogInCredentialFailuerWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(checkLogInCredentialFailuerWithError:)])
    {

        [self.callBack checkLogInCredentialFailuerWithError:[self getErrorMsgWith:error]];
    }
    
}

-(void)existingUserLoginWith:(UserInfoBO *)userInfo
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL existingUserLoginWith:userInfo];
        buzztangWL = nil;
    }
    else
    {
        [self checkLogInCredentialFailuerWithError:NoInternateConnextionMsg];
    }

}




-(void)getNetWorkDetailWithid:(NSString *)networkID
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL getNetWorkDetailWithid:networkID];
        buzztangWL = nil;
    }
    else
    {
        [self netWorkDetailDataFailuerWithError:NoInternateConnextionMsg];
    }

}

-(void)netWorkDetailDataSucceswith:(NetworkBO *)network
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(netWorkDetailDataSucceswith:)])
    {
        [self.callBack netWorkDetailDataSucceswith:network];
    }
}
-(void)netWorkDetailDataFailuerWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(netWorkDetailDataFailuerWithError:)])
    {
        [self.callBack netWorkDetailDataFailuerWithError:[self getErrorMsgWith:error]];
    }

}
-(void)getNetWorkWithUrl:(NSString *)urls
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL getNetWorkWithUrl:urls];
        buzztangWL = nil;
    }
    else
    {
        [self myNetworkDataFailuerWithError:NoInternateConnextionMsg];
    }

}
-(void)myNetworkDataSucceswith:(NSMutableArray  *)arrNetwork
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(myNetworkDataSucceswith:)])
    {
        [self.callBack myNetworkDataSucceswith:arrNetwork];
    }
}
-(void)myNetworkDataFailuerWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(myNetworkDataFailuerWithError:)])
    {
        [self.callBack myNetworkDataFailuerWithError:[self getErrorMsgWith:error]];
    }
    
}

-(void)getAvailableNetworkData
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL getAvailableNetworkData];
        buzztangWL = nil;
    }
    else
    {
        [self availableNetworkDataFailuerWithError:NoInternateConnextionMsg];
    }

}
-(void)availableNetworkDataSucceswith:(NSMutableArray  *)arrNetwork
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(availableNetworkDataSucceswith:)])
    {
        [self.callBack availableNetworkDataSucceswith:arrNetwork];
    }

}
-(void)availableNetworkDataFailuerWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(availableNetworkDataFailuerWithError:)])
    {
        [self.callBack availableNetworkDataFailuerWithError:[self getErrorMsgWith:error]];
    }
 
}

-(void)getSearchResultWithCriteria:(NSString *)criteria
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL getSearchResultWithCriteria:criteria];
        buzztangWL = nil;
    }
    else
    {
        [self searchResultWithCriteriaDataFailuerWithError:NoInternateConnextionMsg];
    }
 
}
-(void)searchResultWithCriteriaDataSuccesWith:(NSMutableArray  *)arrNetwork
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(searchResultWithCriteriaDataSuccesWith:)])
    {
        [self.callBack searchResultWithCriteriaDataSuccesWith:arrNetwork];
    }

}
-(void)searchResultWithCriteriaDataFailuerWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(searchResultWithCriteriaDataFailuerWithError:)])
    {
        [self.callBack searchResultWithCriteriaDataFailuerWithError:[self getErrorMsgWith:error]];
    }
    

}
-(void)creatNetworkWithObject:(NetworkBO *)network
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL creatNetworkWithObject:network];
        buzztangWL = nil;
    }
    else
    {
        [self searchResultWithCriteriaDataFailuerWithError:NoInternateConnextionMsg];
    }
 
}

-(void)creatNetworkSucces
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(creatNetworkSucces)])
    {
        [self.callBack creatNetworkSucces];
    }

}
-(void)creatNetworkFailuerWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(creatNetworkFailuerWithError:)])
    {
        [self.callBack creatNetworkFailuerWithError:[self getErrorMsgWith:error]];
    }

}
-(void)joinNetWorkWithObject:(NetworkBO *)network
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL joinNetWorkWithObject:network];
        buzztangWL = nil;
    }
    else
    {
        [self joinNetWorkFailuerWithError:NoInternateConnextionMsg];
    }
    
}
-(void)joinNetWorkSucces
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(joinNetWorkSucces)])
    {
        [self.callBack joinNetWorkSucces];
    }
 
}
-(void)joinNetWorkFailuerWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(joinNetWorkFailuerWithError:)])
    {
        [self.callBack joinNetWorkFailuerWithError:[self getErrorMsgWith:error]];
    }

}

-(void)getContactsWithNetworkId:(NSString *)networkId
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL getContactsWithNetworkId:networkId];
        buzztangWL = nil;
    }
    else
    {
        [self contactsDataFailuerWithError:NoInternateConnextionMsg];
    }
    
 
}

-(void)contactsDataSuccesWith:(NSMutableArray  *)arrContact
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(contactsDataSuccesWith:)])
    {
        [self.callBack contactsDataSuccesWith:arrContact];
    }

}
-(void)contactsDataFailuerWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(contactsDataFailuerWithError:)])
    {
        [self.callBack contactsDataFailuerWithError:[self getErrorMsgWith:error]];
    }
 
}
-(void)getNewContactsWithNetworkId:(NSString *)networkID
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL getNewContactsWithNetworkId:networkID];
        buzztangWL = nil;
    }
    else
    {
        [self newContactsDataFailuerWithError:NoInternateConnextionMsg];
    }
}
-(void)newContactsDataSuccesWith:(NSMutableArray  *)arrContact
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(newContactsDataSuccesWith:)])
    {
        [self.callBack newContactsDataSuccesWith:arrContact];
    }

}
-(void)newContactsDataFailuerWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(newContactsDataFailuerWithError:)])
    {
        [self.callBack newContactsDataFailuerWithError:[self getErrorMsgWith:error]];
    }

}

-(void)deleteNetWorkWithObject:(NetworkBO *)network
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL deleteNetWorkWithObject:network];
        buzztangWL = nil;
    }
    else
    {
        [self joinNetWorkFailuerWithError:NoInternateConnextionMsg];
    }
    
}
-(void)deleteNetWorkSucceswithMsg:(NSString *)message
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteNetWorkSucceswithMsg:)])
    {
        [self.callBack deleteNetWorkSucceswithMsg:message];
    }

}
-(void)deleteNetWorkFailuerWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteNetWorkFailuerWithError:)])
    {
        [self.callBack deleteNetWorkFailuerWithError:[self getErrorMsgWith:error]];
    }

}
-(void)addNetworkToBuzzboardWithNetworkId:(NSString *)networkId
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL addNetworkToBuzzboardWithNetworkId:networkId];
        buzztangWL = nil;
    }
    else
    {
        [self addNetworkToBuzzboardWithNetworkIdFailuerWithError:NoInternateConnextionMsg];
    }

}
-(void)addNetworkToBuzzboardWithNetworkIdSucces
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(addNetworkToBuzzboardWithNetworkIdSucces)])
    {
        [self.callBack addNetworkToBuzzboardWithNetworkIdSucces];
    }

}
-(void)addNetworkToBuzzboardWithNetworkIdFailuerWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(addNetworkToBuzzboardWithNetworkIdFailuerWithError:)])
    {
        [self.callBack addNetworkToBuzzboardWithNetworkIdFailuerWithError:[self getErrorMsgWith:error]];
    }
 
}
-(void)removeNetworkFromBuzzboardWithNetworkId:(NSString *)networkId
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL removeNetworkFromBuzzboardWithNetworkId:networkId];
        buzztangWL = nil;
    }
    else
    {
        [self removeNetworkFromBuzzboardFailuerWithError:NoInternateConnextionMsg];
    }
 
}
-(void)removeNetworkFromBuzzboardSucceswithMsg:(NSString *)message
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(removeNetworkFromBuzzboardSucceswithMsg:)])
    {
        [self.callBack removeNetworkFromBuzzboardSucceswithMsg:message];
    }
  
}
-(void)removeNetworkFromBuzzboardFailuerWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(removeNetworkFromBuzzboardFailuerWithError:)])
    {
        [self.callBack removeNetworkFromBuzzboardFailuerWithError:[self getErrorMsgWith:error]];
    }

}

-(void)dropFromNetworkWithNetworkId:(NSString *)networkId
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL addNetworkToBuzzboardWithNetworkId:networkId];
        buzztangWL = nil;
    }
    else
    {
        [self dropFromNetworkFailuerWithError:NoInternateConnextionMsg];
    }
 
}

-(void)dropFromNetworkSucceswithMsg:(NSString *)message
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(dropFromNetworkSucceswithMsg:)])
    {
        [self.callBack dropFromNetworkSucceswithMsg:message];
    }

}
-(void)dropFromNetworkFailuerWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(dropFromNetworkFailuerWithError:)])
    {
        [self.callBack dropFromNetworkFailuerWithError:[self getErrorMsgWith:error]];
    }
 
}
-(void)addContactToBuzzboardWith:(NSString *)networkId andcontactId:(NSString *)contactId
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL addContactToBuzzboardWith:networkId andcontactId:contactId];
        buzztangWL = nil;
    }
    else
    {
        [self addContactToBuzzboardFailuerWithError:NoInternateConnextionMsg];
    }
 
}
-(void)addContactToBuzzboardSucceswithMsg:(NSString *)message
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(addContactToBuzzboardSucceswithMsg:)])
    {
        [self.callBack addContactToBuzzboardSucceswithMsg:message];
    }

}
-(void)addContactToBuzzboardFailuerWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(addContactToBuzzboardFailuerWithError:)])
    {
        [self.callBack addContactToBuzzboardFailuerWithError:[self getErrorMsgWith:error]];
    }
 
}
-(void)removeContactToBuzzboardWith:(NSString *)networkId andcontactId:(NSString *)contactId
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL removeContactToBuzzboardWith:networkId andcontactId:contactId];
        buzztangWL = nil;
    }
    else
    {
        [self removeContactToBuzzboardFailuerWithError:NoInternateConnextionMsg];
    }
   
}
-(void)removeContactToBuzzboardSucceswithMsg:(NSString *)message
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(removeContactToBuzzboardSucceswithMsg:)])
    {
        [self.callBack removeContactToBuzzboardSucceswithMsg:message];
    }
    

}
-(void)removeContactToBuzzboardFailuerWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(removeContactToBuzzboardFailuerWithError:)])
    {
        [self.callBack removeContactToBuzzboardFailuerWithError:[self getErrorMsgWith:error]];
    }
}

-(NSString *)getErrorMsgWith:(NSString *)error
{
    
    NSRange range = [error rangeOfString:@"network connection was lost" options:NSCaseInsensitiveSearch];
    NSRange rangeNet = [error rangeOfString:@"Could not connect to the server" options:NSCaseInsensitiveSearch];
    
    NSRange rangeNet1 = [error rangeOfString:@"Code=-1009" options:NSCaseInsensitiveSearch];
    NSRange rangeNet2 = [error rangeOfString:@"offline" options:NSCaseInsensitiveSearch];
    
    if(!(range.location == NSNotFound))
    {
        error = NoInternateConnextionMsg;
    }
    else if (!(rangeNet.location == NSNotFound))
    {
        error = NoInternateConnextionMsg;
    }
    
    else if (!(rangeNet1.location == NSNotFound))
    {
        error = NoInternateConnextionMsg;
    }
    else if (!(rangeNet2.location == NSNotFound))
    {
        error = NoInternateConnextionMsg;
    }
    
    return error;
    
    

}
-(void)getUserProfileDetails{
    
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL getUserProfileDetails];
        buzztangWL = nil;
    }
    else
    {
        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getUserProfileDetailsWithError:)])
        {
            [self.callBack getUserProfileDetailsWithError:NoInternateConnextionMsg];
        }
    }
 
    
}

-(void)getUserProfileDetailsSuccess:(UserProfileBO *)userProfile{
    if(self.callBack != nil &&  [self.callBack respondsToSelector:@selector(getUserProfileDetailsSuccess:)])
    {
       

        [self.callBack getUserProfileDetailsSuccess:userProfile];
    }
    
}
-(void)getUserProfileDetailsWithError:(NSString *)error{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getUserProfileDetailsWithError:)])
    {
        [self.callBack getUserProfileDetailsWithError:[self getErrorMsgWith:error]];
    }

}
-(void)ChangePasswordWithOldPassword:(NSString *)oldPassword withNewPassword:(NSString *)newPassword withConfirmationPassword:(NSString *)confirmationPassword{
    
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL ChangePasswordWithOldPassword:oldPassword withNewPassword:newPassword withConfirmationPassword:confirmationPassword];
        buzztangWL = nil;
    }
    else
    {
        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(changePasseordWithError:)])
        {
            [self.callBack changePasseordWithError:NoInternateConnextionMsg];
        }
    }
 
    
}
-(void)changePasseordSuccess:(NSString *)message
{
    if(self.callBack != nil &&  [self.callBack respondsToSelector:@selector(changePasseordSuccess:)])
    {
        [self.callBack changePasseordSuccess:message];
    }

}
-(void)changePasseordWithError:(NSString *)error{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(changePasseordWithError:)])
    {
        [self.callBack changePasseordWithError:[self getErrorMsgWith:error]];
    }
 
    
}
-(void)editUserProfileDetailsWithFirstName:(NSString *)firstName withLastName:(NSString *)lastName withAddress:(NSString *)address withTimeZone:(NSString *)timezone
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL editUserProfileDetailsWithFirstName:firstName withLastName:lastName withAddress:address withTimeZone:timezone];
        buzztangWL = nil;
    }
    else
    {
        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(editUserProfileWithError:)])
        {
            [self.callBack editUserProfileWithError:NoInternateConnextionMsg];
        }
    }
    
}

-(void)editUserProfileSuccess:(NSDictionary *)messageDict
{
    if(self.callBack != nil &&  [self.callBack respondsToSelector:@selector(editUserProfileSuccess:)])
    {
        [self.callBack editUserProfileSuccess:messageDict];
    }
    
}
-(void)editUserProfileWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(editUserProfileWithError:)])
    {
        [self.callBack editUserProfileWithError:[self getErrorMsgWith:error]];
    }
    
    
}

-(void)getUserHistory{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL getUserHistory];
        buzztangWL = nil;
    }
    else
    {
        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getUserHistoryWithError:)])
        {
            [self.callBack getUserHistoryWithError:NoInternateConnextionMsg];
        }
    }


}
-(void)getUserHistorySuccess:(NSArray *)arrHistory
{
    if(self.callBack != nil &&  [self.callBack respondsToSelector:@selector(getUserHistorySuccess:)])
    {
        [self.callBack getUserHistorySuccess:arrHistory];
    }
    
    
}
-(void)getUserHistoryWithError:(NSString *)error{
    
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getUserHistoryWithError:)])
    {
        [self.callBack getUserHistoryWithError:[self getErrorMsgWith:error]];
    }
    
}

-(void)getBuzzDataWithNetworkId:(NSString *)networkId{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL getBuzzDataWithNetworkId:networkId];
        buzztangWL = nil;
    }
    else
    {
        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getUserHistoryWithError:)])
        {
            [self.callBack getUserHistoryWithError:NoInternateConnextionMsg];
        }
    }

    
}
-(void)getBuzzDataSuccess:(NSArray *)arrBazzData
{
    if(self.callBack != nil &&  [self.callBack respondsToSelector:@selector(getBuzzDataSuccess:)])
    {
        [self.callBack getBuzzDataSuccess:arrBazzData];
    }
    
    
}
-(void)getBuzzDataSuccessContacts:(NSArray *)arrBazzContacts
{
    if(self.callBack != nil &&  [self.callBack respondsToSelector:@selector(getBuzzDataSuccessContacts:)])
    {
        [self.callBack getBuzzDataSuccessContacts:arrBazzContacts];
    }
    
    
}
-(void)getBuzzDataSuccessNetworks:(NSArray *)arrBazzNetworks
{
    if(self.callBack != nil &&  [self.callBack respondsToSelector:@selector(getBuzzDataSuccessNetworks:)])
    {
        [self.callBack getBuzzDataSuccessNetworks:arrBazzNetworks];
    }
    
    
}
-(void)getBuzzDataWithError:(NSString *)error
{
    
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getBuzzDataWithError:)])
    {
        [self.callBack getBuzzDataWithError:[self getErrorMsgWith:error]];
    }
    
}


-(void)createContactWithFirstName:(NSString *)firstName withLastName:(NSString *)lastName withEmail:(NSString *)email withCompany:(NSString *)companyName withOutlookId:(NSString *)outlookId withStockSymbol:(NSString *)stockSymbol withCity:(NSString *)city withFacebookUrls:(NSArray *)arrFacebookUrl withTwitterUrls:(NSArray *)arrTwitter withLinkedinUrls:(NSArray *)arrLinkedInUrl withRssFeedName:(NSArray *)arrRssFeedsName withRssFeedsUrls:(NSArray *)arrRssFeedsUrl
{
   
    
    
    
    
    
    
    
    
    
    
}

/*Ontology managemnet*/
-(void)getAllOntologyWordsForCurrentSession
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL getAllOntologyWordsForCurrentSession];
        buzztangWL = nil;
    }
    else
    {
        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getAllOntolgyWordError:)])
        {
            [self.callBack getAllOntolgyWordError:NoInternateConnextionMsg];
        }
    }
}
//CreatenewOntologyWord
-(void)createNewOntologyWordWithSearchValue:(NSString *)searchStr synonyms:(NSArray *)synonymsArr andExtraWords:(NSString *)extraWordsStr
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL createNewOntologyWordWithSearchValue:searchStr synonyms:synonymsArr andExtraWords:extraWordsStr];
        buzztangWL = nil;
    }
    else
    {
        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getUserHistoryWithError:)])
        {
            [self.callBack createNewOntolgyWordWithError:NoInternateConnextionMsg];
        }
    }
}
//Delete Ontology word
-(void)deleteOntologyWordWithID:(NSString *)ontologyWordID
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL deleteOntologyWordWithID:ontologyWordID];
        buzztangWL = nil;
    }
    else
    {
        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteOntolgyWordWithError:)])
        {
            [self.callBack deleteOntolgyWordWithError:NoInternateConnextionMsg];
        }
    }
}
//Update Ontology word
-(void)updateOntologyWord:(NSString *)newOntologyWordStr WithID:(NSString *)ontologyWordID
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL updateOntologyWord:newOntologyWordStr WithID:ontologyWordID];
        buzztangWL = nil;
    }
    else
    {
        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(updateOntolgyWordWithError:)])
        {
            [self.callBack updateOntolgyWordWithError:NoInternateConnextionMsg];
        }
    }
}

//Delegates for Ontology management
-(void)getAllOntolgyWordSuccess:(NSArray *)allOntologyWords
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getAllOntolgyWordSuccess:)])
    {
        [self.callBack getAllOntolgyWordSuccess:allOntologyWords];
    }
}
-(void)getAllOntolgyWordError:(NSString *)errorMsg
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getAllOntolgyWordError:)])
    {
        [self.callBack getAllOntolgyWordError:errorMsg];
    }
}

-(void)createNewOntolgyWordSuccess:(NSString *)strMessage
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createNewOntolgyWordSuccess:)])
    {
        [self.callBack createNewOntolgyWordSuccess:strMessage];
    }
}
-(void)createNewOntolgyWordWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createNewOntolgyWordWithError:)])
    {
        [self.callBack createNewOntolgyWordWithError:error];
    }
}

-(void)deleteOntolgyWordSuccess:(NSString *)strMessage
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteOntolgyWordSuccess:)])
    {
        [self.callBack deleteOntolgyWordSuccess:strMessage];
    }
}
-(void)deleteOntolgyWordWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteOntolgyWordWithError:)])
    {
        [self.callBack deleteOntolgyWordWithError:error];
    }
}

-(void)updateOntolgyWordSuccess:(NSString *)strMessage
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(updateOntolgyWordSuccess:)])
    {
        [self.callBack updateOntolgyWordSuccess:strMessage];
    }
}
-(void)updateOntolgyWordWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(updateOntolgyWordWithError:)])
    {
        [self.callBack updateOntolgyWordWithError:error];
    }
}

//Search All Synonyms
-(void)searchSynonymsForWord:(NSString*)wordStr
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL searchSynonymsForWord:wordStr];
        buzztangWL = nil;
    }
    else
    {
        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(searchSynonymsForWordError:)])
        {
            [self.callBack searchSynonymsForWordError:NoInternateConnextionMsg];
        }
    }
}

-(void)searchSynonymsForWordSuccess:(id)successData
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(searchSynonymsForWordSuccess:)])
    {
        [self.callBack searchSynonymsForWordSuccess:successData];
    }
}

-(void)searchSynonymsForWordError:(NSString*)errorMsg
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(searchSynonymsForWordError:)])
    {
        [self.callBack searchSynonymsForWordError:errorMsg];
    }
}

//Add New Synonyms for a Ontology Word
-(void)addNewSynonyms:(NSString *)synonymsStr ForWord:(NSString *)wordID
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL addNewSynonyms:synonymsStr ForWord:wordID];
        buzztangWL = nil;
    }
    else
    {
        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(addSynonymError:)])
        {
            [self.callBack addSynonymError:NoInternateConnextionMsg];
        }
    }
}

-(void)addSynonymSuccess:(NSArray *)newlyAddedSynonyms
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(addSynonymSuccess:)])
    {
        [self.callBack addSynonymSuccess:newlyAddedSynonyms];
    }
}

-(void)addSynonymError:(NSString*)errorMsg
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(addSynonymError:)])
    {
        [self.callBack addSynonymError:errorMsg];
    }
}



//Update a synonym for a Ontology Word
-(void)updateSynonym:(NSString *)toBeUpdatedSynonymStr withID:(NSString *)synonymID
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL updateSynonym:toBeUpdatedSynonymStr withID:synonymID];
        buzztangWL = nil;
    }
    else
    {
        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(updateSynonymError:)])
        {
            [self.callBack updateSynonymError:NoInternateConnextionMsg];
        }
    }
}
-(void)updateSynonymSuccess:(NSString*)successMsg
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(updateSynonymSuccess:)])
    {
        [self.callBack updateSynonymSuccess:successMsg];
    }
}
-(void)updateSynonymError:(NSString*)errorMsg
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(updateSynonymError:)])
    {
        [self.callBack updateSynonymError:errorMsg];
    }
}

//Delete a synonym for a Ontology Word
-(void)deleteSynonymWithID:(NSString *)synonymID
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL deleteSynonymWithID:synonymID];
        buzztangWL = nil;
    }
    else
    {
        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteSynonymError:)])
        {
            [self.callBack deleteSynonymError:NoInternateConnextionMsg];
        }
    }
}
-(void)deleteSynonymSuccess:(NSString*)successMsg
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteSynonymSuccess:)])
    {
        [self.callBack deleteSynonymSuccess:successMsg];
    }
}
-(void)deleteSynonymError:(NSString*)errorMsg
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteSynonymError:)])
    {
        [self.callBack deleteSynonymError:errorMsg];
    }
}

//CreateContact
-(void)createContactWithNetworkID:(NSString *)networkID FirstName:(NSString *)fName lastName:(NSString *)lName emailAddress:(NSString *)emailID companyURL:(NSString *)companyUrl stockSymbol:(NSString *)stockSymbol outlookAddress:(NSString *)outlookID facebookURLs:(NSArray *)facebookURLs twitterIDs:(NSArray *)twitterIDs linkedInURls:(NSArray *)linkedInURLs RSSFeedNames:(NSArray *)rssFeedNames RSSFeedURLs:(NSArray *)rssFeedUrls;
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL createContactWithNetworkID:networkID FirstName:fName lastName:lName emailAddress:emailID companyURL:companyUrl stockSymbol:stockSymbol outlookAddress:outlookID facebookURLs:facebookURLs twitterIDs:twitterIDs linkedInURls:linkedInURLs RSSFeedNames:rssFeedNames RSSFeedURLs:rssFeedUrls];
        buzztangWL = nil;
    }
    else
    {
        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createContactWithError:)])
        {
            [self.callBack createContactWithError:NoInternateConnextionMsg];
        }
    }
}

-(void)createContactSuccess:(NSArray *)successData
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createContactSuccess:)])
    {
        [self.callBack createContactSuccess:successData];
    }
}
-(void)createContactWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createContactWithError:)])
    {
        [self.callBack  createContactWithError:error];
    }
}
//UpdateContact
-(void)updateContactWithFirstName:(NSString *)fName lastName:(NSString *)lName emailAddress:(NSString *)emailID companyURL:(NSString *)companyUrl stockSymbol:(NSString *)stockSymbol outlookAddress:(NSString *)outlookID facebookURLs:(NSArray *)facebookURLs twitterIDs:(NSArray *)twitterIDs linkedInURls:(NSArray *)linkedInURLs RSSFeedNames:(NSArray *)rssFeedNames RSSFeedURLs:(NSArray *)rssFeedUrls andContactID:(NSString *)contactID
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL updateContactWithFirstName:fName lastName:lName emailAddress:emailID companyURL:companyUrl stockSymbol:stockSymbol outlookAddress:outlookID facebookURLs:facebookURLs twitterIDs:twitterIDs linkedInURls:linkedInURLs RSSFeedNames:rssFeedNames RSSFeedURLs:rssFeedUrls andContactID:contactID];
        buzztangWL = nil;
    }
    else
    {
        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(updateContactWithError:)])
        {
            [self.callBack updateContactWithError:NoInternateConnextionMsg];
        }
    }
}
-(void)updateContactSuccess:(NSArray *)successData
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(updateContactSuccess:)])
    {
        [self.callBack updateContactSuccess:successData];
    }
}
-(void)updateContactWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(updateContactWithError:)])
    {
        [self.callBack updateContactWithError:error];
    }
}
//DeleteContact
-(void)deleteContactWithContactID:(NSString *)contactID
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL deleteContactWithContactID:contactID];
        buzztangWL = nil;
    }
    else
    {
        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteContactWithError:)])
        {
            [self.callBack deleteContactWithError:NoInternateConnextionMsg];
        }
    }
}
-(void)deleteContactSuccess:(NSString *)strMessage withDeletedContactID:(NSString *)contactID
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteContactSuccess:withDeletedContactID:)])
    {
        [self.callBack deleteContactSuccess:strMessage withDeletedContactID:contactID];
    }
}
-(void)deleteContactWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteContactWithError:)])
    {
        [self.callBack deleteContactWithError:error];
    }
}

//Search All Synonyms #34
-(void)searchAllSynonymsForWord:(NSString*)wordStr
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL searchAllSynonymsForWord:wordStr];
        buzztangWL = nil;
    }
    else
    {
        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(searchAllSynonymsForWordError:)])
        {
            [self.callBack searchAllSynonymsForWordError:NoInternateConnextionMsg];
        }
    }
}
-(void)searchAllSynonymsForWordSuccess:(id)successObject
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(searchAllSynonymsForWordSuccess:)])
    {
        [self.callBack searchAllSynonymsForWordSuccess:successObject];
    }
}
-(void)searchAllSynonymsForWordError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(searchAllSynonymsForWordError:)])
    {
        [self.callBack searchAllSynonymsForWordError:error];
    }
}

//All Network Filters
-(void)getAllNetworkFilters
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL getAllNetworkFilters];
        buzztangWL = nil;
    }
    else
    {
        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteContactWithError:)])
        {
            [self.callBack getAllNetworkFiltersWithError:NoInternateConnextionMsg];
        }
    }
}
-(void)getAllNetworkFiltersSuccess:(NSArray *)array
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getAllNetworkFiltersSuccess:)])
    {
        [self.callBack getAllNetworkFiltersSuccess:array];
    }
}
-(void)getAllNetworkFiltersWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getAllNetworkFiltersWithError:)])
    {
        [self.callBack getAllNetworkFiltersWithError:error];
    }
}
//Create Network Filters
-(void)createNewNetworkFilterWithMasterId:(NSString *)masterIdentifier Synonyms:(NSArray *)synonymsIDArr andNetworkID:(NSArray *)networkIDArr
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL createNewNetworkFilterWithMasterId:masterIdentifier Synonyms:synonymsIDArr andNetworkID:networkIDArr];
        buzztangWL = nil;
    }
    else
    {
        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createNetworkFilterWithError:)])
        {
            [self.callBack createNetworkFilterWithError:NoInternateConnextionMsg];
        }
    }
}
-(void)createNetworkFilterSuccess:(NSString *)strMessage
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createNetworkFilterSuccess:)])
    {
        [self.callBack createNetworkFilterSuccess:strMessage];
    }
}
-(void)createNetworkFilterWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(createNetworkFilterWithError:)])
    {
        [self.callBack createNetworkFilterWithError:error];
    }
}
//Update Network Filters
-(void)updateNetworkFilterWithMasterId:(NSString *)masterIdentifier Synonyms:(NSArray *)synonymsIDArr andNetworkFilterId:(NSString *)filterID
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL updateNetworkFilterWithMasterId:masterIdentifier Synonyms:synonymsIDArr andNetworkFilterId:filterID];
        buzztangWL = nil;
    }
    else
    {
        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(updateNetworkFilterWithError:)])
        {
            [self.callBack updateNetworkFilterWithError:NoInternateConnextionMsg];
        }
    }
}
-(void)updateNetworkFilterSuccess:(NSString *)strMessage
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(updateNetworkFilterSuccess:)])
    {
        [self.callBack updateNetworkFilterSuccess:strMessage];
    }
}
-(void)updateNetworkFilterWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(updateNetworkFilterWithError:)])
    {
        [self.callBack updateNetworkFilterWithError:error];
    }
}
//Delete Network Filters
-(void)deleteNetworkFilterWithNetworkFilterId:(NSString *)filterID andOptionalWordId:(NSString *)wordID
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL deleteNetworkFilterWithNetworkFilterId:filterID andOptionalWordId:wordID];
        buzztangWL = nil;
    }
    else
    {
        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteContactWithError:)])
        {
            [self.callBack deleteOntolgyWordWithError:NoInternateConnextionMsg];
        }
    }
}
-(void)deleteNetworkFilterSuccess:(NSString *)strMessage
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteNetworkFilterSuccess:)])
    {
        [self.callBack deleteNetworkFilterSuccess:strMessage];
    }
}
-(void)deleteNetworkFilterWithError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(deleteNetworkFilterWithError:)])
    {
        [self.callBack deleteNetworkFilterWithError:error];
    }
}

//Service#50
-(void)getNetworkFilterNames
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL getNetworkFilterNames];
        buzztangWL = nil;
    }
    else
    {
        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getNetworkFilterNamesError:)])
        {
            [self.callBack getNetworkFilterNamesError:NoInternateConnextionMsg];
        }
    }
}

-(void)getNetworkFilterNamesSuccess:(id)successData
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getNetworkFilterNamesSuccess:)])
    {
        [self.callBack getNetworkFilterNamesSuccess:successData];
    }
}
-(void)getNetworkFilterNamesError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getNetworkFilterNamesError:)])
    {
        [self.callBack getNetworkFilterNamesError:error];
    }
}

-(void)editNetworkFilterWithIdentifier:(NSString *)networkIdentifier
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL editNetworkFilterWithIdentifier:networkIdentifier];
        buzztangWL = nil;
    }
    else
    {
        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(editNetworkFilterError:)])
        {
            [self.callBack editNetworkFilterError:NoInternateConnextionMsg];
        }
    }
}


-(void)editNetworkFilterSuccess:(id)successData
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(editNetworkFilterSuccess:)])
    {
        [self.callBack editNetworkFilterSuccess:successData];
    }
}
-(void)editNetworkFilterError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(editNetworkFilterError:)])
    {
        [self.callBack editNetworkFilterError:error];
    }
}

-(void)getAllBuzzboardContactsForNetworkID:(NSString *)networkID
{
    if(APPDELEGATE.isServerReachable)
    {
        BuzztangWL *buzztangWL = [[BuzztangWL alloc] init];
        buzztangWL.callBack = self;
        [buzztangWL getAllBuzzboardContactsForNetworkID:networkID];
        buzztangWL = nil;
    }
    else
    {
        if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getBuzzContactsError:)])
        {
            [self.callBack getBuzzContactsError:NoInternateConnextionMsg];
        }
    }
}

-(void)getBuzzContactsSuccess:(NSArray *)successData
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getBuzzContactsSuccess:)])
    {
        [self.callBack getBuzzContactsSuccess:successData];
    }
}

-(void)getBuzzContactsError:(NSString *)error
{
    if(self.callBack != nil && [self.callBack respondsToSelector:@selector(getBuzzContactsError:)])
    {
        [self.callBack getBuzzContactsError:error];
    }
}


@end
