public class EventController {
	public List<Event__c> vesselList {get;set;}
    private ApexPages.StandardSetController standardController;
    private Set<Id> vesselIds = new Set<Id>();
    public string lcURL{get;set;}
    public EventController(ApexPages.StandardSetController standardController){
        //Get List View Id
        System.debug('##current page parameters :'+ApexPages.currentPage().getparameters());
        string listId = ApexPages.currentPage().getparameters().get('vfRetURLInSFX');
        System.debug('##listId :'+listId);
        listId = string.isNotBlank(listId) ? listId.substringAfter('filterName=') : '';
        System.debug('##listId after:'+listId);
        
        this.standardController = standardController;
        vesselList = new List<Event__c>();
        for (Event__c vessel : (List<Event__c>)standardController.getSelected()){ 
            vesselIds.add(vessel.Id);
        }
        vesselList = [SELECT Id, Name, Email__c FROM Event__c WHERE ID IN: vesselIds];
        System.debug('##vesselIds :'+vesselIds);
        lcURL = '/lightning/cmp/c__lc_EventSendEmail?c__selectedRecordIds='+vesselIds+'&c__listViewId='+listId;
    }
    
    public PageReference redirectToLC(){
        System.debug('##lcURL :'+lcURL);
        String returnUrl = lcURL;//'/lightning/cmp/c__lc_EventSendEmail?c__selectedRecordIds='+vesselIds;
        PageReference pgReturnPage = new PageReference(returnUrl);
        pgReturnPage.setRedirect(true);
        return pgReturnPage;
    }
}