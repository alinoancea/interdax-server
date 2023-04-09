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
                <ol class="breadcrumb mt-3">
                    <li class="breadcrumb-item active"><h3><span class="badge bg-secondary">Pagina principala</span></h3></li>
                </ol>
            </nav>

            <div class="row mb-3">
                <div class="col-sm-6">
                    <div class="card h-100">
                        <div class="card-header text-bg-secondary fw-bold">Configurare elemente ecran</div>
                        <div class="card-body">
                            <p class="card-text">Permite selectarea ecranului dorit si vizualizarea produselor curente, adaugarea/eliminarea de produse</p>
                        </div>
                        <div class="card-footer">
                            <a href="/displayConfiguration" role="button" class="btn btn-success w-100">Configurare ecrane</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </body>
    <!-- FOOTER IMPORTS -->
    <script src="static/js/bootstrap.bundle.min.js"></script>
    <script src="static/js/jquery-3.5.1.min.js"></script>
</html>