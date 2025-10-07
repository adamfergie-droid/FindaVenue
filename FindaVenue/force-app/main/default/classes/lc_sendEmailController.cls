public class lc_sendEmailController {
    @AuraEnabled
    public static MailSentWrapper sendEmail(String AllRecordIds, String objectApiName, String emailFieldName, String Subject, String body, String getCcEmails, String getBccEmails, String choice, list<String> attachments) {
        try{
            System.debug('##AllRecordIds :'+AllRecordIds);
            System.debug('##getCcEmails'+ getCcEmails);
            System.debug('##getBccEmails'+getBccEmails);
            //check if user wants to send bulk emails of each email individually
            boolean sendSingularEmails = choice.equalsIgnoreCase('true') ? true : false ;
            set<Id> recordIds = new set<Id>();
            Map<String,String> mapOfEmailWithVesselId = new Map<String, String>();

            //Parse List Of record ids from Json
            List<recordIdWrapper> recordList = (List<recordIdWrapper>) System.JSON.deserialize(AllRecordIds, List<recordIdWrapper>.class);
            system.debug('##recordList :' + recordList);
            for(recordIdWrapper record : recordList) {
                recordIds.add(record.Id);
            }
            System.debug('##recordIds :'+ recordIds);
            set<String> mailIds = new set<String>();
            //Get all Records using Database.query
            String sQuery = 'SELECT Id, Name, '+ emailFieldName + ' FROM ' + objectApiName + ' WHERE Id IN : recordIds';
            System.debug(sQuery);
            list<SObject> selectedRecords = Database.query(sQuery);
            for(Sobject s : selectedRecords) {
                //list<String> mailIdList = (String.valueOf(s.get(emailFieldName))).split(',');
                //Take first email, if it has more than one email in email field
                String emailString = String.valueOf(s.get(emailFieldName));
                if(string.isNotBlank(emailString) && emailString.contains(',')){ //Means it has multiple addresses
                    string firstEmailString = emailString.substringBefore(',');
                    System.debug('##firstEmailString :'+firstEmailString);
                    mailIds.add(firstEmailString);
                    mapOfEmailWithVesselId.put(firstEmailString,String.valueOf(s.get('Id')));
                }else{
                    mailIds.add(emailString);
                    mapOfEmailWithVesselId.put(emailString,String.valueOf(s.get('Id')));
                }
            }
            System.debug('mailIds '+mailIds);
            System.debug('mapOfEmailWithVesselId '+mapOfEmailWithVesselId);
            System.debug('Subject '+subject);
            System.debug('Body '+body);
            System.debug('sendSingleEmail '+sendSingularEmails);

            list<String> ccEmails = new List<String>();
            list<String> bccEmails = new List<String>();
            
            //To remove P tag margin
            if(String.isNotBlank(body)){
            	body = body.replaceAll('<p>','<p style="margin-top:0px;margin-bottom:0px;">');
            }

            if(!String.isEmpty(getCcEmails)) {
                for(String email : getCcEmails.split(',')) {
                    ccEmails.add(email.trim());
                    System.debug('ccEmails'+ccEmails);
                }
            }
            if(!String.isEmpty(getBccEmails)) {
                for(String bccEmail : getBccEmails.split(',')) {
                    bccEmails.add(bccEmail.trim());
                    System.debug('BccEmails'+bccEmails);
                }
            }
            //Check is Emails are present are present
            if(!mailIds.isEmpty()) {
                list<String> versionIds = new List<String>();
                //EMAIL ATTACHMENT CODE
                if(!attachments.isEmpty()){
                    List<ContentVersion> versions = [SELECT Id FROM ContentVersion WHERE ContentDocumentId IN : attachments];

                    for(ContentVersion cv : versions){
                        versionIds.add(cv.Id);
                    }
                    System.debug('##VersionIds :'+versionIds);
                }

                List<OrgWideEmailAddress> orgList = [SELECT id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = : Label.sendEmailCmpOrWideEmailDispName LIMIT 1];

                list<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
                // If the user wants to send bulk emails send all mails at once
                if(!sendSingularEmails) {
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    list<String> allEmails = new list<String>();
                    allEmails.addAll(mailIds);
                    message.toAddresses = allEmails;
                    if(orgList != null && !orgList.isEmpty()){
                        message.setOrgWideEmailAddressId(orgList[0].Id);
                    }

                    message.subject = Subject;
                    if(!ccEmails.isEmpty()) {
                        message.ccaddresses = ccEmails;
                    }
                    if(!bccEmails.isEmpty()) {
                        message.bccaddresses = bccEmails;
                    }
                    message.setHtmlBody(body);
                    if(versionIds.size() > 0){
                        message.setEntityAttachments(versionIds);
                    }

                    messages.add(message);

                    System.debug(JSON.serialize(message));
                } else {
                    // If the user wants to send single message set messages using for loop
                    for(String personId : mailIds) {
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        message.toAddresses = new String[] {personId};
                        if(orgList != null && !orgList.isEmpty()){
                            message.setOrgWideEmailAddressId(orgList[0].Id);
                        }
                        message.subject = Subject;
                        if(mapOfEmailWithVesselId != null && mapOfEmailWithVesselId.containsKey(personId)){
                            System.debug('##mapOfEmailWithVesselId.containsKey(personId) :'+mapOfEmailWithVesselId.containsKey(personId));
                            message.setWhatId(mapOfEmailWithVesselId.get(personId));
                            message.setSaveAsActivity(true);
                        }

                        if(!ccEmails.isEmpty()) {
                            message.ccaddresses = ccEmails;
                        }
                        if(!bccEmails.isEmpty()) {
                            message.bccaddresses = bccEmails;
                        }
                        message.setHtmlBody(body);
                        if(versionIds.size() > 0){
                            message.setEntityAttachments(versionIds);
                        }
                        messages.add(message);
                        System.debug('##Final Email Message :'+JSON.serialize(message));
                    }

                }
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                System.debug('##results :'+results);
                if (results[0].success) {
                    if(!versionIds.isEmpty()) {
                        //deleteDocumentsAfterEmailSend(attachments);
                        //Tushar@cloudroute.in commented this code on 21st Aug 2020, because we need to save sent email "activity" and which requires files to be there. 
						//So as per checking inside salesforce the file is not related to specified group.
                    }
                    MailSentWrapper wrapper = new MailSentWrapper();
                    wrapper.IsSent = true;
                    wrapper.error = false;
                    return wrapper;

                } else {
                    MailSentWrapper wrapper = new MailSentWrapper();
                    wrapper.IsSent = false;
                    wrapper.error = true;
                    return wrapper;
                }
            } else {
                MailSentWrapper wrapper = new MailSentWrapper();
                wrapper.IsSent = false;
                wrapper.error = true;
                return wrapper;
            }
        }catch(Exception e){
            MailSentWrapper wrapper = new MailSentWrapper();
            wrapper.IsSent = false;
            wrapper.error = true;
            wrapper.errorMessage = e.getMessage();
            return wrapper;
        }
    }
    public class MailSentWrapper {
        @AuraEnabled public boolean IsSent;
        @AuraEnabled public boolean error;
        @AuraEnabled public string errorMessage;
    }
    
    @AuraEnabled
    public static preSelectedRecordsSobjectsWrapper preSelectedRecordObjects(String recordIds, String objectApiName, String emailFieldName) {
        System.debug('##recordIds :'+recordIds);
        // Get All Records in string format and convert them to list
        String recordString = (recordIds.remove('{')).remove('}');
        list<String> recordIdList = new List<String>();
        for(String s : recordString.split(',')){
            s = s.trim();
            recordIdList.add(s);
        }
        //list<String> recordIdList =(list<String>)recordString.split(',');
        System.debug('##recordIdList :'+ recordIdList);
        String query = 'SELECT Id, Name, '+ emailFieldName +' FROM '+ objectApiName + ' WHERE Id IN :recordIdList';
        System.debug('query'+query);
        System.debug(recordIds);
        list<Sobject> sObjectList = Database.query(query);
        System.debug(JSON.serializePretty(sObjectList));
        if(!sObjectList.isEmpty()) {
            List<recordIdWrapper> wrappers = new List<recordIdWrapper>();
            for(sObject sobj : sObjectList){
                recordIdWrapper wrap = new recordIdWrapper();
                wrap.Id = String.valueOf(sobj.get('Id'));
                String emailString = String.valueOf(sobj.get(emailFieldName));
                emailString = string.isNotBlank(emailString) && emailString.contains(',') ? emailString.substringBefore(',') : emailString;
                wrap.Name = String.valueOf(sobj.get('Name'))+' - '+emailString;
                wrap.Email = String.valueOf(sobj.get(emailFieldName));
                wrappers.add(wrap);
            }
            preSelectedRecordsSobjectsWrapper wrapper = new preSelectedRecordsSobjectsWrapper();
            wrapper.isSuccess = true;
            wrapper.selectedRecords = wrappers;
            return wrapper;
        } else {
            preSelectedRecordsSobjectsWrapper wrapper = new preSelectedRecordsSobjectsWrapper();
            wrapper.isSuccess = false;
            return wrapper;
        }
    }
    
    
    @AuraEnabled
    public static boolean deleteDocument(String documentId){
        system.debug('Delete Document Called');
        system.debug('documentId: ' + documentId);
        boolean isSuccess = false;
        try {
            isSuccess = true;
            List<ContentDocument> deleteList = [Select Id from ContentDocument where Id = :documentId];
            delete deleteList;
        }catch(exception ex){
            system.debug('@@Exception' + ex);
            isSuccess = false;
        }
        return isSuccess;
        
    }
    
    /*@future
    public static void deleteDocumentsAfterEmailSend(list<String> contentDocumentIds) {
        try {
            List<ContentDocument> deleteList = [Select Id from ContentDocument where Id = :contentDocumentIds];
            delete deleteList; 
        }catch(exception ex){
            system.debug('@@Exception' + ex);
        }
    }*/
    
    public class preSelectedRecordsSobjectsWrapper {
        @AuraEnabled public boolean isSuccess;
        @AuraEnabled public list<recordIdWrapper> selectedRecords;
    }

    public class recordIdWrapper {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String Email;
    }
}