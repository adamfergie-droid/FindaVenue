@isTest
public class reUsableMultiSelectLookupCtrlTest {
	
    @isTest
    public static void fetchLookupValuesTest() {
        Event__c sobj = new Event__c(
            Email__c = 'test@cloudroute.in'  // Email
              // Vessel Name
        );
        
        Event__c sobj1 = new Event__c(
            Email__c = 'test1@cloudroute.in' // Email
             // Vessel Name
                  // Unique IMO Number
        );
        insert sobj1;
        
        //sobj.Name ='USS San Antonio';
        //insert sobj;
        
        reUsableMultiSelectLookupCtrl.fetchLookUpValues('USS', 'Event__c', new SObject[] {(SObject)sobj1});
    } 
}