@isTest
public with sharing class MobileRetailServiceTest {
    private static final String PATH = '/services/mobileOrders';
    private static final String TEST_OPP_NAME_NEW = 'Test Opp New ';
    private static final String TEST_OPP_NAME_EXIST = 'Test Opp Exist ';
    private static final String TEST_OPP_EMAIL = 'testoppemail@testopp.com';
    private static final Decimal TEST_OPP_AMOUNT = 1000;
    private static final Decimal NUMBER_OF_TEST_OPPORTUNITIES = 1;

    @isTest
    static void oppInsertTest(){
        List<Opportunity> testOpportunities = createTestOpportunities();
        String requestBody = JSON.serialize(testOpportunities);

        RestContext.request = prepareRestContext('POST', true, requestBody);

        MobileRetailService.insertMobileOrder();

        List<Opportunity> thisOpportunities = [SELECT Id,
                                                    Name,
                                                    Email__c,
                                                    Amount,
                                                    RetailNumber__c
                                                FROM Opportunity];

        Assert.areEqual(NUMBER_OF_TEST_OPPORTUNITIES, thisOpportunities.size());
        for (Opportunity opportunity : thisOpportunities) {
            Assert.areEqual(TEST_OPP_EMAIL, opportunity.Email__c);
            Assert.areEqual(TEST_OPP_AMOUNT, opportunity.Amount);
        }
    }


    @isTest
    static void oppUpdateById(){
        List<Opportunity> testOpportunities = createTestOpportunities();
        insert testOpportunities;

        for (Opportunity opportunity : testOpportunities) {
            opportunity.Amount = 2000;
        }
        String requestBody = JSON.serialize(testOpportunities);

        RestContext.request = prepareRestContext('PATCH', false, requestBody);
        MobileRetailService.updateMobileOrder();

        List<Opportunity> thisOpportunities = [SELECT Id,
                                                    Name,
                                                    Email__c,
                                                    Amount,
                                                    RetailNumber__c
                                                FROM Opportunity];

        Assert.areEqual(NUMBER_OF_TEST_OPPORTUNITIES, thisOpportunities.size());
        for (Opportunity opportunity : thisOpportunities) {
            Assert.areEqual(TEST_OPP_EMAIL, opportunity.Email__c);
            Assert.areEqual(2000, opportunity.Amount);
        }
    }

    @isTest
    static void oppUpdateByEmailANDRetailNumberTest(){
        List<Opportunity> testOpportunities = createTestOpportunities();
        insert testOpportunities;

        for (Opportunity opportunity : testOpportunities) {
            opportunity.Amount = 2000;
        }
        String requestBody = JSON.serialize(testOpportunities);

        RestContext.request = prepareRestContext('PATCH', true, requestBody);
        MobileRetailService.updateMobileOrder();

        List<Opportunity> thisOpportunities = [SELECT Id,
                                                    Name,
                                                    Email__c,
                                                    Amount,
                                                    RetailNumber__c
                                                FROM Opportunity];

        Assert.areEqual(NUMBER_OF_TEST_OPPORTUNITIES, thisOpportunities.size());
        for (Opportunity opportunity : thisOpportunities) {
            Assert.areEqual(TEST_OPP_EMAIL, opportunity.Email__c);
            Assert.areEqual(2000, opportunity.Amount);
        }
    }

    @isTest
    static void oppDeleteByIdTest(){
        List<Opportunity> testOpportunities = createTestOpportunities();
        insert testOpportunities;

        for (Opportunity opportunity : testOpportunities) {
            opportunity.Amount = 2000;
        }
        String requestBody = JSON.serialize(testOpportunities);

        RestContext.request = prepareRestContext('DELETE', false, requestBody);
        MobileRetailService.deleteMobileOrder();

        List<Opportunity> thisOpportunities = [SELECT Id,
                                                    Name,
                                                    Email__c,
                                                    Amount,
                                                    RetailNumber__c
                                                FROM Opportunity];

        Assert.areEqual(0, thisOpportunities.size());
    }

    @isTest
    static void oppDeleteByEmailANDRetailNumberTest(){
        List<Opportunity> testOpportunities = createTestOpportunities();
        insert testOpportunities;

        for (Opportunity opportunity : testOpportunities) {
            opportunity.Amount = 2000;
        }
        String requestBody = JSON.serialize(testOpportunities);

        RestContext.request = prepareRestContext('DELETE', true, requestBody);
        MobileRetailService.deleteMobileOrder();

        List<Opportunity> thisOpportunities = [SELECT Id,
                                                    Name,
                                                    Email__c,
                                                    Amount,
                                                    RetailNumber__c
                                                FROM Opportunity];

        Assert.areEqual(0, thisOpportunities.size());
    }







    private static RestRequest prepareRestContext(String restMethod, Boolean updateByEmailAndRetailNumber, String requestBody){
        RestRequest request = new RestRequest();
        request.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + PATH;
        request.httpMethod = restMethod;
        request.requestBody = Blob.valueOf(requestBody);
        if (updateByEmailAndRetailNumber) {
            request.addParameter('EmailAndRN', 'true');
        }
        return request;
    }

    private static List<Opportunity> createTestOpportunities(){
        List<Opportunity> opportunitiesForInsert = new List<Opportunity>();

        for (Integer i = 0; i < NUMBER_OF_TEST_OPPORTUNITIES; i++) {
            Opportunity testOpp = new Opportunity(
                Name = TEST_OPP_NAME_NEW + i,
                Email__c = TEST_OPP_EMAIL,
                RetailNumber__c = 'RN-00' + i,
                Amount = TEST_OPP_AMOUNT,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30)
            );
            opportunitiesForInsert.add(testOpp);
        }
        return opportunitiesForInsert;
    }

}