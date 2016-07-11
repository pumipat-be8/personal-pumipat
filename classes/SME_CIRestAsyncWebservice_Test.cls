@isTest
private class SME_CIRestAsyncWebservice_Test
{
    @isTest
    static void testConvertProspectRequest(){
    	//Create fake response
    	Test.setMock(HttpCalloutMock.class, new MockSME_CIRestWebservice());

    	Account account = new Account();
    	account.Name = '123456789';
    	insert account;

    	List<sObject> convertList = new List<sObject>();
    	convertList.add(account);

        Test.startTest();
    	SME_CIRestAsyncWebservice.convertProspectRequest(convertList);
        Test.stopTest();
    }
}