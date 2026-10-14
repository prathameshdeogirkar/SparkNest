String jobName = 'HelpdeskPro Nightly Resolution Milestone Summary';

List<CronTrigger> existingJobs = [
    SELECT Id, CronExpression, State
    FROM CronTrigger
    WHERE CronJobDetail.Name = :jobName
    AND State = 'WAITING'
    LIMIT 1
];

if (existingJobs.isEmpty()) {
    String cronExpression = '0 0 1 * * ?';

    Id jobId = System.schedule(
        jobName,
        cronExpression,
        new ResolutionMilestoneBreachSummary()
    );
=
    System.debug('Nightly job scheduled. Job ID: ' + jobId);
} else {
    System.debug(
        'The nightly job is already scheduled: ' +
        existingJobs[0].CronExpression
    );
}