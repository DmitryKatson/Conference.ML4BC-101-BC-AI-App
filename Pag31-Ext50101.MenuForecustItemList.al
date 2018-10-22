pageextension 50101 "AIR MenuForecustItemList" extends "Item List" //31
{
    layout
    {

    }

    actions
    {
        addafter(Attributes)
        {
            group(Restaurant)
            {
                Visible = MenuForecastIsConfigured;
                action("AIR ShowOnlyMenuItems")
                {
                    Caption = 'Show only menu';
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category10;
                    Image = AssemblyBOM;
                    trigger OnAction()
                    begin
                        ShowOnlyMenuItemsInTheList();
                    end;
                }
            }
        }
    }

    var
        [InDataSet]
        MenuForecastIsConfigured: Boolean;

    trigger OnOpenPage()
    begin
        GetIfMenuForecastIsConfigured(MenuForecastIsConfigured);
    end;

    local procedure GetIfMenuForecastIsConfigured(var isProperlyConfigured: Boolean)
    var
        MFSetup: Record "AIR Menu Forecast Setup";
    begin
        if not MFSetup.Get() then
            exit;

        isProperlyConfigured := (MFSetup."Menu Attribute" <> '') and (MFSetup."Menu Item Category" <> '')
    end;

    local procedure ShowOnlyMenuItemsInTheList()
    var
        MFSetup: Record "AIR Menu Forecast Setup";
    begin
        If not MFSetup.Get() then
            exit;

        if not MenuForecastIsConfigured then
            exit;

        SetRange("Item Category Code", MFSetup."Menu Item Category");
    end;
}