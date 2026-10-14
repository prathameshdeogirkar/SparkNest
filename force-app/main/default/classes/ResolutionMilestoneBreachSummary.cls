global class ResolutionMilestoneBreachSummary implements Schedulable {

    // Sandbox stand-in for the Support Manager.
    // Replace this address if your assignment specifies another manager.
    private static final String SUPPORT_MANAGER_EMAIL =
        'prathamesh.deogirkar@myridius.com';

    global void execute(SchedulableContext context) {
        sendSummaryEmail();
    }

    public static void sendSummaryEmail() {
        Datetime currentTime = System.now();

        List<CaseMilestone> breachedMilestones = [
            SELECT Id, CaseId, Case.CaseNumber,
                   Case.Contact.Name, Case.Account.Name,
                   TargetDate
            FROM CaseMilestone
            WHERE IsViolated = true
              AND CompletionDate = null
              AND Case.IsClosed = false
              AND MilestoneType.Name = 'Close Case'
              AND TargetDate != null
            ORDER BY TargetDate ASC
        ];

        String emailBody =
            'HelpdeskPro - Nightly Resolution Milestone Breach Summary\n\n';

        if (breachedMilestones.isEmpty()) {
            emailBody += 'No open Cases have breached the Resolution milestone.';
        } else {
            for (CaseMilestone milestone : breachedMilestones) {
                String customerName = 'Unknown Customer';

                if (milestone.Case.Contact != null) {
                    customerName = milestone.Case.Contact.Name;
                } else if (milestone.Case.Account != null) {
                    customerName = milestone.Case.Account.Name;
                }

                Long overdueMilliseconds =
                    currentTime.getTime() -
                    milestone.TargetDate.getTime();

                Decimal overdueHours =
                    (Decimal.valueOf(
                        String.valueOf(overdueMilliseconds)
                    ) / 3600000).setScale(2);

                emailBody +=
                    'Case Number: ' + milestone.Case.CaseNumber + '\n' +
                    'Customer Name: ' + customerName + '\n' +
                    'Hours Overdue: ' + String.valueOf(overdueHours) + '\n' +
                    '----------------------------------------\n';
            }
        }

        Messaging.SingleEmailMessage email =
            new Messaging.SingleEmailMessage();

        email.setToAddresses(
            new List<String>{ SUPPORT_MANAGER_EMAIL }
        );
        email.setSubject(
            'Nightly Resolution Milestone Breach Summary'
        );
        email.setPlainTextBody(emailBody);
        email.setSaveAsActivity(false);

        Messaging.sendEmail(
            new Messaging.SingleEmailMessage[]{ email }
        );
    }
}