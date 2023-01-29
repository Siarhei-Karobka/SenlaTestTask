@isTest
public with sharing class MobileRetailServiceTest {
    private static final String PATH = '/services/mobileOrders';
    private static final String TEST_OPP_NAME_NEW = 'Test Opp New ';
    private static final String TEST_OPP_NAME_EXIST = 'Test Opp Exist ';
    private static final String TEST_OPP_EMAIL = 'testoppemail@testopp.com';
    private static final Decimal TEST_OPP_AMOUNT = 1000;
    private static final Decimal NUMBER_OF_TEST_OPPORTUNITIES = 10;


    @isTest
    static void oppInsertTest(){
        List<Opportunity> testOpportunities = createTestOpportunities();
        String body = JSON.serialize(testOpportunities);

        RestRequest request = new RestRequest();
        request.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + PATH;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;

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

    private static List<Opportunity> createTestOpportunities(){
        List<Opportunity> opportunitiesForInsert = new List<Opportunity>();

        for (Integer i = 0; i < NUMBER_OF_TEST_OPPORTUNITIES; i++) {
            Opportunity testOpp = new Opportunity(
                Name = TEST_OPP_NAME_NEW + i,
                Email__c = TEST_OPP_EMAIL,
                RetailNumber__c = 'RN-110011' + i, //unique field
                Amount = TEST_OPP_AMOUNT,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30)
            );
            opportunitiesForInsert.add(testOpp);
        }
        return opportunitiesForInsert;
    }

    // @isTest
    // static void oppUpdateTest(){
        
    // }

    // @isTest
    // static void oppDeleteTest(){
        
    // }
}