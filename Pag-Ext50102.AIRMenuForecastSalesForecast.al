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
        modify("Show Inventory Forecast")
        {
            Visible = false;
        }
        //modify("Show Sales Forecast")
        //{
            //trigger OnAfterAction()
            //var
            //    MFForecast: Record "MS - Sales Forecast";
            //begin
            //    MFForecast.SetRange("Item No.", rec."No.");
            //    Page.Run(Page::"AIR MF Sales Forecast", MFForecast);
            //end;
        //}
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