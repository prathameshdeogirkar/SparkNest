
@IsTest
private class EnquiryServiceTest {

    @IsTest
    static void testDefaultStatusAndFollowUpTask() {
        Enquiry__c enquiry = TestDataFactory.createEnquiry(
            'Monitor Enquiry',
            null,
            1500
        );

        Test.startTest();
        insert enquiry;
        Test.stopTest();

        Enquiry__c savedEnquiry = [
            SELECT Id, Status__c, OwnerId, Subject__c
            FROM Enquiry__c
            WHERE Id = :enquiry.Id
        ];

        System.assertEquals(
            'New',
            savedEnquiry.Status__c,
            'Blank Status should default to New.'
        );

        List<Task> tasks = [
            SELECT Id, Subject, OwnerId, WhatId, ActivityDate,
                   Status, Priority
            FROM Task
            WHERE WhatId = :enquiry.Id
        ];

        System.assertEquals(
            1,
            tasks.size(),
            'One follow-up Task should be created.'
        );
        System.assertEquals(
            'Follow up: Monitor Enquiry',
            tasks[0].Subject
        );
        System.assertEquals(savedEnquiry.OwnerId, tasks[0].OwnerId);
        System.assertEquals(enquiry.Id, tasks[0].WhatId);
        System.assertEquals(Date.today().addDays(3), tasks[0].ActivityDate);
        System.assertEquals('Not Started', tasks[0].Status);
        System.assertEquals('Normal', tasks[0].Priority);
    }

    @IsTest
    static void testBudgetBelowMinimumIsRejected() {
        Enquiry__c enquiry = TestDataFactory.createEnquiry(
            'Low Budget Enquiry',
            'New',
            999
        );

        Test.startTest();
        Database.SaveResult result = Database.insert(enquiry, false);
        Test.stopTest();

        System.assertEquals(
            false,
            result.isSuccess(),
            'An Enquiry with a budget below 1000 should be rejected.'
        );

        System.assert(
            result.getErrors()[0].getMessage().contains(
                'Customer budget must be at least'
            ),
            'The validation error should explain the minimum budget.'
        );
    }

    @IsTest
    static void testClosedDateIsSetWhenStatusChangesToClosed() {
        Enquiry__c enquiry = TestDataFactory.createEnquiry(
            'Close Date Test',
            'In Progress',
            2000
        );
        insert enquiry;

        Test.startTest();
        enquiry.Status__c = 'Closed';
        update enquiry;
        Test.stopTest();

        Enquiry__c savedEnquiry = [
            SELECT Status__c, Closed_Date__c
            FROM Enquiry__c
            WHERE Id = :enquiry.Id
        ];

        System.assertEquals('Closed', savedEnquiry.Status__c);
        System.assertEquals(
            Date.today(),
            savedEnquiry.Closed_Date__c,
            'Closed Date should be today when Status changes to Closed.'
        );
    }

    @IsTest
    static void testBulkInsertOf200Enquiries() {
        List<Enquiry__c> enquiries =
            TestDataFactory.createEnquiries(200);

        Test.startTest();
        insert enquiries;
        Test.stopTest();

        Set<Id> enquiryIds = new Map<Id, Enquiry__c>(enquiries).keySet();

        Integer enquiryCount = [
            SELECT COUNT()
            FROM Enquiry__c
            WHERE Id IN :enquiryIds
        ];

        Integer taskCount = [
            SELECT COUNT()
            FROM Task
            WHERE WhatId IN :enquiryIds
        ];

        System.assertEquals(
            200,
            enquiryCount,
            'All 200 Enquiries should be inserted.'
        );
        System.assertEquals(
            200,
            taskCount,
            'Each Enquiry should have one follow-up Task.'
        );
    }
}
