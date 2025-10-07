/*
 * Created by Glic-Tech Ltd on 15/06/2021.
 *
 * Description: Class to send emails to venues.
 *
 * Last modified by Finbar in Glic-Tech on 28/07/2021.
*/
public class GT_Lead_Proposal_Email {
    /*
    * Description: Get Venues.
    *
    * Last modified by Finbar in Glic-Tech on 23/06/2021.
    */
    @AuraEnabled
    public static string getVenues(string leadId){
        string result = ''; 

        if ( (leadId != '') && (leadId != null) ) {
            List<SObject> x = [ 
                select
                    Id,
                    Name,
                    Venue__c,
                    Venue_Email__c,
                    Venue__r.Name
                from
                    Event_Venues__c
                where
                    Lead__c =: leadId
            ];

            if (! x.isEmpty() ) {
                List<VenueWrapper> wraps = new List<VenueWrapper>();

                for( SObject s : x ){
                    VenueWrapper wv = new VenueWrapper();
                    wv.Id = (string)s.Id;
                    wv.Name = (string)s.getSObject('Venue__r').get('Name');
                    wv.Email = (string)s.get('Venue_Email__c');

                    wraps.add(wv);
                }

                result = JSON.serialize( wraps ); 
            }
        }

        return result;
    }

    /*
    * Description: Sends email to venues.
    *
    * Last modified by Finbar in Glic-Tech on 28/07/2021.
    */
    @AuraEnabled
    public static boolean emailVenues(string leadId, string venues){
        boolean result = false;

        if ( (leadId != '') && (leadId != null) && (venues != '') && (venues != null) ) {
            list<string> venueIds;

            try { venueIds = (list<string>)JSON.deserialize(venues, list<string>.class); } catch (Exception e) { insert new error_log__c(error_message__c =e.getMessage(), error_trace__c = e.getStackTraceString(), related_records__c = leadId); }

            if (venueIds != null) {
                EmailTemplate et = GetEmailTemplate('Send_proposals_HTML');

                if (et != null) {
                    list<Messaging.SingleEmailMessage> emails = new list<Messaging.SingleEmailMessage>();

                    for (Event_Venues__c ev : [select id, lead__c, venue__c, venue_email__c from Event_Venues__c where id =: venueIds ]) {
                        
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                        mail.setTargetObjectId(leadId);
                        mail.setTreatTargetObjectAsRecipient(false);
                        mail.setSaveAsActivity(true);
                        mail.setToAddresses(new list<string>{ ev.venue_email__c }) ;
                        mail.setTemplateID(et.Id); 

                        emails.add(mail);
                    }

                    Messaging.SendEmailResult[] results;

                    try { results = Messaging.sendEmail(emails, true); } catch (Exception e) { insert new error_log__c(error_message__c =e.getMessage(), error_trace__c = e.getStackTraceString(), related_records__c = leadId); }

                    List<Error_Log__c> errors = new List<Error_Log__c>();

                    if( results != null ){

                        for (Messaging.SendEmailResult res : results) {
                            List<Error_Log__c> x = CreateErrors(res);
                            
                            if (! x.isEmpty()) { errors.addAll(x); }
                        }

                        if(! errors.isEmpty() ){ GT_Utilities.InsertRecords(errors); }
                    }

                    if( errors.isEmpty() ){ result = true; }
                }
            }
        }

        return result;
    }

    /*
    * Description: Retrieves email template.
    *
    * Last modified by Finbar in Glic-Tech on 23/06/2021.
    */
    @testvisible
    static EmailTemplate GetEmailTemplate(string tempName){
        EmailTemplate result;

        list<EmailTemplate> temps = [ 
            select 
                Id, 
                Subject, 
                HtmlValue, 
                DeveloperName, 
                Body
            from 
                EmailTemplate 
            where 
                DeveloperName =: tempName
        ];

        if (! temps.isEmpty() ) { result = temps[0]; }

        return result;
    }

    /*
    * Description: Creates error logs.
    *
    * Last modified by Finbar in Glic-Tech on 24/06/2021.
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
                        Error_Trace__c = 'Class: GT_Lead_Proposal_Email: line 85'
                    )
                );
            }
        }

        return errors;
    }

    /*
    * Description: Wrapper class for displaying event venues.
    *
    * Last modified by Finbar in Glic-Tech on 23/06/2021.
    */
    @testvisible
    class VenueWrapper{
        public string Id { get; set; }
        public string Name { get; set; }
        public string Email { get; set; }
    }
}