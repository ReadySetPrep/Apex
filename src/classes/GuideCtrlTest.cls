@isTest
private class GuideCtrlTest {

    static GuideCtrl initTest() {
        PageReference pageRef = Page.Guide;
        Test.setCurrentPage(pageRef);
        GuideCtrl ctrl = new GuideCtrl();
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

    static testMethod void testDoModule() {
        GuideCtrl ctrl = initTest();
        Active__c a = initData();
        for (Integer i=0; i<4; i++) {
            Point__c p = data[i];
            Factory.logComplete(p.Id,1); 
        }
        for (Integer i=4; i<8; i++) {
            Point__c p = data[i];
            Factory.logComplete(p.Id,i); 
        }
                        
        ctrl.Module = Factory.TM;
        PageReference page = ctrl.doModule();
        System.assert(page==null,
            'Expected to stay on Guide page.');
        
        Integer scores = ctrl.Rows.size();
        System.assert(8==Scores, 
            'Expected 8 complete. Have ' + String.valueOf(scores) + '.' );
            
        Integer incorrect = 0;
        Integer correct = 0;    
        for(GuideCtrl.GuideRow row : ctrl.rows) {
           String result = row.getResult(); 
           if (result.contains('Incorrect')) incorrect++;
           if (result.contains('Correct')) correct++;
        }
        
        System.assert(4==incorrect && 4==correct, 
            'Expected 4/4 incorrect/correct');
    }     
    
    static testMethod void testDoModule_fail() {
        GuideCtrl ctrl = initTest();
        PageReference pageRef = ctrl.doModule();
        System.assert(Factory.URL_MAIN==pageRef.getUrl(),
            'Expected redirect to Main on fail, not ' + pageRef.getUrl() + '.');
    }
    
}