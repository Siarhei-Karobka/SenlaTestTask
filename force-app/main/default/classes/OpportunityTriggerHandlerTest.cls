@isTest
public with sharing class OpportunityTriggerHandlerTest {
    private static final Decimal NUMBER_OF_TEST_OPPORTUNITIES = 10;

    @TestSetup
    static void makeData(){
        String chiefRoleId = [SELECT Id FROM UserRole WHERE Name = 'Chief Manager'].Id;

        List<User> users = new List<User>();
        User chiefManager = createUser('chiefManager@test.test', 'cManager');
        chiefManager.UserRoleId = chiefRoleId;
        users.add(chiefManager);
        User employee = createUser('employee@test.test', 'employee');
        users.add(employee);

        TestHelper.insertFutureUser(JSON.serialize(users));
    }

    private static User createUser(String email, String fName){
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User'];
        User testUser = new User(
            Alias = fName,
            Username = email + '.' + fName,
            Email = email,
            FirstName = fName,
            LastName = fName,
            LocaleSidKey = 'en_IE_EURO',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'Europe/Dublin',
            ProfileId = profile.Id
        );
        return testUser;
    }

    @isTest
    static void shareAccessToChiefManagerTest(){
        User employee = [SELECT Id FROM User WHERE Email = 'employee@test.test'];
        User chiefManager = [SELECT Id, Email FROM User WHERE Email = 'chiefManager@test.test'];

        System.runAs(employee) {
            List<Opportunity> testOpps = TestHelper.createTestOpportunities(NUMBER_OF_TEST_OPPORTUNITIES);
            insert testOpps;

            Map<Id, Opportunity> testOpportunities = new Map<Id, Opportunity>([SELECT Id FROM Opportunity]);
            for (Opportunity opp : testOpportunities.values()) {
                opp.StageName = 'Needs Analysis';
            }

            Test.startTest();
            update testOpportunities.values();
            Test.stopTest();

            List<OpportunityShare> oppShareRecords = [SELECT OpportunityId, UserOrGroupId
                                                        FROM OpportunityShare
                                                        WHERE OpportunityId IN: testOpportunities.keySet()
                                                        AND UserOrGroupId =: chiefManager.Id];

            Assert.areEqual(NUMBER_OF_TEST_OPPORTUNITIES, oppShareRecords.size(), 'Opportunity Share records wasn\'t created');
        }
    }

    // // Cannot be tested
    // @isTest
    // static void sendBellNotificationToManagerTest(){}
}