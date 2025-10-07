/*
 * Created by Glic-Tech Ltd on 23-06-2021.
 * 
 * Description: Utility class for Inserts, Updates, Deletes & Reads to/from Database.
 * 
 * Last modified by Finbar in Glic-Tech on 23-06-2021.
*/
public class GT_Utilities {
    /*
    * Description: Retrieves records from Database.
    *
    * Last modified by Finbar in Glic-Tech on 23-06-2021.
    */
    public static list<sObject> GetRecords(string objectApiName, list<string> recordIds, string searchField, string extraFields){
        string query = 'SELECT ' + string.join( GetObjectFields(objectApiName), ',' );
        
        if( (extraFields != '') && (extraFields != null) ){ query += ',' + extraFields; }
        
        query += ' FROM ' + objectApiName;
        
        if( (searchField != '') && (searchField != null) ){ query += ' WHERE ' + searchField + ' =: recordIds'; }
        
        return database.query(query);
    }
    
    /*
    * Description: Retrieved list of all fields from sepcified object.
    *
    * Last modified by Finbar in Glic-Tech on 23-06-2021.
    */
    public static list<string> GetObjectFields(string objectApiName){
        return new list<string>( Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().keySet() );
    }
    
    /*
    * Description: Deletes records from Database.
    *
    * Last modified by Finbar in Glic-Tech on 23-06-2021.
    */
    public static boolean DeleteRecords(list<sObject> records){
        string recordIds = ''; for( sObject o : records ){ recordIds += o.Id + ','; }  recordIds.removeEnd(',');
        try{ delete records; return true; } catch(exception e){ insert new error_log__c(error_message__c =e.getMessage(), error_trace__c = e.getStackTraceString(), related_records__c = recordIds); return false; }
    }
    
    /*
    * Description: Updates records in Database.
    *
    * Last modified by Finbar in Glic-Tech on 23-06-2021.
    */
    public static boolean UpdateRecords(list<sObject> records){
        string recordIds = ''; for( sObject o : records ){ recordIds += o.Id + ','; }  recordIds.removeEnd(',');
        try{ update records; return true; } catch(exception e){ insert new error_log__c(error_message__c =e.getMessage(), error_trace__c = e.getStackTraceString(), related_records__c = recordIds); return false; }
    }
    
    /*
    * Description: Inserts records into Database.
    *
    * Last modified by Finbar in Glic-Tech on 23-06-2021.
    */
    public static boolean InsertRecords(list<sObject> records){
        try{ insert records; return true; } catch(exception e){ insert new error_log__c(error_message__c =e.getMessage(), error_trace__c = e.getStackTraceString()); return false; }
    }
}