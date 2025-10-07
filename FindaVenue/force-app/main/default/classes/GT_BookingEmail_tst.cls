/*
 * Created by Glic-Tech Ltd on 04/07/2021.
 *
 * Description: Test class for GT_BookingEmail.
 *
 * Last modified by Finbar in Glic-Tech on 04/07/2021.
*/
@isTest
class GT_BookingEmail_tst {
    /*
    * Description: sets up test data for the class.
    *
    * Last modified by Finbar in Glic-Tech on 04-07-2021.
    */
    @TestSetup
    static void testData(){
        Lead l = new Lead(
            firstName = 'Finbar', 
            lastname = 'Tracey', 
            Status = 'New',
            Email = 'sfadmin@glic-tech.com'
        );
        insert l;
        
        Venue__c v1 = new Venue__c(
            Name = 'Hotel Kilmore', 
            Email__c = 'Finbar.Tracey@glic-tech.com'
        );
        insert v1;

        Event_Venues__c ev1 = new Event_Venues__c(
            Lead__c = l.Id, 
            Venue__c = v1.Id
        );
        insert ev1;
    }

    /*
    * Description: Tests the autoRun Method.
    *
    * Last modified by Finbar in Glic-Tech on 04-07-2021.
    */
    @IsTest
    static void testAutoRun(){
        Lead l = [ select Id from Lead limit 1 ]; 

        Apexpages.StandardController ssc = new Apexpages.StandardController(l);

        Pagereference ref = new Pagereference('/' + l.Id);
        String expected = ref.getUrl();

        Test.startTest();

        GT_BookingEmail ext = new GT_BookingEmail(ssc);
        Pagereference res = ext.autoRun();

        Test.stopTest();

        String actual = res.getUrl();

        System.assertEquals(expected, actual); 
    }

    /*
    * Description: Tests the autoRun2 Method.
    *
    * Last modified by Finbar in Glic-Tech on 04-07-2021.
    */
    @IsTest
    static void testAutoRun2(){
        Lead l = [ select Id from Lead limit 1 ]; 

        Apexpages.StandardController ssc = new Apexpages.StandardController(l);

        Pagereference ref = new Pagereference('/' + l.Id);
        String expected = ref.getUrl();

        Test.startTest();

        GT_BookingEmail ext = new GT_BookingEmail(ssc);
        Pagereference res = ext.autoRun2();

        Test.stopTest();

        String actual = res.getUrl();

        System.assertEquals(expected, actual); 
    }

    /*
    * Description: Test class for CreateErrors method.
    *
    * Last modified by Finbar in Glic-Tech on 04-07-2021.
    */
    @isTest
    static void testCreateErrors(){
        Lead l = [ select Id from Lead ];

        string result = '{"success":false,"errors":[{"message":"Failure"}]}';

        Messaging.SendEmailResult res1 = (Messaging.SendEmailResult) JSON.deserialize(result, Messaging.SendEmailResult.class);
        
        Test.startTest();

        List<Error_Log__c> errors = GT_BookingEmail.CreateErrors(res1);

        Test.stopTest();

        Boolean expected = false, actual = errors.isEmpty();

        System.assertEquals(expected, actual);
    }
}