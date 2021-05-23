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
                <h1>Operatiuni disponibile</h1>
                <ul>
                    <li>
                        <h3>
                            <a href="/barcodes">Afisare lista produse</a>
                        </h3>
                    </li>
                    <li>
                        <h3>
                            <a href="/fruits_vegetables">Gestionare fructe si legume</a>
                        </h3>
                    </li>
                    <li>
                        <h3>
                            <a href="/frozen">Gestionare congelate</a>
                        </h3>
                    </li>
                </ul>
            </div>
        </div>

        <script src="static/js/jquery-3.5.1.min.js"></script>
        <script src="static/js/bootstrap.bundle.min.js"></script>
    </body>
</html>