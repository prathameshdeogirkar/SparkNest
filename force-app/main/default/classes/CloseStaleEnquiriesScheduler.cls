
global class CloseStaleEnquiriesScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        CloseStaleEnquiriesBatch batchJob =
            new CloseStaleEnquiriesBatch();

        Database.executeBatch(batchJob, 200);
    }
}
