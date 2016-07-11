public class CampaignRewardCalculation {
    /*
     * Created by: chumphon.k@kbtg.tech
     * Created date: 20-Mar-2016
     * Description: CR-006 Auto assign targer list and calculate campaign reward
     */
    private Decimal privateResultNewbooking;
    private Decimal privateResultThankyou;
    public Decimal resultNewBooking{
        get { return privateResultNewbooking; }
    }
    public Decimal resultThankyou{
        get { return privateResultThankyou; }
    }

    public CampaignRewardCalculation() {
        privateResultNewbooking = 0;
        privateResultThankyou = 0;
    }

    public string CalculateNewBooking(Decimal SetupAmount, Decimal FrontEndFee, String Option){
        Decimal percentFrontEndFee = 0;
        Decimal multiplier = 0;
        Decimal minAmount = 1000000;
        Decimal maxReward = 30000;
        Decimal x = 0;
        Decimal decResult = 0;
        String strResult = '-';

        if(SetupAmount >= minAmount){
            percentFrontEndFee = (FrontEndFee * 100) / SetupAmount;
            if(percentFrontEndFee >= 1){

                if(percentFrontEndFee < 2){
                    multiplier = (Option == 'B') ? 1500 : 1000;
                } else if(percentFrontEndFee < 3){
                    multiplier = (Option == 'B') ? 2500 : 2000;
                } else{
                    multiplier = (Option == 'B') ? 3500 : 3000;
                }
                x = (SetupAmount/minAmount);
                decResult = x.round(System.RoundingMode.DOWN) * multiplier;
                if(decResult > maxReward) decResult = maxReward;
                privateResultNewbooking = decResult;

                List<String> args = new String[]{'0','number','###,###,##0.00'};
                strResult = String.format(decResult.format(), args) + ' บาท';
            }
        }
        if(strResult == '-') strResult = 'ลูกค้าไม่ได้รับของรางวัล';
        return strResult;
    }

    public string CalculateThankyou(Decimal FrontEndFee, Decimal BA_Prosaving, Decimal BA_Protection){
        Decimal calcAmount;
        Decimal decResult = 0;
        String strResult = '-';

        //calcAmount = (BA_Prosaving < 600000) ? FrontEndFee+BA_Protection : FrontEndFee+BA_Prosaving+BA_Protection;
        calcAmount = FrontEndFee+BA_Protection;

        if(resultNewBooking > 0) {calcAmount = calcAmount/2;}
        if(calcAmount >= 200000){
            /*
            if(calcAmount < 300000){
                decResult = 1000;
                strResult = 'Lotus 1,000';
            } else 
            */
            if(calcAmount < 500000){
                decResult = 3000;
                strResult = 'Central 3,000';
            } else if(calcAmount < 1000000){
                decResult = 5000;
                strResult = 'PTT 5,000';
            } else if(calcAmount < 1500000){
                decResult = 10000;
                strResult = 'Central 5,000 + PTT 5,000';
            } else if(calcAmount < 2000000){
                decResult = 15000;
                strResult = 'Central 10,000 + PTT 5,000';
            } else if(calcAmount < 3000000){
                decResult = 20000;
                strResult = 'Central 10,000 + PTT 10,000';
            } else if(calcAmount < 4000000){
                decResult = 30000;
                strResult = 'Centara 10,000 + Central 10,000 + PTT 10,000';
            } else if(calcAmount < 5000000){
                decResult = 40000;
                strResult = 'Centara 10,000 + Central 15,000 + PTT 15,000';
            } else{
                decResult = 50000;
                strResult = 'Centara 15,000 + Central 15,000 + PTT 20,000';
            }
            privateResultThankyou = decResult;
        }
        if(strResult == '-') strResult = 'ลูกค้าไม่ได้รับของรางวัล';
        return strResult;
    }
}