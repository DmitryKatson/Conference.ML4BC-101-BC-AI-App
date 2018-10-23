page 50101 "AIR MF Event Schedule List"
{

    PageType = List;
    SourceTable = "AIR MF Event Schedule";
    Caption = 'Events Schedule';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Event Date"; "Event Date")
                {
                    ApplicationArea = All;
                }
                field("Event Type"; "Event Type")
                {
                    ApplicationArea = All;
                }
                field("Event Name"; "Event Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        ShowOnlyFutureEvents();
    end;

    local procedure ShowOnlyFutureEvents()
    begin
        SetFilter("Event Date", '%1..', WorkDate())
    end;

}
