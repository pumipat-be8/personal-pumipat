/**
 * @author chutiwat.s@beryl8.com
 * @5/09/2015 created date
 * @28/01/2016 komsan.wi add group recursive
 */
public with sharing class UserRoleUtils {
    
    public List<User> userList {get;set;}
    private static UserRoleUtils instance = null;

    public static UserRoleUtils getInstance(){
        if(instance == null){ 
            instance = new UserRoleUtils();

            User currentUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

            instance.userList = new List<User>{currentUser};
            instance.userList.addAll(UserRoleUtils.getAllSubRoleUsers(instance.userList));

        }
        return instance;
    }

    public static List<User> getAllSubRoleUsers(List<User> users) {
        Set<ID> currentRoleIds = new Set<ID>();
        for (User user : users) {
            currentRoleIds.add(user.UserRoleId);
        }

        List<User> currentUsers = new List<User>();

        // get all of the roles underneath the passed roles
        for(User eachUser :[SELECT Id, Name, UserRoleId, UserRole.ParentRoleId FROM User 
            WHERE UserRole.ParentRoleId IN :currentRoleIds AND UserRole.ParentRoleId != null]) {
            currentUsers.add(eachUser);
        }

        // go fetch some more rolls!
        if(currentUsers.size() > 0) {
            currentUsers.addAll(getAllSubRoleUsers(currentUsers));
        }

        return currentUsers;
    }
     public static Set<id> GetUserIdsFromGroup(Set<Id> userOrGroupIds)
    {
        // store the results in a set so we don't get duplicates
        Set<Id> result=new Set<Id>();
        String userType = Schema.SObjectType.User.getKeyPrefix();
        String groupType = Schema.SObjectType.Group.getKeyPrefix();
        Set<Id> groupIdProxys = new Set<Id>();
        for(Id m : userOrGroupIds)
        {
            // If the user or group id is a user
            if(((String)m).startsWith(userType))
            {
                result.add(m);
            }
            // If the user or group id is a group
            // Note: there may be a problem with governor limits if this is called too many times
            else if (((String)m).startsWith(groupType))
            {
                // Call this function again but pass in the group found within this group
                groupIdProxys.add(m);
                
            }
        }
        if(groupIdProxys.size() > 0)
        {    
            Set<id> groupId = new set<id>();
            Set<id> roleId = new set<id>();
            Set<id> roleAndSubId = new set<Id>();
            Set<id> subGroupId = new set<Id>();

            for(Group g2 : [Select Id, Type, relatedId From Group Where Id = :groupIdProxys]){
                if(g2.Type == 'Role'){
                    roleId.add(g2.relatedId);    
                }
                else if(g2.Type== 'RoleAndSubordinates'){
                    roleAndSubId.add(g2.relatedId);    
                }
                else if(g2.Type== 'PRMOrganization'){
                    roleId.add(g2.relatedId);    
                }
                else if(g2.Type== 'Regular'){
                    groupId.add(g2.id);    
                }
            }
            if(roleAndSubId.size()>0){
                roleId.addAll(getAllSubRoleIds(roleAndSubId));
            }
            if(roleId.size()>0){
                for(User u: [select id from user where UserRoleId IN: roleId]){
                    result.add(u.id);
                }
            }
            if(groupId.size()>0){
                result.addAll(getAllGroupIds(groupId));
            }
        }
        return result;  
    }
    public static Set<ID> getAllGroupIds(Set<ID> groupId) {
        String groupType = Schema.SObjectType.Group.getKeyPrefix();
        Set<ID> userIds = new Set<ID>();
        Set<id> groupIds = new set<Id>();
        for(GroupMember gm : [select id, UserOrGroupId from GroupMember where GroupId IN: groupId]){
            if(((String)gm.UserOrGroupId).startsWith(groupType)) groupIds.add(gm.UserOrGroupId);
            else userIds.add(gm.UserOrGroupId);
        }

        if(groupIds.size() > 0)
            userIds.addAll(getAllGroupIds(groupIds));
        return userIds;
    }
    public static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
    
        Set<ID> currentRoleIds = new Set<ID>();
    
        // get all of the roles underneath the passed roles
        for(UserRole userRole :[select Id from UserRole where ParentRoleId IN :roleIds AND ParentRoleID != null limit 40000])
            currentRoleIds.add(userRole.Id);
    
        // go fetch some more rolls!
        if(currentRoleIds.size() > 0)
          currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
    
        return currentRoleIds;
    
    }
}