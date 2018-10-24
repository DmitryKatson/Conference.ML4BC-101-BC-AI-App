pageextension 50102 "AIR MenuForecast SalesForecast" extends "Sales Forecast"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        modify("Delete Sales Forecast")
        {
            Visible = false;
        }
        modify("Forecast Settings")
        {
            Visible = false;
        }
        addfirst(processing)
        {
            action("Menu Forecast Update")
            {
                Image = Forecast;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    UpdateRestaurantMenuForecast();
                end;
            }
        }

        addafter("Forecast Settings")
        {
            action("Menu Forecast Settings")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Forecast Settings';
                ToolTip = 'View or edit the setup for the forecast.';

                trigger OnAction();
                begin
                    Page.Run(Page::"AIR Menu Forecast Setup");
                end;

            }
        }
    }
}