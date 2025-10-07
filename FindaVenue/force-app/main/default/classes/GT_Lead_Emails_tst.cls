/*
 * Created by Glic-Tech Ltd on 23/06/2021.
 *
 * Description: Test class for GT_Lead_Emails.
 *
 * Last modified by Finbar in Glic-Tech on 29-06-2021.
*/
@isTest
class GT_Lead_Emails_tst {
    /*
    * Description: Tests up test data for the class.
    *
    * Last modified by Owen in Glic-Tech on 24-06-2021.
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
    * Last modified by Finbar in Glic-Tech on 29-06-2021.
    */
    @IsTest
    static void testAutoRun(){
        Lead l = [ select Id from Lead limit 1 ]; 

        Apexpages.StandardController ssc = new Apexpages.StandardController(l);

        Pagereference ref = new Pagereference('/' + l.Id);
        String expected = ref.getUrl();

        Test.startTest();

        GT_Lead_Emails ext = new GT_Lead_Emails(ssc);
        Pagereference res = ext.autoRun();

        Test.stopTest();

        List<Error_Log__c> errors = [ select Error_Message__c , Error_Trace__c from Error_Log__c ];

        for( Error_Log__c e : errors ){ System.debug(e);  }

        String actual = res.getUrl();

        System.assertEquals(expected, actual); 
    }

    /*
    * Description: Test class for CreateErrors method.
    *
    * Last modified by Finbar in Glic-Tech on 29-06-2021.
    */
    @isTest
    static void testCreateErrors(){
        Lead l = [ select Id from Lead ];

        string result = '{"success":false,"errors":[{"message":"Failure"}]}';

        Messaging.SendEmailResult res1 = (Messaging.SendEmailResult) JSON.deserialize(result, Messaging.SendEmailResult.class);
        
        Test.startTest();

        List<Error_Log__c> errors = GT_Lead_Emails.CreateErrors(res1);

        Test.stopTest();

        List<Error_Log__c> errors1 = [ select Error_Message__c , Error_Trace__c from Error_Log__c ];

        for( Error_Log__c e : errors1 ){ System.debug(e); }

        Boolean expected = false, actual = errors.isEmpty();

        System.assertEquals(expected, actual);
    }
}