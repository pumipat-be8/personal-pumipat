trigger UserExtensionTrigger on User_Extension__c (before update, after update) {
    new UserExtensionTriggerHandler().run();
}