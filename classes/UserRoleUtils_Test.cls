/**
* @author komsan.wi@beryl8.com
* @16/10/2015 createddate
*/
@isTest
private class UserRoleUtils_Test {
    @testSetup static void setupAccount(){
        Mockup_Test mt = new Mockup_Test().setUpTest();
    }
    @isTest static void getRoleUnder(){
    	User userAH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];
		System.runAs(userAH){
			UserRoleUtils userRole = UserRoleUtils.getInstance();
			System.assertEquals(3,userRole.userList.size());
			List<Group> groupList = [SELECT Id,RelatedId FROM Group WHERE DeveloperName=:Mockup_Test.ahRoleDeveloperName];
			Set<Id> groupSet = new Set<Id>();
			for(Group eachGroup : groupList){
				groupSet.add(eachGroup.Id);
			}
			Set<Id> resultSet = UserRoleUtils.GetUserIdsFromGroup(groupSet);
			System.assertNotEquals(0,resultSet.size());
		}
    }
}