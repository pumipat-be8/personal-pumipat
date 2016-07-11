/**
* @author noppawit.h@beryl8.com
* @28/09/2015 created new
*/
trigger ContactTrigger on Contact (before insert, before update, after update){
	new ContactTriggerHandler().run();
}