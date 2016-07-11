/*
 * Created by: chumphon.k@kbtg.tech
 * Created date: 21-Mar-2016
 * Description: CR-006 Auto assign targer list and calculate campaign reward
*/
@isTest
private class CampaignRewardCalculation_Test {
    @isTest static void CalculateNewbooking_1A(){
        String Result;
        CampaignRewardCalculation calc = new CampaignRewardCalculation();
        Test.startTest();
            Result = calc.CalculateNewBooking(2000000, 15000, 'A');
        Test.stopTest();
        System.assertEquals(calc.resultNewBooking, 0);
    }
    @isTest static void CalculateNewbooking_1B(){
        String Result;
        CampaignRewardCalculation calc = new CampaignRewardCalculation();
        Test.startTest();
            Result = calc.CalculateNewBooking(2000000, 15000, 'B');
        Test.stopTest();
        System.assertEquals(calc.resultNewBooking, 0);
    }
    
    @isTest static void CalculateNewbooking_2A(){
        String Result;
        CampaignRewardCalculation calc = new CampaignRewardCalculation();        
        Test.startTest();
            Result = calc.CalculateNewBooking(2000000, 20000, 'A');
        Test.stopTest();
        System.assertEquals(calc.resultNewBooking, 2000);
    }
    @isTest static void CalculateNewbooking_2B(){
        String Result;
        CampaignRewardCalculation calc = new CampaignRewardCalculation();        
        Test.startTest();
            Result = calc.CalculateNewBooking(2000000, 20000, 'B');
        Test.stopTest();
        System.assertEquals(calc.resultNewBooking, 3000);
    }
    
    @isTest static void CalculateNewbooking_3A(){
        String Result;
        CampaignRewardCalculation calc = new CampaignRewardCalculation();        
        Test.startTest();
            Result = calc.CalculateNewBooking(2000000, 40000, 'A');
        Test.stopTest();
        System.assertEquals(calc.resultNewBooking, 4000);
    }
    @isTest static void CalculateNewbooking_3B(){
        String Result;
        CampaignRewardCalculation calc = new CampaignRewardCalculation();        
        Test.startTest();
            Result = calc.CalculateNewBooking(2000000, 40000, 'B');
        Test.stopTest();
        System.assertEquals(calc.resultNewBooking, 5000);
    }
    
    @isTest static void CalculateNewbooking_4A(){
        String Result;
        CampaignRewardCalculation calc = new CampaignRewardCalculation();        
        Test.startTest();
            Result = calc.CalculateNewBooking(2000000, 60000, 'A');
        Test.stopTest();
        System.assertEquals(calc.resultNewBooking, 6000);
    }
    @isTest static void CalculateNewbooking_4B(){
        String Result;
        CampaignRewardCalculation calc = new CampaignRewardCalculation();        
        Test.startTest();
            Result = calc.CalculateNewBooking(2000000, 60000, 'B');
        Test.stopTest();
        System.assertEquals(calc.resultNewBooking, 7000);
    }
    
    @isTest static void CalculateNewbooking_5A(){
        String Result;
        CampaignRewardCalculation calc = new CampaignRewardCalculation();        
        Test.startTest();
            Result = calc.CalculateNewBooking(25000000, 500000, 'A');
        Test.stopTest();
        System.assertEquals(calc.resultNewBooking, 30000);
    }
    @isTest static void CalculateNewbooking_5B(){
        String Result;
        CampaignRewardCalculation calc = new CampaignRewardCalculation();        
        Test.startTest();
            Result = calc.CalculateNewBooking(25000000, 500000, 'B');
        Test.stopTest();
        System.assertEquals(calc.resultNewBooking, 30000);
    }
    
    @isTest static void CalculateThankyou_1(){
        String Result;
        CampaignRewardCalculation calc = new CampaignRewardCalculation();        
        Test.startTest();
            Result = calc.CalculateThankyou(50000,0,0);
        Test.stopTest();
        System.assertEquals(calc.resultThankyou, 0);
    }
    
    @isTest static void CalculateThankyou_2(){
        String Result;
        CampaignRewardCalculation calc = new CampaignRewardCalculation();        
        Test.startTest();
            Result = calc.CalculateThankyou(50000,100000,50000);
        Test.stopTest();
        System.assertEquals(calc.resultThankyou, 0);
    }
    
    @isTest static void CalculateThankyou_3(){
        String Result;
        CampaignRewardCalculation calc = new CampaignRewardCalculation();        
        Test.startTest();
            Result = calc.CalculateThankyou(100000,100000,100000);
        Test.stopTest();
        System.assertEquals(calc.resultThankyou, 3000);
    }
    
    @isTest static void CalculateThankyou_4(){
        String Result;
        CampaignRewardCalculation calc = new CampaignRewardCalculation();        
        Test.startTest();
            Result = calc.CalculateThankyou(300000,100000,200000);
        Test.stopTest();
        System.assertEquals(calc.resultThankyou, 5000);
    }
    
    @isTest static void CalculateThankyou_5(){
        String Result;
        CampaignRewardCalculation calc = new CampaignRewardCalculation();        
        Test.startTest();
            Result = calc.CalculateThankyou(500000,100000,500000);
        Test.stopTest();
        System.assertEquals(calc.resultThankyou, 10000);
    }
    
    @isTest static void CalculateThankyou_6(){
        String Result;
        CampaignRewardCalculation calc = new CampaignRewardCalculation();        
        Test.startTest();
            Result = calc.CalculateThankyou(1000000,100000,500000);
        Test.stopTest();
        System.assertEquals(calc.resultThankyou, 15000);
    }
    
    @isTest static void CalculateThankyou_7(){
        String Result;
        CampaignRewardCalculation calc = new CampaignRewardCalculation();        
        Test.startTest();
            Result = calc.CalculateThankyou(1000000,100000,1000000);
        Test.stopTest();
        System.assertEquals(calc.resultThankyou, 20000);
    }
    
    @isTest static void CalculateThankyou_8(){
        String Result;
        CampaignRewardCalculation calc = new CampaignRewardCalculation();        
        Test.startTest();
            Result = calc.CalculateThankyou(1500000,100000,1500000);
        Test.stopTest();
        System.assertEquals(calc.resultThankyou, 30000);
    }
    
    @isTest static void CalculateThankyou_9(){
        String Result;
        CampaignRewardCalculation calc = new CampaignRewardCalculation();        
        Test.startTest();
            Result = calc.CalculateThankyou(2000000,100000,2000000);
        Test.stopTest();
        System.assertEquals(calc.resultThankyou, 40000);
    }
    
    @isTest static void CalculateThankyou_10(){
        String Result;
        CampaignRewardCalculation calc = new CampaignRewardCalculation();        
        Test.startTest();
            Result = calc.CalculateThankyou(2500000,100000,2500000);
        Test.stopTest();
        System.assertEquals(calc.resultThankyou, 50000);
    }
}