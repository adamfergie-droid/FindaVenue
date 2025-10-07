public class ProVFTemplateUpdatedCompCtrller {
    public static String templateDevName;
    public static List<String> venueIds;

    public ProVFTemplateUpdatedCompCtrller(){

    }

    public List<Event_Venues__c> getSelectedVenues(){
        List<Id> venueIds = ProVFTemplateUpdatedCompCtrller.venueIds ?? new List<String>();

        return [SELECT Id, Venue_Link__c, Venue_Name_Fornula__c, Account_Venue_Location__c, Proposal_Link__c, Selected_Food_Option__c, Proposed_Cost_Text__c FROM Event_Venues__c WHERE Id IN :venueIds];
    }

    public String getTemplateDevName(){
        return templateDevName;
    }
}