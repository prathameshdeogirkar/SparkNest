System.schedule(
    'Close Stale Enquiries Nightly',
    '0 0 2 * * ?',
    new CloseStaleEnquiriesScheduler()
);