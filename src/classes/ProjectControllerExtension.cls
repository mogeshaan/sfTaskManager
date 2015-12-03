global with sharing class ProjectControllerExtension {
    private final Project__c project;
    private ApexPages.StandardController stdController;
    public String taskListString{get;set;}
    public String domId{get;set;}
    public String errorMessage{get;set;}
    public Boolean skipHoliday{get;set;}
    private static Integer calLength = 2;

    /**
     * Constructor
     * @param ApexPages.StandardController stdController
     */
    public ProjectControllerExtension(ApexPages.StandardController stdController) {
        this.project = (Project__c)stdController.getRecord();
        this.stdController = stdController;

        // タスクの取得
        this.taskListString = this.getJSONTasks(this.project.id);

        // DOM用のID取得
        CommonUtil cu = new CommonUtil();
        this.domId = cu.domId;

        // 休日スキップチェック取得
        this.skipHoliday = this.project.SkipHoliday__c;

    }

    /**
     * Task__c getter,setter
     */
    public Task__c tsk {
        get {
            if (tsk == null) {
                tsk = new Task__c();
            }
            return tsk;
        }
        set;
    }

    /**
     * エラーメッセージの修正
     * @return void
     */
    private void remakeErrorMessage() {
      if (errorMessage.length() == 0) {return;}
      String dateMess = 'Cannot deserialize instance of date from VALUE_STRING value';
      if (errorMessage.contains(dateMess) && (errorMessage.substring(dateMess.length()+1, errorMessage.length())).length() > 4) {
        errorMessage = '不正な日付です。 [' + errorMessage.substring(dateMess.length()+1, errorMessage.length()) + ']';
        return;
      }
      return;
    }

    /**
     * タスクデータの登録
     * @return Boolean
     */
    private Boolean saveAction() {
        errorMessage = '';
        Savepoint sp = null;
        try {
            // 全消し用ID取得
            List<Task__c> taskIdList = [
                SELECT id FROM Task__c WHERE Project__c = :this.project.id
            ];

            // 全入れ
            List<Task__c> newTaskList = (List<Task__c>)json.deserialize(taskListString, List<Task__c>.class);

            sp = Database.setSavepoint();
            for (Task__c tc : newTaskList) {
                tc.Project__c = this.project.id;
                insert tc;
            }

            // 全消し
            delete taskIdList;

            return true;
        } catch(System.Exception ex) {
            Database.rollback(sp);  // エラーは全件取り消し
            errorMessage = ex.getMessage();
            remakeErrorMessage();
            return false;
        }
    }

    /**
     * save
     * @return PageReference
     */
    public PageReference save() {
        if (this.saveAction()) {
            return new ApexPages.StandardController(project).view();
        } else {
            return null;
        }
    }

    /**
     * quicksave
     * @return void
     */
    public void quicksave() {
        Boolean res = this.saveAction();
    }

    /**
     * タスクのデータをJSONで取得する
     * @param  String projectId
     * @return String JSON of Task
     */
    public String getJSONTasks(String projectId){
        if (String.isBlank(projectId)) {
            return null;
        }
        // タスクを取得
        List<String> idList = new List<String>();
        idList.add(projectId);
        List<Task__c> s = [
            SELECT
                Id,
                Name,
                StartDate__c,
                StartDateSchedule__c,
                EndDate__c,
                EndDateSchedule__c,
                TaskNumber__c,
                ParentTask__c,
                PersonInCharge__c,
                Remarks__c
            FROM
                Task__c
            WHERE
                Project__c IN :idList
            ORDER By
              TaskNumber__c
        ];

        String tasks = JSON.serialize(s);
        //system.debug(tasks);
        return tasks;
    }

    @RemoteAction
    global static List<Holiday__c> loadHoliday() {
      Date pDate = Date.today();
      Date startDate = Date.newinstance(pDate.year(), pDate.month(), 1);
      Date endDate = startDate.addMonths(2);
      String qp = 'SELECT Id, Name, ymd__c FROM Holiday__c WHERE ymd__c >= String.valueOf(startDate) AND ymd__c < String.valueOf(endDate)';
      List<Holiday__c> lh = Database.query(qp);
      return lh;
    }

}