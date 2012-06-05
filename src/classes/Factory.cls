/**
 * Utility methods used by controller classes. 
 * Object access is enforced by the 
 * logComplete and clearScore methods. 
 */
public class Factory {

    // -- Busines Rules --

    final public static Integer OPS = 4;

    // -- String Constants -- 
    
    final public static String CONTINUE_NEXT = 'Continue to the next exercise.';
    final public static String CORRECT = 'CORRECT! Please Continue.';
    final public static String NOT_CORRECT = 'NOT correct. Select again or Continue.';
    final public static String SETTING_NAME = 'ReadySetPrep';
    final public static String MISSING_OPTION = '-- Missing option --';
    final public static String NO_MODULES = '-- No modules available --';
    final public static String NO_PENDING = '-- No current reveiw session --';
    final public static String NO_PRIORS = '-- No prior scores --';
    final public static String SETUP_COMPLETE = '-- Sample module setup complete --';

    final public static String ERROR_PENDING_NOT_SELECTED = 'Current review sesssion not selected.';    
    final public static String ERROR_PRIOR_NOT_SELECTED = 'Prior scores not selected.';
    final public static String ERROR_MODULE_NOT_SELECTED = 'Module not selected.';
    final public static String ERROR_INSUFFICIENT_ACCESS = 'You do not have sufficient access to perform the requested operation. Contact your administrator.';
    
    final public static String PARAM_MODULE = 'module';
    
    final public static String URL_EXERCISE = '/apex/prep__exercise';
    final public static String URL_GUIDE = '/apex/prep__guide';
    final public static String URL_MAIN = '/apex/prep__main';
    final public static String URL_VERIFY = '/apex/prep__verify';
    
    final public static String NO_ACCESS_NAME = 'no-access-test@dev.readysetprep.com'; 
    final public static String NO_ACCESS_PROFILE = 'PREP No Access';
    
    // -- String Constants (Test) --    

    final public static String DEMO_PENDING = 'X1 - Sales Cloud Consultant';
    final public static String A1 = 'A1 - Administrator';
    final public static String D2 = 'D2 - Advanced Developer';
    final public static String X1 = 'X1 - Sales Cloud Consultant';
    final public static String ZA = 'ZA - Sample Administrator';
    final public static String ZD = 'ZD - Sample Developer';
    final public static String TA = 'TA - Test Administrator';
    final public static String TD = 'TD - Test Developer';
    final public static String TM = 'TM - Test Module';
    
    // -- Helper methods -- 
    
    public static Boolean isCorrect(Set<String> selected, 
            Boolean[] isCorrect, String[] option) {
        // Gen answer key
        Set<String> keys = new Set<String>();
        for (Integer i=0; i<Factory.OPS; i++) {
            Boolean yup = isCorrect[i];
            if (yup) keys.add(option[i]);            
        }
        // True if count jives and selected contains each key
        Boolean ok = (keys.Size() == selected.Size());
        if (ok) for (String k: keys) {
            ok = ok && selected.contains(k); 
        }
        return ok;
    }
    
    public static Boolean hasMessage(String message) {
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean have = false;
        for(Apexpages.Message msg:msgs){
            have = have || (msg.getDetail().contains(message));
        }
        return have;      
    }   
    
   
    // -- Secure Retrieve, Create, and Delete methods --
    
     // Enforces Accessible
    public static List<SelectOption> getModules() {
        List<SelectOption> options = new List<SelectOption>();
        // Return empty list if access denied
        if (Point__c.sObjectType.getDescribe().isAccessible()) {
            List<Point__c> every = [
                SELECT Module__c 
                FROM Point__c 
                ORDER BY Module__c];
            Set<String> distinct = new Set<String>();
            for (Point__c p : every) {
                distinct.add(p.Module__c);
            }
            List<String> sorted = new List<String>();
            for (String m : distinct) { 
                sorted.add(m); 
            }
            sorted.sort();
            for (String m : sorted) { 
                options.add(new SelectOption(m,m)); 
            }
        } else {
          ApexPages.addMessage(
              new ApexPages.Message(
                  ApexPages.Severity.FATAL,ERROR_INSUFFICIENT_ACCESS));        
        }
        return options;
    }
       
