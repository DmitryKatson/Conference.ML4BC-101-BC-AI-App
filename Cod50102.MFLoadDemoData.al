codeunit 50102 "AIR MF Load Demo Data"
{
    procedure LoadDemoData()
    begin
        DoLoadDemoData();
    end;

    local procedure DoLoadDemoData()
    begin
        ConfigureWithDefaultMLEndPoint();

        ConfigureMSForecast();

        DeleteAllDemoItems();

        InsertMenuItem('34', 'rice pudding', true, 198, true);
        InsertMenuItem('12', 'Fruit', true, 116, false);
        InsertMenuItem('18', 'Oranges', true, 189, false);
        InsertMenuItem('32', 'Sweet Potatoes', true, 178, false);
        InsertMenuItem('4 ', 'Chicken Sandwich', true, 134, false);
        InsertMenuItem('23', 'STRAWBERRY ICE CREAM', true, 65, false);
        InsertMenuItem('29', 'Sliced Tomatoes', true, 131, false);
        InsertMenuItem('14', 'Milk', true, 113, false);
        InsertMenuItem('13', 'Grapes', true, 145, false);
        InsertMenuItem('11', 'French fried potatoes', true, 64, false);
        InsertMenuItem('24', 'Sardines', false, 67, false);
        InsertMenuItem('25', 'Sauterne', false, 77, false);
        InsertMenuItem('26', 'Scrambled Eggs', false, 190, false);
        InsertMenuItem('21', 'Plums', false, 87, false);
        InsertMenuItem('27', 'Shrimp Cocktail', false, 133, false);
        InsertMenuItem('28', 'Shrimp Salad', false, 180, false);
        InsertMenuItem('30', 'Stewed Corn', false, 91, false);
        InsertMenuItem('31', 'Stewed Prunes', false, 122, false);
        InsertMenuItem('33', 'Tea', false, 158, false);
        InsertMenuItem('22', 'ROQUEFORT CHEESE', false, 81, false);
        InsertMenuItem('0 ', 'Biscuit Tortoni', false, 163, false);
        InsertMenuItem('20', 'Pear', false, 87, false);
        InsertMenuItem('19', 'Oyster cocktail', false, 79, false);
        InsertMenuItem('1 ', 'Blue Point Oysters', false, 161, false);
        InsertMenuItem('16', 'Orange Juice', false, 183, false);
        InsertMenuItem('15', 'Nesselrode Pudding', false, 82, false);
        InsertMenuItem('10', 'Dessert', false, 149, false);
        InsertMenuItem('9 ', 'Cream Cheese', false, 127, false);
        InsertMenuItem('8 ', 'Crackers', false, 66, false);
        InsertMenuItem('7 ', 'Crab Flake Cocktail', false, 76, false);
        InsertMenuItem('6 ', 'Corned Beef Hash', false, 135, false);
        InsertMenuItem('5 ', 'Chocolate Ice Cream', false, 167, false);
        InsertMenuItem('3 ', 'Boiled potatoes', false, 172, false);
        InsertMenuItem('2 ', 'Boiled eggs', false, 113, false);
        InsertMenuItem('17', 'Orange marmalade', false, 70, false);

        DeleteAllEvents();

        InsertEvent(CalcDate('<3D>', WorkDate()), 1, '');
        InsertEvent(CalcDate('<2D>', WorkDate()), 2, '');
        InsertEvent(CalcDate('<5D>', WorkDate()), 3, 'City Lights');
        InsertEvent(CalcDate('<6D>', WorkDate()), 3, 'The V Festival');
        InsertEvent(CalcDate('<7D>', WorkDate()), 3, 'Wirless Festival');
        InsertEvent(CalcDate('<7D>', WorkDate()), 2, '');

    end;

    local procedure ConfigureWithDefaultMLEndPoint()
    var
        MFSetup: Record "AIR Menu Forecast Setup";
    begin
        if not MFSetup.Get() then
            exit;
        MFSetup."API Key ID" := '0I/iD1LnQqY0GW+dR/qgMC0QptWyLi97afaUBic2G5VYBHeNtq53SPfRShMApY3O4Exi5BBIjToQer6o1e+vbQ==';
        MFSetup."API URI" := 'https://europewest.services.azureml.net/subscriptions/57b61b3f20b1400ea1d2c8d894e54803/services/37be88c18f35472d8f09c0d3294b84ab/execute?api-version=2.0&details=true';
        MFSetup.Modify();
    end;

    local procedure ConfigureMSForecast()
    var
        SalesForecastSetup: Record "MS - Sales Forecast Setup";
    begin
        If Not SalesForecastSetup.Get() then
            SalesForecastSetup.Insert();
        SalesForecastSetup."Period Type" := SalesForecastSetup."Period Type"::Day;
        SalesForecastSetup.Modify();
    end;

    local procedure InsertMenuItem(ExternalID: Code[20]; Name: Text[250]; IsChildrenMenu: Boolean; MaxQtyOnStock: Decimal; PostDemoEntries: Boolean)
    var
        Item: Record Item;
        MFSetup: Record "AIR Menu Forecast Setup";
    begin
        if not MFSetup.Get() then
            exit;
        if isMenuItemAlreadyEsist(ExternalID, MFSetup."Menu Item Category") then
            exit;

        with Item do begin
            Init();
            "No." := '';
            Insert(true);

            Validate(Description, Name);
            Validate("Item Category Code", MFSetup."Menu Item Category");
            Validate("No. 2", ExternalID);
            Validate("Maximum Inventory", MaxQtyOnStock);
            InsertItemAttributeValueMapping(Item, MFSetup."Menu Attribute", IsChildrenMenu);
            Validate("Base Unit of Measure", 'Pack');
            Validate("Gen. Prod. Posting Group", 'RETAIL');
            Validate("Inventory Posting Group", 'RESALE');
            Modify(true);
        end;

        if not PostDemoEntries then
            exit;

        PostDemoItemLedgerEntries(Item."No.", Round(MaxQtyOnStock * 3, 1), CalcDate('<-1D>', WorkDate()), 0);
        PostDemoItemLedgerEntries(Item."No.", Round(MaxQtyOnStock * 0.9, 1), CalcDate('<-1D>', WorkDate()), 1);
        PostDemoItemLedgerEntries(Item."No.", Round(MaxQtyOnStock * 0.8, 1), CalcDate('<-2D>', WorkDate()), 1);
        PostDemoItemLedgerEntries(Item."No.", Round(MaxQtyOnStock * 0.6, 1), CalcDate('<-3D>', WorkDate()), 1);
        PostDemoItemLedgerEntries(Item."No.", Round(MaxQtyOnStock * 1.5, 1), CalcDate('<-4D>', WorkDate()), 1);
        PostDemoItemLedgerEntries(Item."No.", Round(MaxQtyOnStock * 1.2, 1), CalcDate('<-5D>', WorkDate()), 1);
    end;

    local procedure PostDemoItemLedgerEntries(ItemNo: Code[20]; Qty: Decimal; PostingDate: date; EntryType: Integer);
    var
        ItemJnlLine: Record "Item Journal Line";

    begin
        with ItemJnlLine do begin
            Init();
            Validate("Journal Template Name", 'ITEM');
            Validate("Journal Batch Name", 'DEFAULT');
            SetUpNewLine(ItemJnlLine);
            Validate("Line No.", 10000);
            Validate("Item No.", ItemNo);
            Validate("Entry Type", EntryType);
            Validate("Document No.", ItemNo);
            Validate("Posting Date", PostingDate);
            Validate(Quantity, Qty);
            Insert(true);
        end;

        CODEUNIT.RUN(CODEUNIT::"Item Jnl.-Post", ItemJnlLine);
    end;

    local procedure isMenuItemAlreadyEsist(ExternalID: Code[20]; CategoryCode: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        Item.SetRange("Item Category Code", CategoryCode);
        Item.SetRange("No. 2", ExternalID);
        exit(not Item.IsEmpty())
    end;

    local procedure InsertItemAttributeValueMapping(Item: Record Item; MenuType: Text[250]; IsChildrenMenu: Boolean)
    var
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        MFInit: Codeunit "AIR MenuForecast Init";
        MFItemAttributeMgt: Codeunit "AIR MF Item Attributes Mgt.";
    begin
        with ItemAttributeValueMapping do begin
            "Table ID" := DATABASE::Item;
            "No." := Item."No.";
            "Item Attribute ID" := MFItemAttributeMgt.GetItemAttributeID(MenuType);
            case IsChildrenMenu of
                true:
                    "Item Attribute Value ID" := MFItemAttributeMgt.GetItemAttributeValueID("Item Attribute ID", MFInit.GetDefaultChildrenMenuAttributeValue());
                false:
                    "Item Attribute Value ID" := MFItemAttributeMgt.GetItemAttributeValueID("Item Attribute ID", MFInit.GetDefaultAdultMenuAttributeValue())
            end;
            if Insert(true) then;
        end;
    end;

    local procedure DeleteAllDemoItems()
    var
        Item: Record Item;
        MFSetup: Record "AIR Menu Forecast Setup";
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        if not MFSetup.IsMenuForecastProperlyConfigured() then
            exit;
        Item.SetRange("Item Category Code", MFSetup."Menu Item Category");
        If Item.FindSet() then
            repeat
                ItemLedgEntry.SetRange("Item No.", Item."No.");
                if ItemLedgEntry.IsEmpty() then
                    Item.Delete(true);
            until Item.Next() = 0;
    end;

    local procedure DeleteAllEvents()
    var
        MFEvents: Record "AIR MF Event Schedule";
    begin
        MFEvents.DeleteAll(true);
    end;

    local procedure InsertEvent(EventDate: Date; EventType: Integer; EventName: Text[50])
    var
        MFEvents: Record "AIR MF Event Schedule";
    begin
        with MFEvents do begin
            Init();
            "Event Date" := EventDate;
            "Event Type" := EventType;
            "Event Name" := EventName;
            Insert();
        end;
    end;
}