<!doctype html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        
        <link rel="stylesheet" href="static/css/bootstrap.min.css">
        <link href="static/css/styles.css" rel="stylesheet">
        
        <title>Interdax server</title>
    </head>
    <body>
        <div id="header">
            <div class="container p-3 d-flex">
                <a href="/">
                    <div class="logo-container">
                        <img class="logo" src="static/resources/ldp.png" />
                    </div>
                </a>
                <div class="company-name-container mr-auto">
                    <h2 class="font-weight-bold">{{company_name}}</h2>
                </div>
                <a href="/configuration">
                    <div class="gear-container">
                        
                    </div>
                </a>
            </div>
        </div>
        <div id="content" class="bg-light">
            <div class="container">
                <h2>Configurare elemente afisate pe ecran</h2>
                <h3>Congelate 1</h3>
                <div id="item_search">
                    Cauta 
                    <input id=frozen1 type=text list=products style="width:400px" />
                    <button type=button onClick="addItem('frozen1', 'frozen1');">Adauga</button>
                    <datalist id=products>
                        % for p in products:
                            <option value="{{p['barcode']}} | {{p['name']}}">
                        % end
                    </datalist>
                    <table id=table_frozen1>
                        <tr>
                            <th>
                                No
                            </th>
                            <th>
                                Denumire
                            </th>
                            <th>
                                Pret
                            </th>
                            <th>
                                U.M
                            </th>
                            <th>
                                Cantitate
                            </th>
                            <th>
                                Optiuni
                            </th>
                        </tr>
                    </table>
                </div>

                <h3>Congelate 2</h3>
                <div id="item_search">
                    Cauta 
                    <input id=frozen2 type=text list=products style="width:400px" />
                    <button type=button onClick="addItem('frozen2', 'frozen2');">Adauga</button>
                    <table id=table_frozen2>
                        <tr>
                            <th>
                                No
                            </th>
                            <th>
                                Denumire
                            </th>
                            <th>
                                Pret
                            </th>
                            <th>
                                U.M
                            </th>
                            <th>
                                Cantitate
                            </th>
                            <th>
                                Optiuni
                            </th>
                        </tr>
                    </table>
                </div>
                <h3>Peste</h3>
                <div id="item_search">
                    Cauta 
                    <input id=fish type=text list=products style="width:400px" />
                    <button type=button onClick="addItem('fish', 'fish');">Adauga</button>
                    <table id=table_fish>
                        <tr>
                            <th>
                                No
                            </th>
                            <th>
                                Denumire
                            </th>
                            <th>
                                Pret
                            </th>
                            <th>
                                U.M
                            </th>
                            <th>
                                Cantitate
                            </th>
                            <th>
                                Optiuni
                            </th>
                        </tr>
                    </table>
                </div>
                <h3>Preparate congelate</h3>
                <div id="item_search">
                    Cauta 
                    <input id=frozen_vegetables type=text list=products style="width:400px" />
                    <button type=button onClick="addItem('frozen_vegetables', 'frozen_vegetables');">Adauga</button>
                    <table id=table_frozen_vegetables>
                        <tr>
                            <th>
                                No
                            </th>
                            <th>
                                Denumire
                            </th>
                            <th>
                                Pret
                            </th>
                            <th>
                                U.M
                            </th>
                            <th>
                                Cantitate
                            </th>
                            <th>
                                Optiuni
                            </th>
                        </tr>
                    </table>
                </div>
            </div>
        </div>

    </body>
    <script src="static/js/jquery-3.5.1.min.js"></script>
    <script src="static/js/bootstrap.bundle.min.js"></script>
    <script>
        function addItem(el, gama) {
            let txt = document.getElementById(el).value;
            let barcode = txt.split('|')[0].trim();
            window.location.href = "/add?gama=" + gama + "&barcode=" + barcode;
        }

        function get_items(gama) {
            $.ajax({
                type: "GET",
                url: "http://127.0.0.1:18766/json_items?gama=" + gama,
                dataType: "json",
                success: function (result, status, xhr) {
                    let table_fruits = $('#table_' + gama);
                    for (let i = 0; i < result[gama].length; i++) {
                        let tr = $('<tr></tr>');
                        if (result[gama][i]['quantity'] == 0) {
                            tr.css('background-color', 'crimson');
                        }
                        tr.append($('<td></td>').text(i+1));
                        tr.append($('<td></td>').text(result[gama][i]['name']));
                        tr.append($('<td></td>').text(result[gama][i]['price']));
                        tr.append($('<td></td>').text(result[gama][i]['um']));
                        tr.append($('<td></td>').text(result[gama][i]['quantity']));
                        tr.append($('<td></td>').append($('<a></a>').attr('href', '/delete?gama=' + gama + '&barcode=' + result[gama][i]['barcode']).text('Sterge')));
                        tr.appendTo(table_fruits);
                    }
                }
            });
        }

        $(document).ready(function() {
            // frozen1
            get_items('frozen1');
            // frozen2
            get_items('frozen2');
            // fish
            get_items('fish');
            // frozen_vegetables
            get_items('frozen_vegetables');
        });
    </script>    
</html>