    // Enforces createable
    public static void logComplete(Id pointId, Integer tries, Boolean isComplete, Id userId) {

        if (!Score__c.sObjectType.getDescribe().isCreateable()) {
          ApexPages.addMessage(
              new ApexPages.Message(
                  ApexPages.Severity.FATAL,ERROR_INSUFFICIENT_ACCESS));
          return;
        }

        Score__c Score = new Score__c();
            Score.Point__c = pointId;
            Score.Tries__c = tries;
            Score.isComplete__c = isComplete;
            Score.User__c = userId;
        insert Score;
    }
    
    public static void logComplete(Id pointId, Integer tries) {
        logComplete(pointId, tries, true, UserInfo.getUserId());   
    }
       
    // Enforces deleteable
    public static void clearScore(Id userId, String module) {
    
        if (!Score__c.sObjectType.getDescribe().isDeletable()) {
          ApexPages.addMessage(
              new ApexPages.Message(
                  ApexPages.Severity.FATAL,ERROR_INSUFFICIENT_ACCESS));
          return;
        }
    
        List<Score__c> scores = new List<Score__c>();
        scores = [
            SELECT Id FROM Score__c 
            WHERE User__c = :userId
                AND Point__r.Module__c = :module
        ];
        delete scores;
    }
    
    public static void clearScore(String module) {
        clearScore(UserInfo.getUserId(),module);
    }
    
    // -- User Specific Methods --

    public static Active__c setActive(Id setupOwnerId, String module) {
        Active__c a = Active__c.getValues(setupOwnerId);
        boolean isNew = (a==null);
        if (isNew) {
            a = new Active__c();
            a.SetupOwnerId = setupOwnerId;
            a.Name = SETTING_NAME;
        }
        a.Module__c = module;
        upsert a; return a;
    }
    
    public static Active__c setActive(String module) {
        return setActive(UserInfo.getUserId(),module);
    }
    
    public static Active__c getActive(Id setupOwnerId) {
        Active__c a = Active__c.getValues(setupOwnerId);
        // Strip search Active - Custom settings can be spooky
        if ((a==null) || (a.Module__c==null) || (a.Module__c=='')) {
            return null; 
        } else { 
            return a;
        }
    }

    public static Active__c getActive() {
        return getActive(UserInfo.getUserId());
    }
    
    public static List <Score__c> getDone(Id userId, String module) {
        List<Score__c> done = new List<Score__c>();
        done = [
            SELECT Id, Point__c, Point__r.Module__c 
            FROM Score__c 
            WHERE User__c = :userId
                AND Point__r.Module__c = :module
                AND isComplete__c = true
            ORDER BY Point__r.Module__c            
        ];
        return done;
    }
  
    public static List <Score__c> getDone(Active__c a) {
        return getDone(a.SetupOwnerId, a.Module__c);
    }
     
    public static List <Score__c> getDoneModules(Id userId) {
        List<Score__c> done = new List<Score__c>();
        done = [
            SELECT Id, Point__c, Point__r.Module__c 
            FROM Score__c 
            WHERE User__c = :userId
            ORDER BY Point__r.Module__c            
        ];
        return done;
    }
  
  public static List<SelectOption> getPriors(Id userId) {
        List<Score__c> done = getDoneModules(userId);
        Set<String> distinct = new Set<String>();
        for (Score__c s : done) {
            distinct.add(s.Point__r.Module__c);
        }
        List<String> sorted = new List<String>();
        for (String m : distinct) { 
            sorted.add(m); 
        }
        sorted.sort();        
        List<SelectOption> options = new List<SelectOption>();
        for (String m : sorted) { 
            options.add(new SelectOption(m,m)); 
        }
        return options;
    }
    
    public static List<SelectOption> getPriors() {
        return getPriors(UserInfo.getUserId());
    }
    
    // Parity check
    public static String checkOption(String myOption, Integer count) {
        if ((myOption==null) || (myOption=='')) {
            myOption = Factory.MISSING_OPTION;
        }
        return myOption;
    }    
    
