table 50101 "AIR MF Event Schedule"
{

    fields
    {
        field(1; "Event Date"; Date)
        {
        }
        field(2; "Event Type"; Option)
        {
            OptionMembers = " ","Music Event","Children Event",Festival;
        }
        field(10; "Event Name"; Text[250])
        {

        }
    }

    keys
    {
        key(PK; "Event Date", "Event Type")
        {
            Clustered = true;
        }
    }

}