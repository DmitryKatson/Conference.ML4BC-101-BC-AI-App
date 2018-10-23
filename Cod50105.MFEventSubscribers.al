codeunit 50105 "AIR MF Event Subscribers"
{
    [EventSubscriber(ObjectType::Page, Page::"Item Card", 'OnAfterGetCurrRecordEvent', '', false, false)]
    local procedure OnAfterGetCurrRecordOnItemCard(var Rec: Record Item)
    var
        MFExist: Codeunit "AIR MenuForecast Exist";
    begin
        Rec."Has Sales Forecast" := MFExist.HasSalesForecast(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item List", 'OnAfterGetCurrRecordEvent', '', false, false)]
    local procedure OnAfterGetCurrRecordOnItemList(var Rec: Record Item)
    var
        MFExist: Codeunit "AIR MenuForecast Exist";
    begin
        Rec."Has Sales Forecast" := MFExist.HasSalesForecast(Rec);
    end;

}