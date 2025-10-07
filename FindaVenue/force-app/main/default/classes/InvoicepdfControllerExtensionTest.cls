@isTest(SeeAllData=true)
public class InvoicepdfControllerExtensionTest {
//Create Test Data
	public static testmethod void loadData(){
        Invoice__c Invoice = new Invoice__c(
          Date__c = Date.newInstance(2020, 05, 18), // Date
          Description_of_Service__c = 'Test Description 4'  // Description
        );
        
        Test.startTest();
        
        PageReference pageRef = Page.InvoicePDF;
        pageRef.getParameters().put('invoice', String.ValueOf(Invoice.Id));
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(Invoice);
        InvoicePdfControllerExtension con = new InvoicePdfControllerExtension(sc);
        
        Test.stopTest();
        
    } 
     
}