pageextension 50101 "AIR MenuForecustItemList" extends "Item List" //31
{
    layout
    {
        moveafter(Inventory; "Item Category Code")
        addafter("Item Category Code")
        {
            field("Maximum Inventory"; "Maximum Inventory")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addafter(Resources)
        {
            group(Restaurant)
            {
                Visible = MenuForecastIsConfigured;
                Image = Forecast;
                action("AIR ShowOnlyMenuItems")
                {
                    Caption = 'Show only menu items';
                    Image = AssemblyBOM;
                    ApplicationArea = All;
                    trigger OnAction()
                    begin
                        ShowOnlyMenuItemsInTheList();
                    end;
                }
                action("AIR UpdateForecast")
                {
                    Caption = 'Update Forecast';
                    Image = Forecast;
                    ApplicationArea = All;
                    trigger OnAction()
                    begin
                        UpdateRestaurantMenuForecast();
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
        isProperlyConfigured := MFSetup.IsMenuForecastProperlyConfigured();
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

    local procedure UpdateRestaurantMenuForecast()
    begin
        UpdateRestaurantMenuForecastForAllMenuItems();
    end;
}