page 50102 "AIR MF Sales Forecast"
{
    Caption = 'MF Sales Forecast';
    PageType = List;
    SourceTable = "MS - Sales Forecast";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Date; Date)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Forecast Data"; "Forecast Data")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        SetFilter(Date, '%1..', WorkDate());
    end;

}