    public static Integer doneCount(ID userId, String module) {
        return [
            SELECT COUNT() 
            FROM Score__c 
            WHERE User__c = :userId
                AND Point__r.Module__c = :module
                AND isComplete__c = true
        ];
    }
    
    public static Integer doneCount(String module) {
        return doneCount(UserInfo.getUserId(),module);
    }

    // (False Positive?) Checkmarx warns: Bulkify_Apex_Methods_Using_Collections_In_Methods    
    public static Integer doneCount(Active__c a) {
        return doneCount(a.SetupOwnerId, a.Module__c);
    }
    
    public static Integer moduleCount(String module) {
        return [
            SELECT COUNT() 
            FROM Point__c 
            WHERE Module__c = :module
        ];
    }
    
    // (False Positive?) Checkmarx warns: Bulkify_Apex_Methods_Using_Collections_In_Methods
    public static Integer moduleCount(Active__c a) {
        return moduleCount(a.Module__c);
    }

    public static List<Point__c> getLeft(Active__c a) {
        List<Score__c> done = getDone(a);
        Set<String> keys = new Set<String>();
        for (Score__c s : done) {
            keys.add(s.Point__c);        
        }
        List<Point__c> left = new List<Point__c>();
        left = [
            SELECT 
                Id, Module__c, Objective__c, Exercise__c, 
                Option1__c, Option2__c, Option3__c, Option4__c,
                Correct1__c, Correct2__c, Correct3__c, Correct4__c,
                Link__c, Source__c
            FROM Point__c 
            WHERE Module__c = :a.Module__c 
            AND Id NOT IN :keys
            ORDER BY Objective__c            
        ];
        return left;
    }

    private static List<Point__c> getPoints(Set<id> ids) {
        List<Point__c> points = new List<Point__c>();
        points = [
            SELECT 
                Id, Module__c, Objective__c, Exercise__c, 
                Option1__c, Option2__c, Option3__c, Option4__c,
                Correct1__c, Correct2__c, Correct3__c, Correct4__c,
                Link__c, Source__c                
            FROM Point__c 
            WHERE id IN :ids
        ];
        return points;
    }
    
    public static List<Point__c> getCorrect(Id userId, String module) {
        List<Score__c> scores = new List<Score__c>();
        scores = [
            SELECT Point__c, Point__r.Module__c, Point__r.Objective__c
            FROM Score__c 
            WHERE User__c = :userId 
                AND Point__r.Module__c = :module 
                AND isComplete__c = true
                AND Tries__c = 1
            ORDER BY Point__r.Module__c  
        ];
        Set<Id> ids = new Set<id>();
        for (Score__c s: scores) {
            ids.add(s.Point__c);
        }
        return getPoints(ids);
    }
  
    public static List<Point__c> getCorrect(String module) {
        return getCorrect(UserInfo.getUserId(),module);
    }
    
    public static List<Point__c> getIncorrect(Id userId, String module) {
        List<Score__c> scores = new List<Score__c>();
        scores = [
            SELECT Point__c, Point__r.Module__c, Point__r.Objective__c
            FROM Score__c 
            WHERE User__c = :userId 
                AND Point__r.Module__c = :module 
                AND isComplete__c = true
                AND Tries__c > 1
            ORDER BY Point__r.Objective__c ASC, Tries__c DESC    
        ];      
        Set<Id> ids = new Set<id>();
        for (Score__c s: scores) {
            ids.add(s.Point__c);
        }
        return getPoints(ids);
    }
    
    public static List<Point__c> getIncorrect(String module) {
        return getIncorrect(UserInfo.getUserId(),module);
    }
    
    public static Map<Id,Decimal> getTries(Id userId, String module) {
        Map<Id,Decimal> tries = new Map<Id,Decimal>();
        List<Score__c> scores = new List<Score__c>();
        scores = [
            SELECT Point__c, Tries__c 
            FROM Score__c 
            WHERE User__c = :userId 
                AND Point__r.Module__c = :module
        ];
        for (Score__c s : scores) {
            tries.put(s.Point__c, s.Tries__c);
        } 
        return tries;
    }
    
    public static Map<Id,Decimal> getTries(String module) {
        return getTries(UserInfo.getUserId(),module);
    }
    
    // -- Test Data --
  
