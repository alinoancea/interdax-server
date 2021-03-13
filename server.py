#!/usr/bin/env python3

import dbf
import bottle
import yaml
import json
import os
import platform
import datetime

__version__ = '0.0.1'

if platform.system().upper() == 'WINDOWS':
    try:
        import win32gui # NOQA
        import win32con # NOQA

        print('# Windows detected. Hiding window after starting program...')

        this_window = win32gui.GetForegroundWindow()
        win32gui.ShowWindow(this_window, win32con.SW_HIDE)
    except ImportError:
        print('[!] Could not import win32gui/win32con packages! Starting cmd window...')

ROOT_PATH = os.path.dirname(__file__)
CONFIG_FILE = yaml.full_load(open(os.path.join(ROOT_PATH, 'config.yaml')).read())
LOCAL_STORAGE = {
    'fruits': os.path.join(ROOT_PATH, 'storage', 'fruits.txt'),
    'vegetables': os.path.join(ROOT_PATH, 'storage', 'vegetables.txt')
}


def load_extra(path):
    """
        Load products from a given file ("local storage")
    """
    extra_added = []
    if not os.path.exists(path):
        with open(path, 'w') as _:
            pass
    else:
        with open(path) as f:
            for line in f.readlines():
                name, price, um = line.split('|')
                extra_added.append({
                    'name': name,
                    'price': float(price),
                    'um': um
                })
    return extra_added


class Database(object):

    def __init__(self, file):
        self.connection = dbf.Table(file)

    def __enter__(self):
        self.connection.open()
        return self

    def __exit__(self, *args):
        self.connection.close()

    def query(self, q):
        return self.connection.query(q)


stock_database = Database(CONFIG_FILE['stoc_file'])


def convert_barcodes():
    return get_unique_products(additional_fields=('stock',))


def get_products_by_gama(gama):
    products = [p for p in get_unique_products('where \'%s\' in gama' % gama, additional_fields=('stock',)) 
            if p.pop('stock') != 0]

    return sorted(products, key=lambda i: i.get('name'))


def get_unique_products(conditions="", additional_fields=()):
    """
        Function returns a list with every unique product name
        Return object can be customized (default: name, price, barcode, um; optional: date, stock):
            list of dictionaries as [{product1}, {product2}, ...]
    """
    ll = []
    return_fields = ('name', 'price', 'barcode', 'um') + additional_fields
    with stock_database as db:
        # r['produs'] => denumire produs
        # r['um'] => unitate de masura
        # r['barcode'] => cod de bare produs
        # r['datai'] => data intrare produs in gestiune
        # r['pretu'] => pret fara TVA si fara adaos
        # r['pretuv'] => pret vanzare fara TVA
        # r['cantitp'] => cantitate produs
        # r['tva'] => TVA produs
        records = db.query('select * %s' % (conditions,))
        unique_products = {}
        for r in records:
            name = r['produs'].strip()
            price = round(float(r['pretuv']) + (float(r['pretuv'] * float(r['tva'])/100)), 2)
            um = r['um'].strip()
            barcode = r['barcode']
            entry_date = r['datai'] or datetime.date.min
            stock = r['cantitp']

            if name not in unique_products:
                unique_products[name] = {
                    'name': name,
                    'price': price,
                    'barcode': barcode,
                    'um': um,
                    'date': entry_date,
                    'stock': stock
                }
                continue
            elif stock:
                unique_products[name]['price'] = price
                unique_products[name]['date'] = entry_date
            elif not unique_products[name]['stock'] and unique_products[name]['date'] < entry_date:
                unique_products[name]['price'] = price
                unique_products[name]['date'] = entry_date

            unique_products[name]['stock'] += stock

        for _, v in unique_products.items():
            ll.append({kk: v[kk] for kk in return_fields})
    return ll


def delete_product_from_local(file, product_name):
    """
        Delete all ocurrences of a product in a given file
    """
    with open(file) as fr:
        lines = fr.readlines()

    with open(file, 'w') as fw:
        for line in lines:
            if not line.split('|')[0] == product_name:
                fw.write(line)


def add_product_to_local(file, product_name, price, um):
    """
        Add a product into a file
    """
    with open(file, 'a') as fw:
        fw.write('%s|%s|%s\n' % (product_name, price, um))


def get_single_product(product_name):
    product = get_unique_products(conditions='where \'%s\' in produs' % (product_name,), additional_fields=('stock',))
    if product:
        return product[0]


def check_local_storage(product_type):
    storage = 'fruits' if product_type == 'FRUCTE' else 'vegetables'
    local_file = LOCAL_STORAGE[storage]
    extra = load_extra(local_file)
    extra_list = []
    for pr in extra:
        product = get_single_product(pr['name'])
        if product and product['stock'] == 0:
            delete_product_from_local(local_file, pr['name'])
        else:
            extra_list.append(pr)
    return extra_list


@bottle.route('/')
def home():
    return bottle.static_file('home.html', root=os.path.join(ROOT_PATH, 'static', 'html'))


@bottle.route('/barcodes', method='GET')
def barcodes():
    bottle.response.content_type = 'application/json'

    all_products = convert_barcodes()
    return json.dumps(all_products)


@bottle.route('/fruits_vegetables', method='GET')
def fruits_vegetables():
    get_list = bottle.request.query.get('list')

    extra_fruits = check_local_storage('FRUCTE')
    extra_vegetables = check_local_storage('LEGUME')

    if get_list:
        bottle.response.content_type = 'application/json'
        bottle.response.add_header('Access-Control-Allow-Origin', '*')
        fruits = sorted(extra_fruits + get_products_by_gama('FRUCTE'), key=lambda i: i.get('name'))
        vegetables = sorted(extra_vegetables + get_products_by_gama('LEGUME'), key=lambda i: i.get('name'))
        return json.dumps({
            'fruits': fruits,
            'vegetables': vegetables
        })
    else:
        fruits = sorted(extra_fruits, key=lambda i: i.get('name'))
        vegetables = sorted(extra_vegetables, key=lambda i: i.get('name'))
        products = convert_barcodes()

        return bottle.template('templates/fruits_vegetables.tpl', fruits=fruits, vegetables=vegetables,
                               products=products)


@bottle.route('/delete', method='GET')
def delete_from_local():
    gama = bottle.request.query.get('gama')
    name = bottle.request.query.get('name')

    storage = 'fruits' if gama == 'FRUCTE' else 'vegetables'

    delete_product_from_local(LOCAL_STORAGE[storage], name)

    bottle.redirect('/fruits_vegetables')


@bottle.route('/add', method='GET')
def add_to_local():
    gama = bottle.request.query.get('gama')
    name = bottle.request.query.get('name')
    price = bottle.request.query.get('price')
    um = bottle.request.query.get('um')

    storage = 'fruits' if gama == 'FRUCTE' else 'vegetables'

    add_product_to_local(LOCAL_STORAGE[storage], name, price, um)

    bottle.redirect('/fruits_vegetables')


@bottle.route(r'/static/css/<filepath:re:.*\.css>', method='GET')
def css(filepath):
    return bottle.static_file(filepath, root=os.path.join(ROOT_PATH, os.path.join('static', 'css')))


@bottle.route('/favicon.ico', method='GET')
def favicon():
    return bottle.static_file('favicon.ico', root=os.path.join(ROOT_PATH, 'static', 'resources'))


if __name__ == '__main__':
    bottle.run(host=CONFIG_FILE['http_server']['host'], port=CONFIG_FILE['http_server']['port'])
