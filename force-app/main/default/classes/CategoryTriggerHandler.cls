public with sharing class CategoryTriggerHandler {

    public static void handleTrigger(List<Category__c> triggerOld, List<Category__c> triggerNew, Map<Id, Category__c> oldMap, Map<Id, Category__c> newMap, System.TriggerOperation triggerEvent ) {
        switch on triggerEvent {
            when AFTER_INSERT {               
                //checkCategories
                CheckCategories(triggerNew,null);

            }
            when  AFTER_UPDATE{             
                //checkCategories
                CheckCategories(triggerNew,oldMap);
            }
            when AFTER_DELETE {           
                //checkCategories             
                CheckCategories(triggerOld,null);

            }

        }

    }
static void CheckCategories(List<Category__c> trrigerRecords, Map<Id, Category__c> oldMap){
    Set<Id> setBuildingIds = New Set<Id>();

    for (Category__c cat : trrigerRecords){
        if( oldMap == null ){
            setBuildingIds.Add(cat.Building_lok__c);
        }else if (oldMap != null && cat.Surface__c != oldMap.get(cat.Id).Surface__c){
             setBuildingIds.Add(cat.Building_lok__c);
        }
        
           
    }
if(setBuildingIds.size()>0){

    List<Building__c> listBuilding = [SELECT Id, Total_Building_Surface__c, (SELECT Id, Surface__c, Total_Category_Surface__c,Category_lok__c FROM Categories2__r WHERE Surface__c != null ) 
                                        FROM Building__c Where id in:setBuildingIds];

        List<Category__c> listToUpdateCategory = new List<Category__c>();

            Set <Id> SetCategoryIds = new Set <Id> ();
           

     for(Building__c b :listBuilding){
        Decimal totalBuildingSurface = 0;
        
  
        for(Category__c c : b.Categories2__r){
             
           
                    c.Total_Category_Surface__c = c.Surface__c;
                totalBuildingSurface += c.Total_Category_Surface__c;
                
                if( c.Category_lok__c!=null){

                   SetCategoryIds.add(c.Category_lok__c);

                }
           
        }
        listToUpdateCategory.addAll(b.Categories2__r);
        b.Total_Building_Surface__c = totalBuildingSurface;
     }

update listToUpdateCategory;
update listBuilding;

      List<Category__c> listCategories = [SELECT Id, Surface__c, Total_Category_Surface__c,Category_lok__c , (SELECT Id, Surface__c, Total_Category_Surface__c,RecordTypeId FROM Categories__r  Where RecordTypeId = '0122o000000lxOZAAY')  
                                                FROM Category__c  where id in :SetCategoryIds ] ;
            for(Category__c rC :listCategories){
                Decimal totalCategorySurface = 0;
                    for(Category__c cR : rC.Categories__r){
            
                            totalCategorySurface+=cR.Total_Category_Surface__c;
                    }
                 rC.Total_Category_Surface__c += totalCategorySurface;

             }
        update listCategories;
        }
    }
}