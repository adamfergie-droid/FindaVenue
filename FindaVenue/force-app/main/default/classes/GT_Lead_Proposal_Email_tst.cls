/*
 * Created by Glic-Tech Ltd on 23/06/2021.
 *
 * Description: Test class for GT_Lead_Proposal_Email.
 *
 * Last modified by Finbar in Glic-Tech on 01/07/2021.
*/
@isTest
public class GT_Lead_Proposal_Email_tst {
    /*
    * Description: creating email template.
    *
    * Last modified by Finbar in Glic-Tech on 01/07/2021.
    */
    @TestSetup
    static void makeData(){
        EmailTemplate et = new EmailTemplate();
		et.isActive = true;
		et.Name = 'name';
		et.DeveloperName = 'Send_proposals_HTML';
		et.TemplateType = 'text';
		et.FolderId = UserInfo.getUserId();
		et.Subject = 'Your Subject Here';
        insert et;

        testData();
    }

    /*
    * Description: Test data for class.
    *
    * Last modified by Finbar in Glic-Tech on 24/06/2021.
    */
    @testvisible
    @future
    static void testData(){
        Lead l = new Lead(firstName = 'Finbar', lastname = 'Tracey', Status='New', email = 'finbar.tracey@glic-tech.com');
        insert l;

        Venue__c v1 = new Venue__c(Name = 'Hotel Kilmore', Email__c = 'Finbar.Tracey@glic-tech.com');
        insert v1;

        Venue__c v2 = new Venue__c(Name = 'Cavan Crystal', Email__c = 'sfadmin@glic-tech.com');
        insert v2;

        Event_Venues__c ev1 = new Event_Venues__c(Lead__c = l.id, Venue__c = v1.Id);
        insert ev1;
        Event_Venues__c ev2 = new Event_Venues__c(Lead__c = l.id, Venue__c = v2.Id);
        insert ev2;
    }

    /*
    * Description: Test Method for getVenues method.
    *
    * Last modified by Finbar in Glic-Tech on 23/06/2021.
    */
    @IsTest
    static void testGetVenues(){
        Lead l = [ SELECT Id FROM lead LIMIT 1 ];

        Test.startTest();
        GT_Lead_Proposal_Email.getVenues(l.id);
        Test.stopTest();
        
    }

    /*
    * Description: Test Method for emailVenues method.
    *
    * Last modified by Finbar in Glic-Tech on 24/06/2021.
    */
    @IsTest
    static void testemailVenues(){
        lead l = [select id from lead];
        list<Event_Venues__c> venues = [select id from Event_Venues__c];
        list<string> z = new list<string>();

        for (Event_Venues__c v : venues) {z.add(v.Id);}
        string y = JSON.serialize(z);
        
        Test.startTest();
        GT_Lead_Proposal_Email.emailVenues(l.id, y);
        Test.stopTest();
    }

    /*
    * Description: Test Method for GetEmailTemplate method.
    *
    * Last modified by Finbar in Glic-Tech on 24/06/2021.
    */
    @IsTest
    static void testGetEmailTemplate(){
        EmailTemplate et = [ select Id, DeveloperName from EmailTemplate limit 1 ];

        Test.startTest();
        GT_Lead_Proposal_Email.GetEmailTemplate(et.DeveloperName);
        Test.stopTest();
    }

    /*
    * Description: Test class for CreateErrors method.
    *
    * Last modified by Finbar in Glic-Tech on 24/06/20221.
    */
    @isTest
    static void testCreateErrors(){
        Lead l = [ select Id from Lead ];

        string result = '{"success":false,"errors":[{"message":"Failure"}]}';

        Messaging.SendEmailResult res1 = (Messaging.SendEmailResult) JSON.deserialize(result, Messaging.SendEmailResult.class);

        //Messaging.SendEmailError er = new Messaging.SendEmailError();
        //System.StatusCode.EMAIL_ADDRESS_BOUNCED "statuscode":"EMAIL_ADDRESS_BOUNCED", ,"targetobjectid":"' + l.Id + '"
        
        Test.startTest();

        List<Error_Log__c> errors = GT_Lead_Proposal_Email.CreateErrors(res1);

        Test.stopTest();

        Boolean expected = false, actual = errors.isEmpty();

        System.assertEquals(expected, actual);
    }
}