    private static Integer count = 0;
   
    // Returns null if profile is not available.
    public static User getTestUser(String username, String profile) {
        Integer profiles = [SELECT COUNT() FROM Profile WHERE name = :profile];
        if (profiles>0) {
            Profile SysAdProfileId = [SELECT Id FROM Profile WHERE name = :profile];       
             User newUser = new User
                 (username=username + '.' + count++,
                 lastName='myLastName',
                 profileId=SysAdProfileId.id,
                 email='user@test.com',
                 alias='testUser',
                 timeZoneSidKey='America/Denver',
                 localeSidKey='en_CA',
                 emailEncodingKey='UTF-8',
                 languageLocaleKey='en_US');
                 insert newUser; 
             return newUser;
        } else { 
            return null;
        }
    }
    
    public static User getTestUser(String username) {
        return getTestUser(username, 'System Administrator');
    }
  
    public static List<Point__c> newModuleTest(String module) {

        List<String> s = newSource(); 
        List<String> o = newObjective(); 
        List<String> e = newExercise();
        List<String> k = newLink(); 
        List<Point__c> p = new Point__c[10];

        for (Integer n=0; n<10; n++) {
            p[n] = new Point__c (
                Source__c = s[n],
                Correct1__c = true,
                Objective__c = o[n],
                Exercise__c = e[n],
                Link__c = k[n],
                Option1__c = 'Alpha',
                Option2__c = 'Beta',
                Option3__c = 'Charlie',
                Option4__c = 'Delta', 
                Module__c = module,
                Version__c = 19 );
       }  
       
       p[5].Correct2__c = true;
       p[6].Correct2__c = true;
       p[7].Correct2__c = true;
       p[7].Correct3__c = true;
       p[8].Correct2__c = true;
       p[8].Correct3__c = true;
       p[9].Correct2__c = true;
       p[9].Correct3__c = true;
       p[9].Correct4__c = true;
      
       return p; 
    }

    static String[] newObjective() {
        String[] o = new String[10];
            o[0] = 'Objective (1)';
            o[1] = 'Objective (2)';
            o[2] = 'Objective (2)';
            o[3] = 'Objective (2)';
            o[4] = 'Objective (3)';
            o[5] = 'Objective (3)';
            o[6] = 'Objective (3)';
            o[7] = 'Objective (3)';
            o[8] = 'Objective (3)';
            o[9] = 'Objective (3)';
            return o;
    }

    static String[] newLink() {
        String[] k = new String[10];
            k[0] = 'https://www.google.com/doodles/new-years-day-2012';
            k[1] = 'https://www.google.com/doodles/happy-holidays-2011';
            k[2] = 'https://www.google.com/doodles/charles-addams-100th-birthday';
            k[3] = 'https://www.google.com/doodles/new-years-day-2012';
            k[4] = 'https://www.google.com/doodles/happy-holidays-2011';
            k[5] = 'https://www.google.com/doodles/charles-addams-100th-birthday';
            k[6] = 'https://www.google.com/doodles/new-years-day-2012';
            k[7] = 'https://www.google.com/doodles/happy-holidays-2011';
            k[8] = 'https://www.google.com/doodles/charles-addams-100th-birthday';
            k[9] = 'https://www.google.com/doodles/oskar-luts-125th-birthday';
            return k;
    }

    static String[] newSource() {
        String[] s = new String[10];
            s[0] = 'Source (1)';
            s[1] = 'Source (2)';
            s[2] = 'Source (3)';
            s[3] = 'Source (1)';
            s[4] = 'Source (2)';
            s[5] = 'Source (3)';
            s[6] = 'Source (1)';
            s[7] = 'Source (2)';
            s[8] = 'Source (3)';
            s[9] = 'Source (4)';
        return s;
    }
    
    static String[] newExercise() {    
        String[] e = new String[10];
            e[0] = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.';      
            e[1] = 'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.';
            e[2] = 'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.';
            e[3] = 'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';
            e[4] = 'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.';
            e[5] = 'Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. ';
            e[6] = 'Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.'; 
            e[7] = 'Corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur?';
            e[8] = 'Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur.';
            e[9] = 'At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga.';
        return e;    
    }
}