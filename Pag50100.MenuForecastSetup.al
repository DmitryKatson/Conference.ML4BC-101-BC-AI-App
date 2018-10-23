page 50100 "AIR Menu Forecast Setup"
{

    PageType = Card;
    SourceTable = "AIR Menu Forecast Setup";
    Caption = 'Restaurant Menu Sales Forecast Setup';
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
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
    actions
    {
        area(Navigation)
        {
            action("Events")
            {
                ApplicationArea = All;
                Image = DueDate;
                RunObject = page "AIR MF Event Schedule List";
            }
        }
    }

}
