
@IsTest
private class CloseStaleEnquiriesSchedulerTest {

    @IsTest
    static void testSchedulerExecutesBatch() {
        CloseStaleEnquiriesScheduler scheduler =
            new CloseStaleEnquiriesScheduler();

        Test.startTest();

        String jobId = System.schedule(
            'Test Close Stale Enquiries',
            '0 0 2 * * ?',
            scheduler
        );

        Test.stopTest();

        System.assertNotEquals(
            null,
            jobId,
            'The scheduler should return a scheduled job ID.'
        );

        CronTrigger scheduledJob = [
            SELECT Id, CronExpression, State
            FROM CronTrigger
            WHERE Id = :jobId
        ];

        System.assertEquals(
            '0 0 2 * * ?',
            scheduledJob.CronExpression,
            'The scheduler should use the requested CRON expression.'
        );
    }
}
