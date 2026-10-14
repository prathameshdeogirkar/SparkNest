public class MilestoneUtils {

    public static void completeMilestone(
        List<Id> caseIds,
        String milestoneName,
        Datetime completionDate
    ) {
        if (caseIds == null || caseIds.isEmpty()) {
            return;
        }

        List<CaseMilestone> milestones = [
            SELECT Id, CompletionDate
            FROM CaseMilestone
            WHERE CaseId IN :caseIds
            AND MilestoneType.Name = :milestoneName
            AND CompletionDate = null
        ];

        for (CaseMilestone milestone : milestones) {
            milestone.CompletionDate = completionDate;
        }

        if (!milestones.isEmpty()) {
            Database.update(milestones, AccessLevel.SYSTEM_MODE);
        }
    }
}