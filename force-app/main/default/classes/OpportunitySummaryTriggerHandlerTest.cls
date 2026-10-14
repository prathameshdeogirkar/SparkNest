@isTest
public class OpportunitySummaryTriggerHandlerTest {

    @isTest
    static void testInsertAndUpdateSummary() {

        Account acc = new Account(
            Name = 'Summary Test Account'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Summary Test Opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 10000
        );

        Test.startTest();

        insert opp;

        Account updatedAccount = [
            SELECT Total_Opportunity_Count__c,
                   Total_Opportunity_Amount__c
            FROM Account
            WHERE Id = :acc.Id
        ];

        System.assertEquals(
            1,
            updatedAccount.Total_Opportunity_Count__c
        );

        System.assertEquals(
            10000,
            updatedAccount.Total_Opportunity_Amount__c
        );

        // Update Opportunity Amount
        opp.Amount = 25000;
        update opp;

        Test.stopTest();

        updatedAccount = [
            SELECT Total_Opportunity_Count__c,
                   Total_Opportunity_Amount__c
            FROM Account
            WHERE Id = :acc.Id
        ];

        System.assertEquals(
            1,
            updatedAccount.Total_Opportunity_Count__c
        );

        System.assertEquals(
            25000,
            updatedAccount.Total_Opportunity_Amount__c
        );
    }


    @isTest
    static void testDeleteOpportunitySummary() {

        Account acc = new Account(
            Name = 'Delete Summary Account'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Delete Summary Opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 15000
        );

        insert opp;

        Test.startTest();

        delete opp;

        Test.stopTest();

        Account updatedAccount = [
            SELECT Total_Opportunity_Count__c,
                   Total_Opportunity_Amount__c
            FROM Account
            WHERE Id = :acc.Id
        ];

        System.assertEquals(
            0,
            updatedAccount.Total_Opportunity_Count__c
        );

        System.assertEquals(
            0,
            updatedAccount.Total_Opportunity_Amount__c
        );
    }


    @isTest
    static void testOpportunityMovesBetweenAccounts() {

        Account accountA = new Account(
            Name = 'Account A'
        );

        Account accountB = new Account(
            Name = 'Account B'
        );

        insert new List<Account>{
            accountA,
            accountB
        };

        Opportunity opp = new Opportunity(
            Name = 'Moving Opportunity',
            AccountId = accountA.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 50000
        );

        insert opp;

        // Move Opportunity from Account A to Account B
        opp.AccountId = accountB.Id;

        Test.startTest();

        update opp;

        Test.stopTest();

        List<Account> accounts = [
            SELECT Id,
                   Total_Opportunity_Count__c,
                   Total_Opportunity_Amount__c
            FROM Account
            WHERE Id IN :new Set<Id>{
                accountA.Id,
                accountB.Id
            }
        ];

        Map<Id, Account> accountMap = new Map<Id, Account>(accounts);

        System.assertEquals(
            0,
            accountMap.get(accountA.Id).Total_Opportunity_Count__c
        );

        System.assertEquals(
            0,
            accountMap.get(accountA.Id).Total_Opportunity_Amount__c
        );

        System.assertEquals(
            1,
            accountMap.get(accountB.Id).Total_Opportunity_Count__c
        );

        System.assertEquals(
            50000,
            accountMap.get(accountB.Id).Total_Opportunity_Amount__c
        );
    }


    @isTest
    static void testBulk200Opportunities() {

        Account acc = new Account(
            Name = 'Bulk Summary Account'
        );

        insert acc;

        List<Opportunity> opportunities = new List<Opportunity>();

        for (Integer i = 0; i < 200; i++) {

            opportunities.add(
                new Opportunity(
                    Name = 'Bulk Opportunity ' + i,
                    AccountId = acc.Id,
                    StageName = 'Prospecting',
                    CloseDate = Date.today().addDays(30),
                    Amount = 1000
                )
            );
        }

        Test.startTest();

        insert opportunities;

        Test.stopTest();

        Account updatedAccount = [
            SELECT Total_Opportunity_Count__c,
                   Total_Opportunity_Amount__c
            FROM Account
            WHERE Id = :acc.Id
        ];

        System.assertEquals(
            200,
            updatedAccount.Total_Opportunity_Count__c
        );

        System.assertEquals(
            200000,
            updatedAccount.Total_Opportunity_Amount__c
        );
    }
}