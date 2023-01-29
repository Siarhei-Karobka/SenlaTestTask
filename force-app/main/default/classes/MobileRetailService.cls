@RestResource(urlMapping = '/mobileOrders/*')
global with sharing class MobileRetailService {
    private static List<Database.Error> errors = new List<Database.Error>();
    private static Boolean hasErrors = false;
    private static List<Opportunity> oppsForUpdate = new List<Opportunity>();
    private static List<Opportunity> oppsNotFound = new List<Opportunity>();

    @HttpPost
    global static void insertMobileOrder(){
        RestRequest req = RestContext.request;
        RestResponse res = new RestResponse();
        String reqBody = req.requestBody.toString();

        try {
            List<Opportunity> opportunities = (List<Opportunity>)JSON.deserialize(reqBody, List<Opportunity>.class);
            Database.SaveResult[] srList = Database.insert(opportunities, false);
            checkForSaveErrors(srList);
            if (hasErrors) {
                res.statusCode = 500;
                res.responseBody = Blob.valueOf(JSON.serialize(errors));
            }
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(e.getMessage());
        }
    }

    @HttpPatch
    global static void updateMobileOrder(){
        RestRequest req = RestContext.request;
        RestResponse res = new RestResponse();
        String reqBody = req.requestBody.toString();
        CampaignApiParams params = new CampaignApiParams(req.params);

        try {
            List<Opportunity> opportunities = (List<Opportunity>)JSON.deserialize(reqBody, List<Opportunity>.class);
            Database.SaveResult[] srList;

            if (!params.findByEmailAndRN) { //Update By ID
                srList = Database.update(opportunities, false);
            } else { //Update By Email And Retail Number
                Map<String,Opportunity> emailRNToOppMap = emailRNToOppIdMap(opportunities);
                Map<String, String> emailRNToOppIdMap = selectByEmailRN (emailRNToOppMap);
                matchByEmailRN(emailRNToOppMap, emailRNToOppIdMap);
                srList = Database.update(oppsForUpdate, false);
            }
            checkForSaveErrors(srList);
            if (hasErrors) {
                res.statusCode = 500;
                res.responseBody = Blob.valueOf(JSON.serialize(errors));
            }
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(e.getMessage());
        }
    }

    @HttpDelete
    global static void deleteMobileOrder(){
        RestRequest req = RestContext.request;
        RestResponse res = new RestResponse();
        String reqBody = req.requestBody.toString();
        CampaignApiParams params = new CampaignApiParams(req.params);

        try {
            List<Opportunity> opportunities = (List<Opportunity>)JSON.deserialize(reqBody, List<Opportunity>.class);
            Database.DeleteResult[] drList;
            if (!params.findByEmailAndRN) { //Delete By ID
                drList = Database.delete(opportunities, false);
            } else { //Delete By Email And Retail Number
                Map<String,Opportunity> emailRNToOppMap = emailRNToOppIdMap(opportunities);
                Map<String, String> emailRNToOppIdMap = selectByEmailRN (emailRNToOppMap);
                matchByEmailRN(emailRNToOppMap, emailRNToOppIdMap);
                drList = Database.delete(oppsForUpdate, false);
            }
            checkForDeleteErrors(drList);
            if (hasErrors) {
                res.statusCode = 500;
                res.responseBody = Blob.valueOf(JSON.serialize(errors));
            }
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(e.getMessage());
        }
    }

    private static void checkForSaveErrors(Database.SaveResult[] srList){
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                hasErrors = true;
                errors.addAll(sr.getErrors());
            }
        }
    }

    private static void checkForDeleteErrors(Database.DeleteResult[] drList){
        for (Database.DeleteResult sr : drList) {
            if (!sr.isSuccess()) {
                hasErrors = true;
                errors.addAll(sr.getErrors());
            }
        }
    }

    private static Map<String,Opportunity> emailRNToOppIdMap(List<Opportunity> opportunities){
        Map<String,Opportunity> emailRNToOppMap = new Map<String,Opportunity>();
        for (Opportunity opportunity : opportunities) {
            if (!String.isBlank(opportunity.Email__c) && !String.isBlank(opportunity.RetailNumber__c)) {
                emailRNToOppMap.put(opportunity.Email__c + opportunity.RetailNumber__c, opportunity);
            } else {
                oppsNotFound.add(opportunity);
            }
        }
        return emailRNToOppMap;
    }

    private static Map<String, String> selectByEmailRN(Map<String,Opportunity> emailRNToOppMap){
        Map<String, String> emailRNToOppIdMap = new Map<String, String>();
        List<Opportunity> opps = [SELECT Id,
                                        EmailToRetailNumber__c
                                    FROM Opportunity
                                    WHERE EmailToRetailNumber__c IN: emailRNToOppMap.keySet()
                                    ];
        for (Opportunity opp : opps) {
            emailRNToOppIdMap.put(opp.EmailToRetailNumber__c, opp.Id);
        }
        return emailRNToOppIdMap;
    }

    private static void matchByEmailRN(Map<String,Opportunity> emailRNToOppMap, Map<String, String> emailRNToOppIdMap){
        for (Opportunity opp : emailRNToOppMap.values()) {
            if (emailRNToOppIdMap.get(opp.Email__c + opp.RetailNumber__c) != null) {
                opp.Id = emailRNToOppIdMap.get(opp.Email__c + opp.RetailNumber__c);
                oppsForUpdate.add(opp);
            } else {
                oppsNotFound.add(opp);
            }
        }
    }

    public class CampaignApiParams{
		public Boolean findByEmailAndRN {get;set;}

		public CampaignApiParams(Map<String, Object> params){
			for(String key : params.keySet()){
				params.put(key.toLowerCase(), params.get(key));
			}
			this.findByEmailAndRN = params.containsKey('EmailAndRN') ? (String.isBlank((String) params.get('EmailAndRN')) ? true : Boolean.valueOf(params.get('EmailAndRN'))) : false;
		}
	}
}