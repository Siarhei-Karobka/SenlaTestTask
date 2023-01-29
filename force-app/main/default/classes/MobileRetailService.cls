@RestResource(urlMapping = '/mobileOrders/*')
global with sharing class MobileRetailService {

    @HttpPost
    global static void insertMobileOrder(){
        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.toString();
        List<Opportunity> opportunities = (List<Opportunity>)JSON.deserialize(reqBody, List<Opportunity>.class);
        System.debug('Opportunities: ' + opportunities);
        Database.insert(opportunities, true); //TODO: Change to false;
    }

    // @HttpPatch
    // global static void updateMobileOrder(){

    // }

    // @HttpDelete
    // global static void deleteMobileOrder(){

    // }
}