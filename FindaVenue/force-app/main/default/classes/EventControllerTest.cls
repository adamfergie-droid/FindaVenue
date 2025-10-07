@isTest
public class EventControllerTest {
    
    @isTest
    public static void EventControllerTestMethod() {
        list<Event__c> vesselList = new List<Event__c>();
        Event__c sobj = new Event__c(              
            Email__c = 'test@cloudroute.in' // Email
			
        );
        vesselList.add(sobj);
        insert vesselList;
        
        Test.startTest();
        Test.setCurrentPage(Page.GetSelectedRecordsFromEventList);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(vesselList);
        stdSetController.setSelected(vesselList);
        EventController vc = new EventController(stdSetController);
        vc.redirectToLC();
    }
}