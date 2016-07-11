/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   A global utility Test

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
05/28/2015	Charnun.T 			First Create
------------------------------------------------------------*/
@isTest
private class GlobalUtility_Test {

	static testMethod void setApplicationLogWrapper(){
		ApplicationLogWrapper msg = new ApplicationLogWrapper();
		msg.source = 'source';
        msg.logMessage = 'logMessage';
        msg.sourceFunction = 'sourceFunction';
        msg.referenceId = 'referenceId';
        msg.referenceInfo = 'referenceInfo';
        msg.payload = 'payLoad';
        msg.debugLevel = GlobalConstants.DEBUG_LOG;
        msg.logCode = 'logCode';
        msg.timer = Long.valueOf('1234567');
        msg.ex = null;
	}

        static testMethod void toDateFormat(){
                Date todayDate = System.today();
                String newDate = GlobalUtility.toDateFormat('2558', '2', '16');
                System.assertEquals('16/02/2015', newDate);
        }

        static testMethod void toCurrency(){
                String stringCurrency = GlobalUtility.toCurrency('1900000');
                System.assertEquals('1,900,000.00', stringCurrency);
        }

        static testMethod void dropLeadingZero(){
                String zeroLead = '000099';
                System.assertEquals('99', GlobalUtility.dropLeadingZero(zeroLead));
        }

        static testMethod void isEmailValid(){
                String validEmail = 'ttt11@comdfdf.com';
                String invalidEmail = 'ttt121424@dfsfgsgsg';

                System.assertEquals(true, GlobalUtility.isEmailValid(validEmail));
                System.assertEquals(false, GlobalUtility.isEmailValid(invalidEmail));
        }
}