/*
 * Created by Glic-Tech Ltd on 15/06/2021.
 *
 * Description: Class to send emails to venues.
 *
 * Last modified by Finbar in Glic-Tech on 28/07/2021.
*/
public class GT_Lead_Emails {
    public Boolean IsEmpty { get; set; }
    public Id RecordId { get; set; }

    /*
    * Description: constructor for class.
    *
    * Last modified by Owen in Glic-Tech on 24-06-2021.
    */
    public GT_Lead_Emails(ApexPages.StandardController sc) {
        this.IsEmpty = false;
        this.RecordId = sc.getId();
    }
    
    /*
    * Description: availability email.
    *
    * Last modified by Finbar in Glic-Tech on 28-07-2021.
    */
    public PageReference autoRun() {
        EmailTemplate et = GetEmailTemplate('Check_availability_HTML');

        if (et != null) {
            list<Messaging.SingleEmailMessage> emails = new list<Messaging.SingleEmailMessage>();

            for (Event_Venues__c ev : [select id, lead__c, venue__c, venue_email__c from Event_Venues__c where lead__c =: this.RecordId ]) {
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                mail.setTargetObjectId(this.RecordId);
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setSaveAsActivity(true);
                mail.setToAddresses(new list<string>{ ev.venue_email__c }) ;
                mail.setTemplateID(et.Id); 

                emails.add(mail);
            }

            Messaging.SendEmailResult[] results;

            try { results = Messaging.sendEmail(emails, true); } catch (Exception e) { insert new error_log__c(error_message__c =e.getMessage(), error_trace__c = e.getStackTraceString(), related_records__c = this.RecordId); }

            List<Error_Log__c> errors = new List<Error_Log__c>();

            if( results != null ){

                for (Messaging.SendEmailResult res : results) {
                    List<Error_Log__c> x = CreateErrors(res);
                    
                    if (! x.isEmpty()) { errors.addAll(x); }
                }

                if(! errors.isEmpty() ){ GT_Utilities.InsertRecords(errors); }
            }
        }

        PageReference pageRef = new PageReference('/' + this.RecordId);
        pageRef.setRedirect(true);

        return pageRef;
    }

    /*
    * Description: Retrieves email template.
    *
    * Last modified by Finbar in Glic-Tech on 24/06/2021.
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
    * Last modified by Finbar in Glic-Tech on 29/06/2021.
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
                        Error_Trace__c = 'Class: GT_Lead_Emails: line 85'
                    )
                );
            }
        }

        return errors;
    }

}