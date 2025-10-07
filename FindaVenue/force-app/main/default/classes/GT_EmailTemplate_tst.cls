/*
 * Created by Glic-Tech Ltd on 07-07-2021.
 *
 * Description: Test class for GT_EmailTemplate_con.
 *
 * Last modified by Finbar in Glic-Tech on 13-07-2021.
*/
@IsTest
class GT_EmailTemplate_tst {
    /*
    * Description: Sets up test data for the class.
    *
    * Last modified by Owen in Glic-Tech on 07-07-2021.
    */
    @TestSetup
    static void makeData(){
        EmailTemplate et = new EmailTemplate(
            IsActive = true,
            Name = 'Email Template Dev 1',
            DeveloperName = 'EmailTemplateDev1',
            TemplateType = 'text',
            FolderId = UserInfo.getUserId(),
            Subject = 'Available Venues'
        );
        insert et;
        
        makeData2();
    }

    /*
    * Description: Sets test data up for the class.
    *
    * Last modified by Owen in Glic-Tech on 07-07-2021.
    */
    @Future
    static void makeData2(){
        Lead l = new Lead(
            FirstName = 'Harry',
            LastName = 'Potter',
            Email = 'sfadmin@glic-tech.com'
        );
        insert l;

        Venue__c v = new Venue__c(
            Name = '3Arena',
            Email__c = 'sfadmin@glic-tech.com',
            Link__c = 'google.ie'
        );
        insert v;

        Venue__c v1 = new Venue__c(
            Name = 'The White House',
            Email__c = 'sfadmin@glic-tech.com',
            Link__c = 'google.ie'
        );
        insert v1;

        Event_Venues__c ev = new Event_Venues__c(
            Lead__c = l.Id,
            Venue__c = v.Id
        );
        insert ev;

        Event_Venues__c ev1 = new Event_Venues__c(
            Lead__c = l.Id,
            Venue__c = v1.Id
        );
        insert ev1;
    }

    /*
    * Description: Tests the SelectVenues Method.
    *
    * Last modified by Owen in Glic-Tech on 07-07-2021.
    */
    @isTest
    static void testSelectVenues(){
        List<Event_Venues__c> ev = [ select Id, selected__c from Event_Venues__c ];

        Test.startTest();

        Boolean actual = GT_emailTemplate_con.SelectVenues(ev);

        Test.stopTest();

        Boolean expected = true;

        System.assertEquals(expected, actual);
    }

    /*
    * Description: Tests the GetEventVenues Method.
    *
    * Last modified by Owen in Glic-Tech on 07-07-2021.
    */
    @isTest
    static void testGetEventVenues(){
        String leadId = [ select Id from Lead limit 1 ].Id;

        Test.startTest();

        String evs = GT_emailTemplate_con.GetEventVenues(leadId);

        Test.stopTest();

        Boolean expected = true, actual = evs.contains('Id');

        system.debug(evs);

        System.assertEquals(expected, actual);
    }

    /*
    * Description: Tests the getListOfVenues Method.
    *
    * Last modified by Owen in Glic-Tech on 07-07-2021.
    */
    @isTest
    static void testGetListOfVenues(){
        List<Event_Venues__c> evs = [ select Id, selected__c, Lead__c from Event_Venues__c ];

        for( Event_Venues__c ev : evs ){ ev.selected__c = true; }

        update evs;

        GT_emailTemplate_con etc = new GT_EmailTemplate_con();
        etc.leadId = evs[0].Lead__c;

        Test.startTest();

        List<Event_Venues__c> evs1 = etc.getListOfVenues();

        Test.stopTest();

        Integer expected = 2, actual = evs1.size();

        System.assertEquals(expected, actual);
    }

    /*
    * Description: Tests the Constructor.
    *
    * Last modified by Owen in Glic-Tech on 07-07-2021.
    */
    @isTest
    static void testGT_emailTemplate_con(){
        // insert code here
    }

    /*
    * Description: Tests the SendVenuesToCustomer Method.
    *
    * Last modified by Owen in Glic-Tech on 07-07-2021.
    */
    @isTest
    static void testSendVenuesToCustomer(){
        Event_Venues__c ev = [  
            select
                Id,
                Lead__c,
                Venue__r.Id,
                Venue__r.Name,
                Name
            from
                Event_Venues__c
            limit 1
        ];

        string eventVenues = '[{"attributes":{"type":"Event_Venues__c","url":"/services/data/v52.0/sobjects/Event_Venues__c/'+ ev.Id +'"},"Id":"'+ ev.Id +'","Name":"'+ ev.Name +'","Venue__c":"'+ ev.Venue__r.Id +'","Venue__r":{"attributes":{"type":"Venue__c","url":"/services/data/v52.0/sobjects/Venue__c/'+ ev.Venue__r.Id +'"},"Id":"'+ ev.Venue__r.Id +'","Name":"'+ ev.Venue__r.Name +'"}}]';

        Test.startTest();

        Boolean actual = GT_emailTemplate_con.SendVenuesToCustomer(eventVenues, ev.Lead__c);

        Test.stopTest();

        Boolean expected = true;

        System.assertEquals(expected, actual);
    }


    /*
    * Description: Test class for CreateErrors method.
    *
    * Last modified by Owen in Glic-Tech on 07-07-2021.
    */
    @isTest
    static void testCreateErrors(){
        string result = '{"success":false,"errors":[{"message":"Failure"}]}';

        Messaging.SendEmailResult res1 = (Messaging.SendEmailResult) JSON.deserialize(result, Messaging.SendEmailResult.class);
        
        Test.startTest();

        List<Error_Log__c> errors = GT_emailTemplate_con.CreateErrors(res1);

        Test.stopTest();

        Boolean expected = false, actual = errors.isEmpty();

        System.assertEquals(expected, actual);
    }

    /*
    * Description: Tests the SelectProposalCheckbox Method.
    *
    * Last modified by Finbar in Glic-Tech on 13-07-2021.
    */
    @isTest
    static void testSelectProposalCheckbox(){
        List<Lead> l = [ select Id, sendProposal__c from Lead ];

        Test.startTest();

        Boolean actual = GT_emailTemplate_con.SelectProposalCheckbox(l);

        Test.stopTest();

        Boolean expected = true;

        System.assertEquals(expected, actual);
    }
}