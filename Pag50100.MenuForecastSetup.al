page 50100 "AIR Menu Forecast Setup"
{

    PageType = Card;
    SourceTable = "AIR Menu Forecast Setup";
    Caption = 'Menu Items Sales Forecast Setup';
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Primary Key"; "Primary Key")
                {
                    ApplicationArea = All;
                }
                field("API URI"; "API URI")
                {
                    ApplicationArea = All;
                }
                field("API Key ID"; "API Key ID")
                {
                    ApplicationArea = All;
                }
                field("Menu Item Category"; "Menu Item Category")
                {
                    ApplicationArea = All;
                }
                field("Menu Attribute"; "Menu Attribute")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
