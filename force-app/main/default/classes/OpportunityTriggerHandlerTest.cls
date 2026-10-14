@isTest(SeeAllData=true)
public class OpportunityTriggerHandlerTest {

    // Positive scenario:
    // Non-Closed Won → Closed Won
    @isTest(SeeAllData=true)
static void testClosedWonAutomation() {

    Opportunity opp = [
        SELECT Id, StageName, CloseDate, Type, Account.Industry
        FROM Opportunity
        WHERE StageName != 'Closed Won'
        AND Account.Industry != null
        LIMIT 1
    ];

    Test.startTest();

    opp.StageName = 'Closed Won';
    update opp;

    Test.stopTest();

    Opportunity updatedOpp = [
        SELECT Id, StageName, CloseDate, Type
        FROM Opportunity
        WHERE Id = :opp.Id
    ];

    System.assertEquals(
        'Closed Won',
        updatedOpp.StageName,
        'Opportunity should be Closed Won'
    );

    System.assertEquals(
        Date.today(),
        updatedOpp.CloseDate,
        'Close Date should be Today'
    );

    System.assertEquals(
        'New Customer',
        updatedOpp.Type,
        'Type should be New Customer'
    );
}


    // Negative scenario:
    // Opportunity is already Closed Won.
    @isTest(SeeAllData=true)
static void testAlreadyClosedWon() {

    Opportunity opp = [
        SELECT Id, StageName, CloseDate, Type, NextStep
        FROM Opportunity
        WHERE StageName = 'Closed Won'
        LIMIT 1
    ];

    Date originalCloseDate = opp.CloseDate;
    String originalType = opp.Type;

    Test.startTest();

    // Stage remains Closed Won.
    // Only update another field.
    opp.NextStep = 'Negative Test';
    update opp;

    Test.stopTest();

    Opportunity updatedOpp = [
        SELECT Id, StageName, CloseDate, Type, NextStep
        FROM Opportunity
        WHERE Id = :opp.Id
    ];

    System.assertEquals(
        'Closed Won',
        updatedOpp.StageName,
        'Stage should remain Closed Won'
    );

    System.assertEquals(
        originalCloseDate,
        updatedOpp.CloseDate,
        'Close Date should not be changed'
    );

    System.assertEquals(
        originalType,
        updatedOpp.Type,
        'Type should not be changed'
    );

    System.assertEquals(
        'Negative Test',
        updatedOpp.NextStep,
        'Other field should be updated'
    );
}


    // Bulk scenario:
    // Test with 200 Opportunities.
@isTest
static void testBulkClosedWonAutomation() {

    List<Opportunity> opportunities = new List<Opportunity>();

    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>();
    Map<Id, Opportunity> newMap = new Map<Id, Opportunity>();

    for (Integer i = 0; i < 200; i++) {

        // Create a unique fake Opportunity Id for testing.
        Id fakeId = Id.valueOf(
            '006' + String.valueOf(i).leftPad(12, '0')
        );

        Opportunity oldOpp = new Opportunity(
            Id = fakeId,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Type = 'Existing Customer - Upgrade'
        );

        Opportunity newOpp = new Opportunity(
            Id = fakeId,
            StageName = 'Closed Won',
            CloseDate = Date.today().addDays(30),
            Type = 'Existing Customer - Upgrade'
        );

        opportunities.add(newOpp);

        oldMap.put(fakeId, oldOpp);
        newMap.put(fakeId, newOpp);
    }

    Test.startTest();

    OpportunityTriggerHandler.handleBeforeUpdate(
        opportunities,
        oldMap,
        newMap
    );

    Test.stopTest();

    System.assertEquals(
        200,
        opportunities.size(),
        'Exactly 200 Opportunities should be processed'
    );

    for (Opportunity opp : opportunities) {

        System.assertEquals(
            'Closed Won',
            opp.StageName,
            'Opportunity should be Closed Won'
        );

        System.assertEquals(
            Date.today(),
            opp.CloseDate,
            'Close Date should be Today'
        );

        System.assertEquals(
            'New Customer',
            opp.Type,
            'Type should be New Customer'
        );
    }
}
}