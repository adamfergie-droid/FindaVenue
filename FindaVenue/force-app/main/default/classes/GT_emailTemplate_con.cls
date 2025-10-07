/*
 * Created by Glic-Tech Ltd on 06/07/2021.
 *
 * Description: controller for vf email template.
 *
 * Last modified by Finbar in Glic-Tech on 14/07/2021.
*/
public class GT_emailTemplate_con {
    public Id leadId { get; set; }
    //public List<Event_Venues__c> venues { get; set; }

    /*
    * Description: class constructor.
    *
    * Last modified by Finbar in Glic-Tech on 07/07/2021.
    */
    public GT_emailTemplate_con() {
        // insert code here
    }

    /*
    * Description: Retrieve list of records based on Lead Id.
    *
    * Last modified by Finbar in Glic-Tech on 14-07-2021.
    */
    public List<Event_Venues__c> getListOfVenues(){
        return [ select Id, Name, Venue_Link__c, Venue__r.Name from Event_Venues__c where Lead__c =: this.leadId and selected__c = true ];
    }

    /*
    * Description: Retrieves Event Venues related to the specified Lead.
    *
    * Last modified by Finbar in Glic-Tech on 14-07-2021.
    */
    @AuraEnabled
    public static string GetEventVenues(string leadId){
        string result = '';

        if( (leadId != null) && (leadId != '') ){
            List<Event_Venues__c> venues = [ select Id, Name, Venue_Email__c, Venue__r.Name from Event_Venues__c where Lead__c =: LeadId ];

            if(! venues.isEmpty() ){
                result = JSON.serialize(venues);
            }
        }

        return result;
    }

    /*
    * Description: Sends the venues to the customer.
    *
    * Last modified by FInbar in Glic-Tech on 08-07-2021.
    */
    @AuraEnabled
    public static Boolean SendVenuesToCustomer(string eventVenues, string leadId){
        Boolean result = false;
        List<Lead> leadList = new List<Lead>();

        Lead l = [
            select
                Id,
                Email,
                sendProposal__c
            from 
                Lead
            where 
                Id =: leadId
        ];

        leadList.add(l);

        List<Event_Venues__c> venues;

        try{ venues = (List<Event_Venues__c>)JSON.deserialize(eventVenues, List<Event_Venues__c>.class); } catch(Exception e){ insert new Error_Log__c(Error_Message__c = e.getMessage(), Error_Trace__c = e.getStackTraceString()); }

        if( venues != null ){
            Boolean ans = SelectVenues(venues);

            if( ans ){
                SelectProposalCheckbox(leadList);
                result = true;
            }
        }

        return result;
    }

    /*
    * Description: Creates Error Log records.
    *
    * Last modified by Owen in Glic-Tech on 07-07-2021.
    */
    @testvisible
    static list<error_log__c> CreateErrors(Messaging.SendEmailResult res){
        list<error_log__c> errors = new list<error_log__c>();

        if (! res.isSuccess() ) {
            Messaging.SendEmailError[] errs = res.getErrors();

            for( Messaging.SendEmailError err : errs ){
                errors.add(
                    new Error_Log__c(
                        Error_Message__c = err.getMessage(),
                        Related_Records__c = err.getTargetObjectId(),
                        Error_Trace__c = 'Class: GT_emailTemplate_con: line 133'
                    )
                );
            }
        }

        return errors;
    }

    /*
    * Description: Selects the venues to put on the email to customer.
    *
    * Last modified by Finbar in Glic-Tech on 08-07-2021.
    */
    @testvisible
    static Boolean SelectVenues(List<Event_Venues__c> venues){
        for( Event_Venues__c ev : venues ){ if(! ev.selected__c ){ ev.selected__c = true; } }
        return GT_Utilities.UpdateRecords(venues);
    }

    /*
    * Description: Selects the send proposal checkbox.
    *
    * Last modified by Finbar in Glic-Tech on 08-07-2021.
    */
    @testvisible
    static Boolean SelectProposalCheckbox(List<Lead> lead){
        for( Lead l : lead ){ if(! l.sendProposal__c ){ l.sendProposal__c = true; } }
  
        return GT_Utilities.UpdateRecords(lead);
    }

}