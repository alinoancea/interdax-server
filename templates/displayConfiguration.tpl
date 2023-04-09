<!doctype html>
<html lang="en">
    <!-- HEAD -->
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        
        <link rel="stylesheet" href="static/css/bootstrap.min.css">
        <link rel="stylesheet" href="static/css/bootstrap-icons.css">
        <link href="static/css/styles.css" rel="stylesheet">
        
        <title>Interdax server</title>
    </head>
    <body class="bg-light">
        <!-- HEADER -->
        <header class="my-header">
            <div class="container p-2">
                <div class="d-flex flex-wrap align-items-center justify-content-center justify-content-lg-start">
                    <a href="/">
                        <img src="static/resources/ldp.png" class="float-start mw-5 logo" alt="Home LDP">
                    </a>
                    <span class="fs-4 fw-bolder p-2 ms-2 me-lg-auto">{{company_name}}</span>
                    <!-- <a href="/configuration">
                        <i class="bi bi-gear-fill"></i>
                    </a> -->
                </div>
            </div>
        </header>
        
        <!-- BODY -->
        <div class="container">
            <nav style="--bs-breadcrumb-divider: '';" aria-label="breadcrumb">
                <ol class="breadcrumb mt-3 align-items-center">
                    <li class="breadcrumb-item"><a href="/"><h3><span class="badge bg-primary">Pagina principala</span></h3></a></li>
                    <i class="bi bi-chevron-right mx-2"></i>
                    <li class="breadcrumb-item active"><h3><span class="badge bg-secondary">Configurare ecrane</span></h3></li>
                </ol>
            </nav>

            <div class="mb-3">
                <div class="form-floating col-sm-5">
                    <select class="form-select" id="displaySelect" aria-label="Select display">
                        % for k,v in displays.items():
                            <option value="{{k}}">{{v}}</option>
                        % end
                    </select>
                    <label for="floatingSelect">Selecteaza ecran</label>
                </div>
            </div>

            <div class="mb-3 col-sm-5">
                <div class="input-group mb-3">
                    <input type="text" list=products class="form-control" id="productInput" placeholder="Cauta produs" aria-describedby="addProductButton">
                    <button class="btn btn-success btn-lg" type="button" id="addProductButton" onclick="addItem()">
                        <i class="bi bi-plus-circle-fill"></i>
                    </button>
                </div>
                <datalist id=products>
                    % for p in products:
                        <option value="{{p['barcode']}}|{{p['name']}}">
                    % end
                </datalist>
            </div>
                <div class="table-responsive">
                    <table class="table table-striped table-hover table-bordered border-white">
                        <thead class="table-dark">
                            <tr>
                                <th class="col-md-1">#</th>
                                <th>Denumire</th>
                                <th class="col-md-1">Pret</th>
                                <th class="col-md-1">U.M</th>
                                <th class="col-md-1">Cantitate</th>
                                <th class="col-md-1"></th>
                            </tr>
                        </thead>
                        <tbody class=""></tbody>
                    </table>
                </div>
            </div>
    </body>
    <!-- FOOTER IMPORTS -->
    <script src="static/js/bootstrap.bundle.min.js"></script>
    <script src="static/js/jquery-3.5.1.min.js"></script>

    <script>
        // GLOBAL VARS
        var HOST_ADDRESS = document.location.hostname;
        var HOST_PORT = document.location.port;

        function addItem() {
            let gama = $('#displaySelect').find("option:selected").val();
            let productValueSelected = $('#productInput').val();
            let barcode = productValueSelected.split('|')[0].trim();
            let jsonData = {
                'gama': gama,
                'barcode': barcode
            }
            
            $.ajax({
                type: "POST",
                url: "http://" + HOST_ADDRESS + ":" + HOST_PORT + "/product",
                contentType: 'application/json',
                data: JSON.stringify(jsonData),
                success: function() {
                    get_items(gama);
                    $('#productInput').val("").focus();
                }
            })
        }

        function deleteItem(barcode) {
            let gama = $('#displaySelect').find("option:selected").val();
            let jsonData = {
                'gama': gama,
                'barcode': barcode
            }

            $.ajax({
                type: "DELETE",
                url: "http://" + HOST_ADDRESS + ":" + HOST_PORT + "/product",
                contentType: 'application/json',
                data: JSON.stringify(jsonData),
                success: function() {
                    getDisplaySelectionAndPopulateTable();
                }
            })
        }

        function get_items(gama) {
            $.ajax({
                type: "GET",
                url: "http://" + HOST_ADDRESS + ":" + HOST_PORT + "/json_items?gama=" + gama,
                dataType: "json",
                success: function (result, status, xhr) {
                    // remove elements from table
                    let table = $('table > tbody > tr');
                    table.remove();

                    table = $('table > tbody');

                    if ('extras' in result[gama]) {
                        result[gama] = result[gama]['extras'];
                    }

                    if (result[gama].length === 0) {
                        let tr = $('<tr></tr>').addClass('align-middle');
                        tr.append($('<td></td>').attr('colspan', 6).addClass('text-center p-3').text('Nu exista produse adaugate pentru ecranul selectat!'));
                        tr.appendTo(table);
                    }

                    for (let i = 0; i < result[gama].length; i++) {
                        let tr = $('<tr></tr>').addClass('align-middle');
                        if (result[gama][i]['quantity'] === 0) {
                            tr.addClass('bg-danger')
                        }

                        tr.append($('<th></th>').text(i+1).attr('scope', 'row'));
                        tr.append($('<td></td>').text(result[gama][i]['name']));
                        tr.append($('<td></td>').text(result[gama][i]['price']));
                        tr.append($('<td></td>').text(result[gama][i]['um']));
                        tr.append($('<td></td>').text(result[gama][i]['quantity']));

                        let trash_button = $('<button></button>').attr('type', 'button').addClass('btn btn-danger border border-white').click(function() { deleteItem(result[gama][i]['barcode']) });
                        trash_button.append($('<i></i>').addClass('bi bi-trash'));

                        tr.append($('<td></td>').append(trash_button));
                        tr.appendTo(table);
                    }
                }
            });
        }

        function getDisplaySelectionAndPopulateTable() {
            var optionSelected = $('#displaySelect').find("option:selected");
            var valueSelected  = optionSelected.val();
            
            get_items(valueSelected);
        }

        $('select').change(function () {
            getDisplaySelectionAndPopulateTable();
        });

        $(document).ready(function() {
            getDisplaySelectionAndPopulateTable();

            $('#productInput').keypress(function(e) {
                if (e.which === 13) {
                    getDisplaySelectionAndPopulateTable();
                }
            });
    
        });
    </script>
</html>