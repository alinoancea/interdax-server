<html>
    <head>
        <title>Configurare fructe si legume</title>
        <link href="static/css/styles.css" rel="stylesheet">
    </head>
    <body>
        <h2>Configurare elemente afisate pe ecran</h2>
        <h3>Fructe</h3>
        <div id="fruits_search">
            Cauta 
            <input id=fruit type=text list=products style="width:400px" />
            <button type=button onClick="addFruit();">Adauga</button>
            <datalist id=products>
                % for p in products:
                    <option value="{{p['name']}} | {{p['price']}} | {{p['um']}}">
                % end
            </datalist>
            <table>
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
                        Optiuni
                    </th>
                </tr>
                % for i,item in enumerate(fruits):
                <tr>
                    <td>{{i+1}}</td>
                    <td>{{item['name']}}</td>
                    <td>{{item['price']}}</td>
                    <td>{{item['um']}}</td>
                    <td><a href=/delete?gama=FRUCTE&name={{item['name'].replace(' ', '%20')}}>Sterge</a></td>
                </tr>
                % end
            </table>
        </div>
        <h3>Legume</h3>
        <div id="vegetables_search">
            Cauta 
            <input id=vegetable type=text list=products style="width:400px" />
            <button type=button onClick="addVegetable();">Adauga</button>
            <table>
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
                        Optiuni
                    </th>
                </tr>
                % for i,item in enumerate(vegetables):
                <tr>
                    <td>{{i+1}}</td>
                    <td>{{item['name']}}</td>
                    <td>{{item['price']}}</td>
                    <td>{{item['um']}}</td>
                    <td><a href=/delete?gama=LEGUME&name={{item['name'].replace(' ', '%20')}}>Sterge</a></td>
                </tr>
                % end
            </table>
        </div>
    </body>
    <script>
        function addFruit() {
            let txt = document.getElementById('fruit').value;
            let name = txt.split('|')[0].trim().replace(' ', '%20');
            let price = txt.split('|')[1].trim();
            let um = txt.split('|')[2].trim().replace(' ', '%20');
            window.location.href = "/add?gama=FRUCTE&name=" + name + "&price=" + price + "&um=" + um;
        }

        function addVegetable() {
            let txt = document.getElementById('vegetable').value;
            let name = txt.split('|')[0].trim().replace(' ', '%20');
            let price = txt.split('|')[1].trim();
            let um = txt.split('|')[2].trim().replace(' ', '%20');
            window.location.href = "/add?gama=LEGUME&name=" + name + "&price=" + price + "&um=" + um;
        }
    </script>
</html>