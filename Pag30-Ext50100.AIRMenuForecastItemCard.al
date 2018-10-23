pageextension 50100 "AIR MenuForecastItemCard" extends "Item Card" //30
{
    layout
    {

    }

    actions
    {
        modify(Forecast)
        {
            Visible = false;
        }

        addafter(Forecast)
        {
            group(Restaurant)
            {
                Visible = MenuForecastIsConfigured;
                Image = Forecast;
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
            action("AIR OpenForecast")
            {
                Caption = 'Open Forecast';
                Image = OrderPromising;
                ApplicationArea = All;
                RunObject = page "AIR MF Sales Forecast";
                RunPageLink = "Item No." = field ("No.");
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

}
