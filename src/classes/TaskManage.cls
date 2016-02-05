global with sharing class TaskManage {
  public String errorMessage{ get; set; }
  public String noticeMessage{ get; set; }
  public Project__c project{ get; set; }
  public String domId;
  public List<Tasklist__c> Tasklists{ set; }
  public ID pid;
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
  public TaskManage() {
    // プロジェクトのIDをセット
    this.pid = ApexPages.CurrentPage().getParameters().get('projectid');
    if(String.isEmpty(this.pid)){
      return;
    }
    // プロジェクトの取得
    this.project = [SELECT Id, Name, StartDate__c, SkipHoliday__c, EndDate__c, ProjectOwnerUser__c, PersonInCharge__c FROM Project__c WHERE Id = :this.pid];
    // タスクのJSONを取得
    List<Tasklist__c> lt = this.getTaskLists();
    this.taskListString = JSON.serialize(lt);
    // すべての文字列
    this.condAllKana = COND_ALL_KANA;
  }

  /**
   * タスク取得
   * @return List<Tasklist__c>
   */
  public List<Tasklist__c> getTaskLists() {
    if (String.isEmpty(this.pid)) {
        return null;
    }
    // タスクを取得
    List<Tasklist__c> lt = [
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
            TaskUser__c,
            Project__c
        FROM
            Tasklist__c
        WHERE
            Project__c = :this.pid
        ORDER By
          TaskNumber__c
    ];
    return lt;
  }

  /**
   * 保存
   * @return PageReference
   */
  public PageReference save() {
      this.errorMessage = null;
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
      this.errorMessage = null;
      this.saveAction();
      return;
  }

  /**
   * キャンセル
   * @return {[type]} [description]
   */
  public PageReference cancel() {
      this.errorMessage = null;
      return (new ApexPages.StandardController(this.project)).view();
  }

  /**
   * 日付のフォーマットチェック
   * @param  String pDateString
   * @return Boolean
   */
  private Boolean checkDateFormat(String pDateString) {
    if (pDateString == null) {return true;}
    try {
      Date d = Date.valueOf(pDateString);
    } catch(System.Exception ex) {
      return false;
    }
    return true;
  }

  /**
   * レコードチェック
   * @param  List<Map<String, String>>      pPostedRecord
   * @return List<Tasklist__c>
   */
  private List<Tasklist__c> checkPostedRecord(List<Map<String, String>> pPostedRecord) {
    List<Tasklist__c> lt = new List<Tasklist__c>(); // 新しいタスクリスト
    List<TaskList__c> oldLt = this.getTaskLists();  // 現状のタスクリスト
    CheckRecordException cre = new CheckRecordException();
    Integer recNum = 0;
    Boolean hasError = false;
    String errMessNull = '値をセットして下さい。 ';
    String errMessFormat = '不正な日付です。 ';
    String dummyString = 'Dummy';
    Date dummyDate = Date.today();

    for (Map<String, String> rec : pPostedRecord) {
      Tasklist__c tc = new Tasklist__c();
      // 既存のレコードがあればそれを基にする
      if (String.isNotEmpty(rec.get('Id'))) {
        for (TaskList__c oldT : oldLt) {
          if (rec.get('Id') == oldT.Id) {
            tc = oldT;
          }
        }
      }

      // チェック
      // タスク名
      if (rec.get('Name') == null || rec.get('Name').length() == 0) {
        // 必須
        cre.setMessageList(recNum, '[' + Schema.SObjectType.Tasklist__c.fields.Name.label + ']', errMessNull);
        tc.Name = dummyString;
        hasError = true;
      } else {
        tc.Name = rec.get('Name');
      }
      // 担当者
      if (rec.get('PersonInCharge__c') == null || rec.get('PersonInCharge__c').length() == 0) {
        // 必須
        cre.setMessageList(recNum, '[' + Schema.SObjectType.Tasklist__c.fields.PersonInCharge__c.label + ']', errMessNull);
        tc.PersonInCharge__c = dummyString;
        hasError = true;
      } else {
        tc.PersonInCharge__c = rec.get('PersonInCharge__c');
      }
      // 開始予定日
      if (rec.get('StartDateSchedule__c') == null || rec.get('StartDateSchedule__c').length() == 0) {
        // 必須
        cre.setMessageList(recNum, '[' + Schema.SObjectType.Tasklist__c.fields.StartDateSchedule__c.label + ']', errMessNull);
        tc.StartDateSchedule__c = dummyDate;
        hasError = true;
      } else if (!checkDateFormat(rec.get('StartDateSchedule__c'))) {
        // 書式
        cre.setMessageList(recNum, '[' + Schema.SObjectType.Tasklist__c.fields.StartDateSchedule__c.label + ']', errMessFormat + '"' + rec.get('StartDateSchedule__c') + '" ');
        tc.StartDateSchedule__c = dummyDate;
        hasError = true;
      } else {
        tc.StartDateSchedule__c = Date.valueOf(rec.get('StartDateSchedule__c'));
      }
      // 終了予定日
      if (rec.get('EndDateSchedule__c') == null || rec.get('EndDateSchedule__c').length() == 0) {
        // 必須
        cre.setMessageList(recNum, '[' + Schema.SObjectType.Tasklist__c.fields.EndDateSchedule__c.label + ']', errMessNull);
        tc.EndDateSchedule__c = dummyDate;
        hasError = true;
      } else if (!checkDateFormat(rec.get('EndDateSchedule__c'))) {
        // 書式
        cre.setMessageList(recNum, '[' + Schema.SObjectType.Tasklist__c.fields.EndDateSchedule__c.label + ']', errMessFormat + '"' + rec.get('EndDateSchedule__c') + '" ');
        tc.EndDateSchedule__c = dummyDate;
        hasError = true;
      } else {
        tc.EndDateSchedule__c = Date.valueOf(rec.get('EndDateSchedule__c'));
      }
      // 開始日
      if (rec.get('StartDate__c') != null) {
        if (!checkDateFormat(rec.get('StartDate__c'))) {
          // 書式
          cre.setMessageList(recNum, '[' + Schema.SObjectType.Tasklist__c.fields.StartDate__c.label + ']', errMessFormat + '"' + rec.get('StartDate__c') + '" ');
          tc.StartDate__c = dummyDate;
          hasError = true;
        } else {
          tc.StartDate__c = Date.valueOf(rec.get('StartDate__c'));
        }
      }
      // 終了日
      if (rec.get('EndDate__c') != null) {
        if (!checkDateFormat(rec.get('EndDate__c'))) {
          // 書式
          cre.setMessageList(recNum, '[' + Schema.SObjectType.Tasklist__c.fields.EndDate__c.label + ']', errMessFormat + '"' + rec.get('EndDate__c') + '" ');
          tc.EndDate__c = dummyDate;
          hasError = true;
        } else {
          tc.EndDate__c = Date.valueOf(rec.get('EndDate__c'));
        }
      }

      // 順序
      tc.TaskNumber__c = Integer.valueOf(rec.get('TaskNumber__c'));

      // ユーザ
      if (rec.get('TaskUser__c') != null) {
        tc.TaskUser__c = rec.get('TaskUser__c');
      }

      // プロジェクト
      if (String.isEmpty(tc.id)) {
        tc.Project__c = this.pid;
      }

      lt.add(tc);
      recNum++;
    }
    // エラーが有ったら例外をスローする
    if (hasError) {
      throw cre;
    }
    return lt;
  }

  /**
   * タスクデータの登録
   * @return Boolean
   */
  private Boolean saveAction() {
      errorMessage = '';
      Savepoint sp = null;
      if (String.isEmpty(this.pid)) {
        noticeMessage = 'pidが空でした';
        return null;
      }
      try {
          // チェック
          List<Map<String, String>> tr = (List<Map<String, String>>)json.deserialize(taskListString, List<Map<String, String>>.class);
          List<Tasklist__c> newTaskList = this.checkPostedRecord(tr);

          // 既存IDで新規リストにないものは削除する
          List<ID> newTaskId = new List<ID>();
          for (Tasklist__c nt : newTaskList) {
            newTaskId.add(nt.id);
          }
          List<Tasklist__c> delTaskId = [SELECT id FROM Tasklist__c WHERE Project__c = :this.pid AND id NOT IN :newTaskId];

          // チェックポイント
          sp = Database.setSavepoint();

          // 全入れ
          upsert newTaskList;

          // 全消し
          delete delTaskId;

          // リストの内容を入れ替え
          List<Tasklist__c> lt = this.getTaskLists();
          this.taskListString = JSON.serialize(lt);

          return true;
      } catch (CheckRecordException cre) {
          if (sp != null) {Database.rollback(sp);}  // エラーは全件取り消し
          errorMessage = cre.errorMessage;
          return false;
      } catch (System.Exception ex) {
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
  public static Map<String, String> getSplitName(String pConcatName) {
    if (String.isEmpty(pConcatName)) {return null;}
    Map<String, String> m = new Map<String, String>();
    if (pConcatName.equals(COND_ALL_KANA)) {
      m.put(COLUMN_COMPANY, null);
      m.put(COLUMN_DEPARTMENT, null);
    } else {
      String[] ls = pConcatName.split(':');
      m.put(COLUMN_COMPANY, ls[0]);
      m.put(COLUMN_DEPARTMENT, ls[1]);
    }
    return m;
  }

  @RemoteAction
  /**
   * 会社取得
   * Usersから各ユーザーの会社名を取得し、重複排除して返す
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
   * Usersから各ユーザーの会社名と部署名の組合せを取得し、重複排除して返す
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