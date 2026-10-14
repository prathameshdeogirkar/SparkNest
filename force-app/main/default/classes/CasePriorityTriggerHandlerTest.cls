@isTest
public class CasePriorityTriggerHandlerTest {

    @isTest
    static void testEmailCasePriorityAutomation() {

        Case caseRecord = new Case(
            Subject = 'Email Case Test',
            Origin = 'Email',
            Status = 'Working',
            Priority = 'High'
        );

        Test.startTest();
        insert caseRecord;
        Test.stopTest();

        Case insertedCase = [
            SELECT Origin, Status, Priority
            FROM Case
            WHERE Id = :caseRecord.Id
        ];

        System.assertEquals(
            'Email',
            insertedCase.Origin
        );

        System.assertEquals(
            'New',
            insertedCase.Status
        );

        System.assertEquals(
            'Normal',
            insertedCase.Priority
        );
    }


    @isTest
    static void testNonEmailCaseRemainsUnchanged() {

        Case caseRecord = new Case(
            Subject = 'Web Case Test',
            Origin = 'Web',
            Status = 'Working',
            Priority = 'High'
        );

        Test.startTest();
        insert caseRecord;
        Test.stopTest();

        Case insertedCase = [
            SELECT Origin, Status, Priority
            FROM Case
            WHERE Id = :caseRecord.Id
        ];

        System.assertEquals(
            'Web',
            insertedCase.Origin
        );

        System.assertEquals(
            'Working',
            insertedCase.Status
        );

        System.assertEquals(
            'High',
            insertedCase.Priority
        );
    }


    @isTest
    static void testBulk200EmailCases() {

        List<Case> cases = new List<Case>();

        for (Integer i = 0; i < 200; i++) {

            cases.add(
                new Case(
                    Subject = 'Bulk Email Case ' + i,
                    Origin = 'Email',
                    Status = 'Working',
                    Priority = 'High'
                )
            );
        }

        Test.startTest();
        insert cases;
        Test.stopTest();

        List<Case> insertedCases = [
            SELECT Origin, Status, Priority
            FROM Case
            WHERE Id IN :cases
        ];

        System.assertEquals(
            200,
            insertedCases.size(),
            'All 200 Cases should be inserted'
        );

        for (Case caseRecord : insertedCases) {

            System.assertEquals(
                'Email',
                caseRecord.Origin
            );

            System.assertEquals(
                'New',
                caseRecord.Status
            );

            System.assertEquals(
                'Normal',
                caseRecord.Priority
            );
        }
    }
}