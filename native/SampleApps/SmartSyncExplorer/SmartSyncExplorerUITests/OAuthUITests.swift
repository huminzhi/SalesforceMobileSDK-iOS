/*
OAuthUITests.swift
OAuthUITests

Copyright (c) 2016, salesforce.com, inc. All rights reserved.

Redistribution and use of this software in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright notice, this list of conditions
and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of
conditions and the following disclaimer in the documentation and/or other materials provided
with the distribution.
* Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
endorse or promote products derived from this software without specific prior written
permission of salesforce.com, inc.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


import XCTest
@testable import SalesforceSDKCore

class OAuthUITest: SalesforceNoSessionTestCase {
    
    let loginHelper = LoginHelper()
    let loginPage = LoginPage()
    let hostPage = HostPage()
    let searchScreen = SearchScreen()
    let userListScreen = UserListScreen()
    
    // MARK: Setup
    override func setUp() {
        super.setUp()
        loginPage.waitForPageLoaded()
    }
    
    override func tearDown() {
        loginPage.waitForPageLoaded()
        super.tearDown()
    }
    
    // MARK: Tests
    func testLoginSwitchBetweenAndLogoutUsers() {
        loginPage.scrollUp() //sanity test scrolling is enabled
        for login in loginAccounts {
            let user = login.valueForKey("username") as! String
            let password = login.valueForKey("password") as! String
            let host = login.valueForKey("host") as! String
            addAndSwitchToUser(user, password:password, host:host, passcode:passcode)
            sleep(1)
        }
        
        let total = loginAccounts.count
        for i in 0..<total {
            let user = loginAccounts[i].valueForKey("username") as! String
            switchToUser(user, onUserList: false)
        }
        
        searchScreen.switchUser()        
        for j in 0..<total-1 {
            let user = loginAccounts[j].valueForKey("username") as! String
            switchToUser(user, onUserList: true)
            searchScreen.logout()
        }
        searchScreen.logout()
        loginPage.waitForPageLoaded()
    }
    
    func testLogoutRelogin() {
        let user = loginAccounts[0].valueForKey("username") as! String
        let password = loginAccounts[0].valueForKey("password") as! String
        loginHelper.loginToSalesforce(user, password: password, host: Host.sandbox)
        searchScreen.waitForPageLoaded()
        searchScreen.logout()
        loginHelper.loginToSalesforce(user, password: password)
        searchScreen.waitForPageLoaded()
        searchScreen.logout()
    }
    
    func TODOtestRevokeRefreshToken(){
        //login up to 3 users
        var i = 0
        for login in loginAccounts {
            if (i>2) {
              break
            }
            let user = login.valueForKey("username") as! String
            let password = login.valueForKey("password") as! String
            let host = login.valueForKey("host") as! String
            addAndSwitchToUser(user, password:password, host:host, passcode: passcode)
            i = i + 1
            sleep(1)
        }
        
        SFAuthenticationManager.sharedManager().logoutAllUsers() //FIXME: for some reason, this doesn's work
        sleep(5) //give server sometime to revoke the token
        
        searchScreen.sync()
        loginPage.waitForPageLoaded()
        XCTAssert(!searchScreen.isPresenting(), "Should not stay on search screen")
    }
    
    func switchToUser(username:String, onUserList:Bool) {
        if (!onUserList) {
            searchScreen.switchUser()
        }
        userListScreen.switchToUser(username)
        searchScreen.waitForPageLoaded()
    }
    
    func addAndSwitchToUser(username:String, password:String, host:String, passcode:String) {
        if (!loginPage.isPresenting()) {
            searchScreen.waitForPageLoaded()
            searchScreen.switchUser()
            userListScreen.addUser()
        }
        loginHelper.loginToSalesforce(username, password: password, url:host, withPasscode: passcode)
    }
    
    
}