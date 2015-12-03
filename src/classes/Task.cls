global with sharing class Task {
  public String errorMessage{ get; set; }
  public String noticeMessage{ get; set; }
  public Project__c project{ get; set; }
  public String domId;
  public List<Task__c> tasks{ set; }
  public String pid;
  public String taskListString { get;set; }
  public String condAllKana { get;set; }
  private final static String COND_ALL = 'ALL';
  private final static String COND_ALL_KANA = '--すべて--';
  private final static String COLUMN_COMPANY = 'COMP';
  private final static String COLUMN_DEPARTMENT = 'DEPT';
  private final static String NULL_COMPANY = '--会社未設定--';
  private final static String NULL_DEPARTMENT = '--部署未設定--';

  /**
   * コンストラクタ
   */
  public Task() {
    // プロジェクトのIDをセット
    this.pid = ApexPages.CurrentPage().getParameters().get('projectid');
    if(this.pid == null || this.pid.length() == 0){
      return;
    }
    // プロジェクトの取得
    this.project = [SELECT Id, Name, StartDate__c, SkipHoliday__c, EndDate__c, ProjectOwnerUser__c, PersonInCharge__c FROM Project__c WHERE Id = :this.pid];
    // タスクのJSONを取得
    List<Task__c> lt = this.getTasks();
    this.taskListString = JSON.serialize(lt);
    //this.noticeMessage = this.taskListString;
    // すべての文字列
    this.condAllKana = COND_ALL_KANA;
  }

  /**
   * タスク取得
   * @return List<Task__c>
   */
  public List<Task__c> getTasks() {
    if (this.pid == null || this.pid.length() == 0) {
        return null;
    }
    // タスクを取得
    List<Task__c> lt = [
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
            Remarks__c,
            TaskUser__c
        FROM
            Task__c
        WHERE
            Project__c = :this.pid
        ORDER By
          TaskNumber__c
    ];
    //system.debug(lt);
    return lt;
  }

  /**
   * 保存
   * @return PageReference
   */
  public PageReference save() {
      if (this.saveAction()) {
          return (new ApexPages.StandardController(this.project)).view();
      }
      return null;
  }

  /**
   * 適用
   * @return void
   */
  public void quicksave() {
      this.saveAction();
      return;
  }

  /**
   * [cancel description]
   * @return {[type]} [description]
   */
  public PageReference cancel() {
      return null;
  }

  /**
   * タスクデータの登録
   * @return Boolean
   */
  private Boolean saveAction() {
      errorMessage = '';
      Savepoint sp = null;
      if (this.pid == null || this.pid.length() == 0) {
        noticeMessage = 'pidが空でした';
        return null;
      }
      try {
          // 全消し用ID取得
          List<Task__c> taskIdList = [
              SELECT id FROM Task__c WHERE Project__c = :this.pid
          ];

          // 全入れ
          List<Task__c> newTaskList = (List<Task__c>)json.deserialize(taskListString, List<Task__c>.class);

          sp = Database.setSavepoint();
          for (Task__c tc : newTaskList) {
              tc.Project__c = this.pid;
              insert tc;
          }

          // 全消し
          delete taskIdList;

          return true;
      } catch(System.Exception ex) {
          if (sp != null) {Database.rollback(sp);}  // エラーは全件取り消し
          errorMessage = ex.getMessage();
          return false;
      }
  }

  @RemoteAction
  /**
   * 休日取得
   * @param  String  pStartMonth
   * @return List<Holiday__c>
   */
  global static List<Holiday__c> getHoliday(String pStartMonth) {
    Date startDate = Date.valueOf(pStartMonth);
    Date endDate = startDate.addMonths(2);
    return [SELECT Id, Name, ymd__c FROM Holiday__c WHERE ymd__c >= :startDate AND ymd__c < :endDate];
  }

  @RemoteAction
  /**
   * ユーザ取得(部署条件付き)
   * @param  String pDept
   * @return List<User>
   */
  global static List<User> getUser() {
    return getUserByDept(COND_ALL);
  }

  @RemoteAction
  /**
   * ユーザ取得
   * @param  String pDept
   * @return List<User>
   */
  global static List<User> getUserByDept(String pDept) {
    List<User> lu = new List<User>();
    String comp = null;
    String dept = null;

    if (pDept.equals(COND_ALL)) {
      lu = [SELECT Id, Name, Department, Profile.Name FROM User];
    } else {
      Map<String, String> m = getSplitName(pDept);
      comp = m.get(COLUMN_COMPANY).equals(NULL_COMPANY)? null : m.get(COLUMN_COMPANY);
      dept = m.get(COLUMN_DEPARTMENT).equals(NULL_DEPARTMENT)? null : m.get(COLUMN_DEPARTMENT);
      if (m.get(COLUMN_COMPANY).equals(COND_ALL_KANA)) {
      // 会社がすべての場合（自動的に部署もすべて）
        lu = [SELECT Id, Name, Department, Profile.Name FROM User];
      } else if (m.get(COLUMN_DEPARTMENT).equals(COND_ALL_KANA)) {
      // 会社の指定があり、部署がすべての場合
        lu = [SELECT Id, Name, Department, Profile.Name FROM User WHERE CompanyName = :comp];
      } else {
      // 会社部署ともに指定されている場合
        lu = [SELECT Id, Name, Department, Profile.Name FROM User WHERE CompanyName = :comp AND Department = :dept];
      }
    }
    return lu;
  }

  /**
   * 結合された会社名と部署からそれぞれの文字列を取り出す
   * @param  String pConcatName
   * @return Map<String, String>
   */
  private static Map<String, String> getSplitName(String pConcatName) {
    if (pConcatName == null || pConcatName.length() == 0) {return null;}
    Map<String, String> m = new Map<String, String>();
    if (pConcatName.equals(COND_ALL_KANA)) {
      m.put(COLUMN_COMPANY, null);
      m.put(COLUMN_DEPARTMENT, null);
    } else {
      String[] ls = pConcatName.split(':');
      m.put(COLUMN_COMPANY, ls[0]);
      m.put(COLUMN_DEPARTMENT, ls[1]);
      System.debug(m);
    }
    return m;
  }

  @RemoteAction
  /**
   * 会社取得
   * @return List<String> 会社名リスト
   */
  global static List<String> getCompanyName() {
    List<User> ld = [SELECT CompanyName FROM User ORDER BY CompanyName];
    List<String> ls = new List<String>();
    String prevVal = 'DummyValue';
    String nowVal = null;
    for (User u : ld) {
      nowVal = u.CompanyName == null? NULL_COMPANY : u.CompanyName;
      if (!prevVal.equals(nowVal)) {
        ls.add(nowVal);
      }
      prevVal = nowVal;
    }
    return ls;
  }

  @RemoteAction
  /**
   * 部署取得
   * @return List<User>
   */
  global static List<User> getDepartment() {
    List<User> ld = [SELECT CompanyName, Department FROM User ORDER BY CompanyName, Department];
    List<User> lu = new List<User>();
    String prevValComp = 'DummyValue';
    String prevValDept = 'DummyValue';
    for (User u : ld) {
      u.CompanyName = u.CompanyName == null? NULL_COMPANY : u.CompanyName;
      u.Department = u.Department == null? NULL_DEPARTMENT : u.Department;
      if (!prevValComp.equals(u.CompanyName) || !prevValDept.equals(u.Department)) {
        lu.add(u);
      }
      prevValComp = u.CompanyName;
      prevValDept = u.Department;
    }
    return lu;
  }
}