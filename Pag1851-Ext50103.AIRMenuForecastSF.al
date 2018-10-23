pageextension 50103 "AIR MenuForecast SF" extends "Sales Forecast No Chart" //1851
{
    layout
    {

    }

    actions
    {
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

    }
}