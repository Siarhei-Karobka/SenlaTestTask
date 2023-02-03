public with sharing class TestHelper {
    public static final String TEST_OPP_NAME_NEW = 'Test Opp New ';
    public static final String TEST_OPP_NAME_EXIST = 'Test Opp Exist ';
    public static final String TEST_OPP_EMAIL = 'testoppemail@testopp.com';
    public static final Decimal TEST_OPP_AMOUNT = 11000;

    public static List<Opportunity> createTestOpportunities(Decimal numberOfTestOpps){
        List<Opportunity> opportunitiesForInsert = new List<Opportunity>();

        for (Integer i = 0; i < numberOfTestOpps; i++) {
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


    @future
    public static void insertFutureUser(String serializedUsers) {
        List<User> futureUser = (List<User>)JSON.deserialize(serializedUsers, List<User>.class);
        insert futureUser;
    }
}