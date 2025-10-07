public class SendEventVenuesEmailInvocable {
    @InvocableMethod(label='Send Event Venues Email')
    public static void sendEmail(List<FlowInput> inputs){
        FlowInput input = inputs[0];

        List<EmailTemplate> emailTemps = [SELECT Id, DeveloperName FROM EmailTemplate WHERE Id = :input.emailTemplateId];

        ProVFTemplateUpdatedCompCtrller.templateDevName = emailTemps[0].DeveloperName;
        ProVFTemplateUpdatedCompCtrller.venueIds = input.venueIds;

        Messaging.SingleEmailMessage newEmailMsg = new Messaging.SingleEmailMessage();
        newEmailMsg.setTemplateId(input.emailTemplateId);
        newEmailMsg.setTargetObjectId(input.opportunityId);
        newEmailMsg.setToAddresses(input.recipientEmails);
        newEmailMsg.setWhatId(input.opportunityId);
        newEmailMsg.setTargetObjectId(input.recipientId);

        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{newEmailMsg});
    }

    public class FlowInput{
        @InvocableVariable
        public Id opportunityId;
        @InvocableVariable
        public List<Id> venueIds;
        @InvocableVariable
        public Id recipientId;
        @InvocableVariable
        public List<String> recipientEmails;
        @InvocableVariable
        public Id emailTemplateId;
    }
}