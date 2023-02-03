@isTest
public with sharing class MobileRetailServiceTest {
    private static final Decimal NUMBER_OF_TEST_OPPORTUNITIES = 100;

    @isTest
    static void oppInsertTest(){
        List<Opportunity> testOpportunities = TestHelper.createTestOpportunities(NUMBER_OF_TEST_OPPORTUNITIES);
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
            Assert.areEqual(TestHelper.TEST_OPP_EMAIL, opportunity.Email__c);
            Assert.areEqual(TestHelper.TEST_OPP_AMOUNT, opportunity.Amount);
        }
    }


    @isTest
    static void oppUpdateById(){
        List<Opportunity> testOpportunities = TestHelper.createTestOpportunities(NUMBER_OF_TEST_OPPORTUNITIES);
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
            Assert.areEqual(TestHelper.TEST_OPP_EMAIL, opportunity.Email__c);
            Assert.areEqual(2000, opportunity.Amount);
        }
    }

    @isTest
    static void oppUpdateByEmailANDRetailNumberTest(){
        List<Opportunity> testOpportunities = TestHelper.createTestOpportunities(NUMBER_OF_TEST_OPPORTUNITIES);
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
            Assert.areEqual(TestHelper.TEST_OPP_EMAIL, opportunity.Email__c);
            Assert.areEqual(2000, opportunity.Amount);
        }
    }

    @isTest
    static void oppDeleteByIdTest(){
        List<Opportunity> testOpportunities = TestHelper.createTestOpportunities(NUMBER_OF_TEST_OPPORTUNITIES);
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
        List<Opportunity> testOpportunities = TestHelper.createTestOpportunities(NUMBER_OF_TEST_OPPORTUNITIES);
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
        request.httpMethod = restMethod;
        request.requestBody = Blob.valueOf(requestBody);
        if (updateByEmailAndRetailNumber) {
            request.addParameter('EmailAndRN', 'true');
        }
        return request;
    }
}