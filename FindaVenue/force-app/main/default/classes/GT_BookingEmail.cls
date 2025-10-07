/*
 * Created by Glic-Tech Ltd on 03/07/2021.
 *
 * Description: Class to send booking emails to client & venue.
 *
 * Last modified by Finbar in Glic-Tech on 28/07/2021.
*/
public class GT_BookingEmail {
    public Boolean IsEmpty { get; set; }
    public Id RecordId { get; set; }
    public Id VenueID { get; set; }

    /*
    * Description: constructor for class.
    *
    * Last modified by Finbar in Glic-Tech on 03-07-2021.
    */
    public GT_BookingEmail(ApexPages.StandardController sc) {
        this.IsEmpty = false;
        this.RecordId = sc.getId();
        this.VenueID = [SELECT Winning_Venue__c FROM Lead where id =: RecordId].Winning_Venue__c;

    }

    /*
    * Description: Send_booking_Venue_deposit_HTML.
    *
    * Last modified by Finbar in Glic-Tech on 28-07-2021.
    */
    public PageReference autoRun() {
        EmailTemplate et = GetEmailTemplate('Send_booking_Venue_deposit_HTML');

        List<String> emailList = new List<String>();

        String clientEmail = [SELECT email FROM Lead where id =: RecordId].email;
        
        emailList.add(clientEmail);

        
        if (et != null) {
            list<Messaging.SingleEmailMessage> emails = new list<Messaging.SingleEmailMessage>();

            for (Venue__c v : [SELECT email__c FROM Venue__c where id =: this.VenueID]) {
                
                emailList.add(v.Email__c);
                System.debug(emailList);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                mail.setTargetObjectId(this.RecordId);
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setSaveAsActivity(true);
                mail.setToAddresses(emailList) ;
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
    * Description: Send_booking_FAV_deposit_HTML.
    *
    * Last modified by Finbar in Glic-Tech on 27-07-2021.
    */
    public PageReference autoRun2() {
        EmailTemplate et = GetEmailTemplate('Send_booking_FAV_deposit_HTML');

        List<String> emailList = new List<String>();

        String clientEmail = [SELECT email FROM Lead where id =: RecordId].email;
        
        emailList.add(clientEmail);

        
        if (et != null) {
            list<Messaging.SingleEmailMessage> emails = new list<Messaging.SingleEmailMessage>();

            for (Venue__c v : [SELECT email__c FROM Venue__c where id =: this.VenueID]) {
                
                emailList.add(v.Email__c);
                System.debug(emailList);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                mail.setTargetObjectId(this.RecordId);
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setSaveAsActivity(false);
                mail.setToAddresses(emailList) ;
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
    * Last modified by Finbar in Glic-Tech on 04/07/2021.
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
    * Last modified by Finbar in Glic-Tech on 04/07/2021.
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
                        Error_Trace__c = 'Class: GT_BookingEmails'
                    )
                );
            }
        }

        return errors;
    }
}