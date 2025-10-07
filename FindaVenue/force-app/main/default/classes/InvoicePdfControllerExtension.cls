public class InvoicePdfControllerExtension {
    //Invoice
    public Invoice__c invoice;
    //public static List<Invoice_Product__c> invoiceProducts{get; set;}
    //Controller Constructor
    public InvoicePdfControllerExtension(ApexPages.StandardController controller) {
        invoice = (Invoice__c) controller.getRecord();
    }
    
    //Get Invoice Products  
}