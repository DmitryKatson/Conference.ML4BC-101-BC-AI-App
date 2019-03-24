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
        InsertMenuItem('12', 'Fruit', true, 116, true);
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
        MFSetup."API Key ID" := '<<API KEY>>'0; //insert API Key here from AML WS
        MFSetup."API URI" := '<<API URI>>'0;  //insert API URI here from AML WS
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

        UploadItemPicture(Item."No.");

        if not PostDemoEntries then
            exit;

        PostDemoItemLedgerEntries(Item."No.", Round(MaxQtyOnStock * 8, 1), CalcDate('<-6D>', WorkDate()), 0, 10000);
        PostDemoItemLedgerEntries(Item."No.", Round(MaxQtyOnStock * 0.9, 1), CalcDate('<-1D>', WorkDate()), 1, 10000);
        PostDemoItemLedgerEntries(Item."No.", Round(MaxQtyOnStock * 0.8, 1), CalcDate('<-2D>', WorkDate()), 1, 10000);
        PostDemoItemLedgerEntries(Item."No.", Round(MaxQtyOnStock * 0.6, 1), CalcDate('<-3D>', WorkDate()), 1, 10000);
        PostDemoItemLedgerEntries(Item."No.", Round(MaxQtyOnStock * 1.5, 1), CalcDate('<-4D>', WorkDate()), 1, 10000);
        PostDemoItemLedgerEntries(Item."No.", Round(MaxQtyOnStock * 1.2, 1), CalcDate('<-5D>', WorkDate()), 1, 10000);
    end;

    local procedure PostDemoItemLedgerEntries(ItemNo: Code[20]; Qty: Decimal; PostingDate: date; EntryType: Integer; LineNo: Integer);
    var
        ItemJnlLine: Record "Item Journal Line";
        ItemJnlMgt: Codeunit ItemJnlManagement;
        JnlSelected: Boolean;
        CurrentJnlBatchName: Code[10];
    begin
        ItemJnlMgt.TemplateSelection(PAGE::"Item Journal", 0, FALSE, ItemJnlLine, JnlSelected);
        IF NOT JnlSelected then
            exit;
        ItemJnlMgt.OpenJnl(CurrentJnlBatchName, ItemJnlLine);

        DeleteAllItemJnlLines('ITEM', 'DEFAULT');

        with ItemJnlLine do begin
            Init();
            Validate("Journal Template Name", 'ITEM');
            Validate("Journal Batch Name", 'DEFAULT');
            SetUpNewLine(ItemJnlLine);
            Validate("Line No.", LineNo);
            Validate("Item No.", ItemNo);
            Validate("Entry Type", EntryType);
            Validate("Document No.", ItemNo);
            Validate("Posting Date", PostingDate);
            Validate(Quantity, Qty);
            Insert(true);
        end;

        CODEUNIT.RUN(CODEUNIT::"Item Jnl.-Post Line", ItemJnlLine);
    end;

    local procedure DeleteAllItemJnlLines(TemplateName: Code[20]; BatchName: code[20])
    var
        ItemJnlLine: Record "Item Journal Line";
    begin
        ItemJnlLine.SetRange("Journal Template Name", TemplateName);
        ItemJnlLine.SetRange("Journal Batch Name", BatchName);
        ItemJnlLine.DeleteAll(true);
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
        MenuForecastPopulate: Codeunit "AIR MenuForecastPopulate";
    begin
        if not MFSetup.IsMenuForecastProperlyConfigured() then
            exit;
        Item.SetRange("Item Category Code", MFSetup."Menu Item Category");
        If Item.FindSet() then
            repeat
                MenuForecastPopulate.PrepareForecast(Item."No.");
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

    local procedure UploadItemPicture(ItemNo: code[20])
    var
        PictureURL: Text;
        Client: HttpClient;
        Response: HttpResponseMessage;
        InStr: InStream;
        Item: Record Item;
    begin
        Item.get(ItemNo);

        PictureURL := GetItemPictureUrl(Item."No. 2");
        If Not Client.Get(PictureURL, Response) then
            exit;

        Response.Content().ReadAs(InStr);

        Item.Picture.ImportStream(InStr, Item.Description);
        Item.Modify();
    end;

    local procedure GetItemPictureUrl(ItemNo: Code[20]): Text
    begin
        Case ItemNo of
            '0':
                exit('https://i.pinimg.com/originals/fa/c5/d7/fac5d7e64dad9b83adf4e9baf89f907e.jpg');
            '1':
                exit('https://s3-media2.fl.yelpcdn.com/bphoto/14bESw7982LpvusjT3Am8Q/o.jpg');
            '2':
                exit('https://growfood.pro/blog/wp-content/uploads/2017/11/yayca-pravilnoe-pitanie2.jpg');
            '3':
                exit('https://assets.rbl.ms/14520696/980x.jpg');
            '4':
                exit('http://kzd1000.ru/images/cms/data/sendvichnica_-_buterbrodnica_elektricheskaya_v-_6152_na_4_sht_3.jpg');
            '5':
                exit('https://d1wv4dwa0ti2j0.cloudfront.net/live/img/production/detail/ice-cream/cartons_rich-creamy_classic-chocolate.jpg');
            '6':
                exit('https://www.carriesexperimentalkitchen.com/wp-content/uploads/2014/03/Corned-Beef-Hash-cek.jpg');
            '7':
                exit('https://www.foodtrients.com/wp-content/uploads/2016/05/crab-civiche-1024x720.jpg');
            '8':
                exit('https://static.fanpage.it/wp-content/uploads/sites/21/2017/12/crackers.jpg');
            '9':
                exit('https://www.friendshipbreadkitchen.com/wp-content/uploads/2011/02/Cream-Cheese-Frosting-3.jpg');
            '10':
                exit('https://look.com.ua/pic/201505/1920x1080/look.com.ua-119386.jpg');
            '11':
                exit('https://static01.nyt.com/images/2017/07/13/multimedia/French-Fries_SOCIAL_still/French-Fries_SOCIAL_still-videoSixteenByNineJumbo1600.jpg');
            '12':
                exit('https://ph.toluna.com/dpolls_images/2018/12/09/8ae89ac8-3fea-457e-ab2a-cd3f47a5fdb1.jpg');
            '13':
                exit('https://img3.badfon.ru/original/2048x1360/2/ff/vinograd-krasnyy-grozdi-kust-1636.jpg');
            '14':
                exit('https://fermilon.ru/wp-content/uploads/2017/05/1-27.jpg');
            '15':
                exit('https://img.delicious.com.au/8_W_mBr_/w1200/del/2015/10/steamed-orange-puddings-13523-1.jpg');
            '16':
                exit('http://s1.1zoom.me/b5050/748/Orange_fruit_Juice_Fruit_443369_1920x1200.jpg');
            '17':
                exit('https://res.cloudinary.com/uktv/image/upload/v1435307591/avhhshxr7pm6gocfytqo.jpg');
            '18':
                exit('https://wallbox.ru/resize/2560x1600/wallpapers/main2/201725/1497981115594960bbe84331.73238678.jpg');
            '19':
                exit('http://marieclaire.com.my/wp-content/uploads/2016/04/Oyster-shooters-1.jpg');
            '20':
                exit('https://www.artsfon.com/pic/201708/1680x1050/artsfon.com-114222.jpg');
            '21':
                exit('https://getbg.net/upload/full/www.GetBg.net_2017Food___Berries_and_fruits_and_nuts_Juicy_ripe_blue_plums_113021_.jpg');
            '22':
                exit('http://fb.ru/misc/i/gallery/13662/2977215.jpg');
            '23':
                exit('https://wmpics.pics/dl-COUA.jpg');
            '24':
                exit('https://datysho.ru/wp-content/uploads/2018/11/04-15.jpg');
            '25':
                exit('https://vzboltay.com/uploads/posts/2019-01/1548013359_sauternes-retina.jpg');
            '26':
                exit('https://www.incredibleegg.org/wp-content/uploads/Scrambled-with-Milk-930x620.jpg');
            '27':
                exit('https://assets.bonappetit.com/photos/5b3bed6d02847f05a1933429/master/pass/ba-best-shrimp-cocktail-2.jpg');
            '28':
                exit('https://rfsdelivers.com/images/restaurant-inc/the-dish/dish-shrimp-salad.jpg');
            '29':
                exit('https://cdn.pixabay.com/photo/2018/08/20/07/01/tomatoes-3618281_1280.jpg');
            '30':
                exit('https://images.csmonitor.com/csm/2012/07/cajuncorn.jpg');
            '31':
                exit('http://www.simplebites.net/wp-content/uploads/2012/03/prunes.jpg');
            '32':
                exit('https://indianagentledentist.com/abbeville/wp-content/uploads/sites/22/2018/03/iStock-514149368.jpg');
            '33':
                exit('https://images8.alphacoders.com/387/387276.jpg');
            '34':
                exit('http://www.misskitchenwitch.com/blog/wp-content/uploads/2013/08/RicePudding1.jpg');
        End;
    end;

}