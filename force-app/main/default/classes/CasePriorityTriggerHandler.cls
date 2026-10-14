public class CasePriorityTriggerHandler {

    public static void handleBeforeInsert(List<Case> cases) {

        for (Case caseRecord : cases) {

            if (caseRecord.Origin == 'Email') {
                caseRecord.Status = 'New';
                caseRecord.Priority = 'Normal';
            }
        }
    }
}