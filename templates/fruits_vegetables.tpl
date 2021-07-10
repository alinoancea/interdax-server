<!doctype html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        
        <link rel="stylesheet" href="static/css/bootstrap.min.css">
        <link href="static/css/styles.css" rel="stylesheet">
        
        <title>Configurare fructe & legume</title>
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
                <h3>Fructe</h3>
                <div id="item_search">
                    Cauta 
                    <input id=fruit type=text list=products style="width:400px" />
                    <button type=button onClick="addItem('fruit', 'fruits');">Adauga</button>
                    <datalist id=products>
                        % for p in products:
                            <option value="{{p['barcode']}} | {{p['name']}}">
                        % end
                    </datalist>
                    <table id=table_fruits>
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
                <h3>Legume</h3>
                <div id="item_search">
                    Cauta 
                    <input id=vegetable type=text list=products style="width:400px" />
                    <button type=button onClick="addItem('vegetable', 'vegetables');">Adauga</button>
                    <table id=table_vegetables>
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
                    result = result[gama]['extras'];
                    for (let i = 0; i < result.length; i++) {
                        let tr = $('<tr></tr>');
                        if (result[i]['quantity'] == 0) {
                            tr.css('background-color', 'crimson');
                        }
                        tr.append($('<td></td>').text(i+1));
                        tr.append($('<td></td>').text(result[i]['name']));
                        tr.append($('<td></td>').text(result[i]['price']));
                        tr.append($('<td></td>').text(result[i]['um']));
                        tr.append($('<td></td>').text(result[i]['quantity']));
                        tr.append($('<td></td>').append($('<a></a>').attr('href', '/delete?gama=' + gama + '&barcode=' + result[i]['barcode']).text('Sterge')));
                        tr.appendTo(table_fruits);
                    }
                }
            });
        }

        $(document).ready(function() {
            // fruits
            get_items('fruits');
            
            // vegetables
            get_items('vegetables');
        });
    </script>
    </body>
</html>