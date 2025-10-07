@isTest
public class lc_sendEmailControllerTest {
    @isTest (SeeAllData=true)
    public static void sendEmailTest() {
        String recordIds ='{';
        Event__c sobj = new Event__c(
            Email__c = 'test@cloudroute.in'
        );
        insert sobj;
        recordIds += sobj.Id;
        Event__c sobj1 = new Event__c(
            Email__c = 'test1@cloudroute.in'  // Email
        );
        insert sobj1;
        recordIds = recordIds + ','+ sobj1.Id;
        recordIds = recordIds + '}';
        String AllRecordIds = '[{"Email":"'+sobj.Email__c+'","Id":"'+sobj.Id+'","Name":"'+sobj.Name+'"},{"Email":"'+sobj1.Email__c+'","Id":"'+sobj1.Id+'","Name":"'+sobj1.Name+'"}]';
        String objectApiName ='Event__c';
        String emailFieldName = 'Email__c';
        String Subject = 'Testing email send';
        String body ='<b>Tetsing in bold html</b>';
        String getCcEmails = 'test2@cloudroute.in';
        String getBccEmails = 'test3@cloudroute.in';
        String Choice = 'true';
        List<String> attachments = new List<String>();
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        lc_sendEmailController.sendEmail(AllRecordIds, objectApiName, emailFieldName, Subject, body, getCcEmails, getBccEmails, Choice, new String[] {cv.ContentDocumentId});
        
        sobj1.Email__c ='aishwarya.m@cloudroute.in';
        update sobj1;
        lc_sendEmailController.sendEmail(AllRecordIds, objectApiName, emailFieldName, Subject, body, getCcEmails, getBccEmails, 'False', attachments);
        lc_sendEmailController.sendEmail('', objectApiName, emailFieldName, Subject, body, getCcEmails, getBccEmails, 'False', attachments);
        lc_sendEmailController.preSelectedRecordObjects(recordIds, objectApiName, emailFieldName); 
        lc_sendEmailController.preSelectedRecordObjects('', objectApiName, emailFieldName); 
    }
    @isTest
    public static void deleteContentDocument() {
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        list<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        lc_sendEmailController.deleteDocument(cdList[0].Id);
        //lc_sendEmailController.deleteDocumentsAfterEmailSend(new String[] {cdList[0].Id});
    }
}