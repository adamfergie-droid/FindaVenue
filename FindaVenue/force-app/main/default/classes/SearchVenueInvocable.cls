public without sharing class SearchVenueInvocable {

    public class InputRequest {
        @InvocableVariable(label='Event Scenario')
        public String eventScenario;
        
        @InvocableVariable(label='Venue Type')
        public String venueType;

        @InvocableVariable(label='Event Location')
        public String eventLocation;

        @InvocableVariable(label='Quantity Min')
        public Integer quantityMin;
        
        @InvocableVariable(label='Quantity Max')
        public Integer quantityMax;
        
        @InvocableVariable(label='Capacity')
        public Integer capacity;
    }

    public class OutputResponse {
        @InvocableVariable(label='Account Record')
        public List<Account> accountRecList;

    }

    @InvocableMethod(label='Search Events Dynamically')
    public static List<OutputResponse> searchEvents(List<InputRequest> requests) {
        List<OutputResponse> results = new List<OutputResponse>();
        String fullQuery;

        for (InputRequest req : requests) {
            String query = 'SELECT Id, Name,Entire_Venue_Capacity__c,Theatre_Capacity__c,Banquet_Capacity_double__c,Reception_Standing_Capacity__c,Area__c,Quality_Of_Venue_1_Highest__c, RecordType.Name FROM Account WHERE ';
            List<String> conditions = new List<String>();
            
            if (req.quantityMin != null) {
                conditions.add('QualityFormula__c  >='+ req.quantityMin);
            }
            
            if (req.quantityMax != null) {
                conditions.add('QualityFormula__c  <='+ req.quantityMax);
            }
            
            if (req.capacity != null) {
                conditions.add('Entire_Venue_Capacity__c >='+ req.capacity);
            }
            
            if (String.isNotBlank(req.venueType)) {
                String venueType = 'Bar';
                conditions.add('Venue_Type_New__c = '+ '\'' + req.venueType + '\'');
            }
            if (String.isNotBlank(req.eventLocation)) {
                conditions.add('Area__c  = '+ '\'' + req.eventLocation + '\'');
            }
            
            System.debug('eventScenario: ' + req.eventScenario);
            if (String.isNotBlank(req.eventScenario)) {
                List<String> interests = req.eventScenario.split(';');
                    
                    // Escape any single quotes in values
                    for (Integer i = 0; i < interests.size(); i++) {
                        interests[i] = interests[i].replace('\'', '\\\'');
                    }
                
                conditions.add('Event_Scenarios__c INCLUDES (\'' + String.join(interests, '\', \'') + '\')');
            }
            
            fullQuery = query + String.join(conditions, ' AND ');
        	
        }
        
        //Check Dyanmic Query
        fullQuery = fullQuery.trim();
        
        // Check if it ends with 'WHERE'
        if (fullQuery.endsWith('WHERE')) {
            // Remove 'WHERE' and any trailing spaces
            fullQuery = fullQuery.substring(0, fullQuery.length() - 'WHERE'.length()).trim();
        }
        
        
        System.debug('Dynamic Query: ' + fullQuery);
        List<Account> venueAccount = Database.query(fullQuery);
        List<Account> potentialVenues = new List<Account>();
        
        for (Account acct : venueAccount) {
            if(acct.RecordType.Name == 'Venue'){
                potentialVenues.add(acct);
               
            }
        }
		OutputResponse res = new OutputResponse();
        res.accountRecList = potentialVenues;
        results.add(res);
        return results;
    }
}