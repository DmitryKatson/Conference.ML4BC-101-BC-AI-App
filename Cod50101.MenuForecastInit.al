codeunit 50101 "AIR MenuForecast Init"
{
    procedure GetDefaultMenuCategory(): Code[20]
    begin
        exit('Restaurant menu')
    end;

    procedure GetDefaultMenuAttribute(): Text[250]
    begin
        exit('Menu Type')
    end;

    procedure GetDefaultChildrenMenuAttributeValue(): Code[20]
    begin
        exit('Children')
    end;

    procedure GetDefaultAdultMenuAttributeValue(): Code[20]
    begin
        exit('Adult')
    end;

}