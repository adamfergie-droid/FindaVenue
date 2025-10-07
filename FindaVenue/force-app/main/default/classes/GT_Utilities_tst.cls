/*
 * Created by Glic-Tech Ltd on 23-06-2021.
 *
 * Description: Test class for GT_Utilities.
 *
 * Last modified by Finbar in Glic-Tech on 23-06-2021.
*/
@isTest 
class GT_Utilities_tst {
    /*
    * Description: Tests the GetObjectFields Method.
    *
    * Last modified by Finbar in Glic-Tech on 23-06-2021.
    */
    @istest 
    static void testGetObjectFields(){
        string objectApiName = 'Error_Log__c';
        
        Test.startTest();
        
        list<string> fields = GT_Utilities.GetObjectFields(objectApiName);
        
        Test.stopTest();
        
        boolean actual = true; if( (fields.isEmpty()) || (fields == null) ){ actual = false; }
        
        system.assertEquals(true, actual);
    }
    
    /*
    * Description: Tests the InsertRecords Method.
    *
    * Last modified by Finbar in Glic-Tech on 23-06-2021.
    */
    @istest 
    static void testInsertRecords(){
        Test.startTest();
        
        boolean actual = GT_Utilities.InsertRecords(new list<Error_Log__c> { new Error_Log__c() });
        
        Test.stopTest();
        
        system.assertEquals(true, actual);
    }
    
    /*
    * Description: Tests the UpdateRecords Method.
    *
    * Last modified by Finbar in Glic-Tech on 23-06-2021.
    */
    @istest 
    static void testUpdateRecords(){
        Error_Log__c e = new Error_Log__c();
        insert e;
        
        e.Related_Records__c = e.Id;
        
        Test.startTest();
        
        boolean actual = GT_Utilities.UpdateRecords(new list<Error_Log__c> { e });
        
        Test.stopTest();
        
        system.assertEquals(true, actual);
    }
    
    /*
    * Description: Tests the DeleteRecords Method.
    *
    * Last modified by Finbar in Glic-Tech on 23-06-2021.
    */
    @istest
    static void testDeleteRecords(){
        Error_Log__c e = new Error_Log__c();
        insert e;
        
        Test.startTest();
        
        boolean actual = GT_Utilities.DeleteRecords(new list<Error_Log__c> { e });
        
        Test.stopTest();
        
        system.assertEquals(true, actual);
    }
    
    /*
    * Description: Tests the GetRecords Method.
    *
    * Last modified by Finbar in Glic-Tech on 23-06-2021.
    */
    @istest 
    static void testGetRecords(){
        Error_Log__c e = new Error_Log__c();
        insert e;
        
        string objectApiName = 'Error_Log__c', searchField = 'Id', extraFields = '';
        list<string> recordIds = new list<string> { e.Id };
        
        Test.startTest();
        
        list<sObject> records = GT_Utilities.GetRecords(objectApiName, recordIds, searchField, extraFields);
        
        Test.stopTest();
        
        integer actual = records.size(), expected = 1;
        
        system.assertEquals(expected, actual);
    }
}