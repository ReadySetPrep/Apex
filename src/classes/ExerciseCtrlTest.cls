@isTest
private class ExerciseCtrlTest {

    static ExerciseCtrl initTest() {
        PageReference pageRef = Page.Exercise;
        Test.setCurrentPage(pageRef);
        ExerciseCtrl ctrl = new ExerciseCtrl();
        return ctrl;
    }
    
    static List<Point__c> data = new List<Point__c>();
    
    static Active__c initData() {
        if (data.size()==0) { 
            data = Factory.newModuleTest(Factory.TM);
            upsert data;
            Active__c a = Factory.setActive(Factory.TM);  
            return a;          
        } else { 
            return Factory.getActive();
        }
    }
    
    static testMethod void testGetOptions() {
        ExerciseCtrl ctrl = initTest();
        String[] myOptions = new String[]{};
        for (Integer i=0; i<Factory.OPS; i++) {
            myOptions.add(String.valueOf(i));
        }
        ctrl.Option = myOptions;
        List<SelectOption> options = ctrl.getOptions();
        for (Integer i=0; i<Factory.OPS; i++) {
            SelectOption o = options[i];
            String value = o.getValue();
            String label = o.getLabel();
            System.assert(value==label,
                'Expected value and label to match.');
                
            System.assert(value==myOptions[i],
                'Expected value to match original.');
        }     
    }
    
    static testMethod void testGetOptions_Errors() {
        String empty = Factory.checkOption('',1);
        String unset = Factory.checkOption(null,1);
        System.assert(Factory.MISSING_OPTION==empty && 
            Factory.MISSING_OPTION==unset,
            'Expected parameters to be validated.');           
    }

    static testMethod void testDoSelect_Pass() {
        ExerciseCtrl ctrl = initTest();
        Active__c a = initData();
        PageReference next = ctrl.doNext();
        for (Integer i=0; i<Factory.OPS; i++) {
            if (ctrl.Correct[i]) ctrl.Selections.add(ctrl.Option[i]);
        }
        next = ctrl.doSelect();
        String testOutcome = Factory.CORRECT;
        System.assert(Factory.CORRECT==ctrl.Outcome,
            'Expected Outcome to be success.');
            
        System.assert(1==ctrl.Tries,
            'Expected first try.');
            
        Integer count = [
            SELECT COUNT() 
            FROM Score__c 
            WHERE Point__c = :ctrl.PointId
        ];
        System.assert(1==count, 
            'Expected one score to be logged, not ' + String.valueOf(count) + '.');
    }

    static testMethod void testDoSelect_Fail() {
        ExerciseCtrl ctrl = initTest();
        Active__c a = initData();
        PageReference next = ctrl.doNext();
        for (Integer i=0; i<Factory.OPS; i++) {
            if (!ctrl.Correct[i]) ctrl.Selections.add(ctrl.Option[i]);
        }
        next = ctrl.doSelect();
        String testOutcome = Factory.NOT_CORRECT;
        System.assert(Factory.NOT_CORRECT==ctrl.Outcome,
            'Expected Outcome to be failure.');
            
        System.assert(1==ctrl.Tries,
            'Expected first try.');
        
        Integer count = [
            SELECT COUNT()
            FROM Score__c 
            WHERE Id = :ctrl.PointId 
                AND isComplete__c = true
        ];
        System.assert(0==count, 
            'Expected Failure not to be logged');
    }
     
    static testMethod void testDoNext() {
        ExerciseCtrl ctrl = initTest();
        Active__c a = initData();
        System.assert(null!=a,
            'Expected score for test data.');
        
        PageReference next = ctrl.doNext();
        System.assert(null==next,
            'Expected to stay on Exercise page.');
            
        // Review ...
        Boolean haveLegends = (ctrl.Current!='') && 
            (ctrl.Total!='') && (ctrl.Progress!='') && 
            (ctrl.SelectionLabel!=''); 
        System.assert(haveLegends,
            'Expected page legends to be set.');
        
        System.assert(0<ctrl.Corrects,
            'Expected at least one option to be correct.');
        
        
        String omega = ctrl.Option[Factory.OPS-1];
        Boolean isOmega = ctrl.Correct[Factory.OPS-1];
        System.assert(null!=omega && ''!=omega && null!=isOmega,
            'Expected all four options to be populated');
            
        System.assert(!ctrl.PostBack,
            'Expected PostBack to be false.');
            
        System.assert(''==ctrl.Outcome,
            'Expected Outcome to be empty.');
            
        System.assert('Exercise 1 out of 10.' == ctrl.Progress, 
            'Expected 1 out of 10 not ' + ctrl.Progress);
    }
    
    static testMethod void testDoNext_NoActive() {
        ExerciseCtrl ctrl = initTest();
        PageReference next = ctrl.doNext(
            Factory.getTestUser('user@test.com').Id);
        System.assert(Factory.URL_MAIN==next.getURL(),
            'Expected redirect to Prep! main page.');    
    }
    
    static testMethod void testDoNext_NoneLeft() {   
        ExerciseCtrl ctrl = initTest();
        Active__c a = initData();
        Integer count = Factory.getLeft(a).size();
        PageReference next = null;
        for (Integer j=0; j<count; j++) {        
            next = ctrl.doNext();
            String js = String.valueOf(j+1);
            System.assert(js==ctrl.Current, 
                'Expected Current to advance. (' + ctrl.Current + '/' + js + ')');            
            for (Integer i=0; i<Factory.OPS; i++) {
                if (ctrl.Correct[i]) ctrl.Selections.add(ctrl.Option[i]);
            }
            next = ctrl.doSelect();
        }
        next = ctrl.doNext();
        System.assert(null!=next, 
            'Expected redirect if done.');
            
        String nextUrl = next.getUrl();
        String guideUrl = '/apex/prep__guide?module=TM+-+Test+Module';       
        System.assert(guideUrl==nextUrl,
            'Expected redirect to ' + guideUrl + ' when done, not ' + nextUrl + '.');
    }  
}