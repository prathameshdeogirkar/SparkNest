trigger AccountTrigger on Account (before delete, before insert, before update) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            AccountTriggerHandler.handleBeforeInsertUpdate(Trigger.new);
        }

        if (Trigger.isDelete) {
            AccountTriggerHandler.handleBeforeDelete(Trigger.old);
        }
    }

   

}