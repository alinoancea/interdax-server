#!/usr/bin/env python3

import bottle
import yaml
import json
import os
import platform
import time

from multiprocessing import Process

import database

__version__ = '0.0.2'

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


def convert_barcodes():
    return database.get_all_products()


def get_products_by_gama(gama):
    products = database.get_products_by_gama(gama)

    return sorted(products, key=lambda i: i.get('name'))


def add_product_to_local(display, product_barcode):
    database.add_product_to_display(display, product_barcode)


def get_single_product(product_name):
    product = database.get_product_by_name(product_name,)
    if product:
        return product[0]


def check_local_storage():
    time_sleep = 300

    while True:
        database.insert_local_products_into_database()
        time.sleep(time_sleep)


@bottle.route('/')
def home():
    return bottle.template('templates/home.tpl', company_name=CONFIG_FILE['company']['name'].upper())


@bottle.route('/barcodes', method='GET')
def barcodes():
    bottle.response.content_type = 'application/json'

    all_products = convert_barcodes()
    return json.dumps(all_products)


@bottle.route('/fruits_vegetables', method='GET')
def fruits_vegetables():
    products = convert_barcodes()

    return bottle.template('templates/fruits_vegetables.tpl', company_name=CONFIG_FILE['company']['name'].upper(),
            products=products)


@bottle.route('/json_items', method='GET')
def json_items():
    gama = bottle.request.query.get('gama').split(',')
    r = {}

    bottle.response.content_type = 'application/json'
    bottle.response.add_header('Access-Control-Allow-Origin', '*')

    if 'fruits' in gama:
        extras = sorted(database.get_product_from_database(display='fruits'), key=lambda i: i.get('name'))
        fruits = sorted(database.get_products_by_gama('FRUCTE') + extras, key=lambda i: i.get('name'))
        r['fruits'] = {
            'fruits': fruits,
            'extras': extras
        }
    elif 'vegetables' in gama:
        extras = sorted(database.get_product_from_database(display='vegetables'), key=lambda i: i.get('name'))
        vegetables = sorted(database.get_products_by_gama('LEGUME') + extras,  key=lambda i: i.get('name'))
        r['vegetables'] = {
            'vegetables': vegetables,
            'extras': extras
        }
    elif 'frozen1' in gama:
        frozen1 = sorted(database.get_product_from_database(display='frozen1'), key=lambda i: i.get('name'))
        r['frozen1'] = frozen1
    elif 'frozen2' in gama:
        frozen2 = sorted(database.get_product_from_database(display='frozen2'), key=lambda i: i.get('name'))
        r['frozen2'] = frozen2
    elif 'fish' in gama:
        fish = sorted(database.get_product_from_database(display='fish'), key=lambda i: i.get('name'))
        r['fish'] = fish
    elif 'frozen_vegetables' in gama:
        frozen_vegetables = sorted(database.get_product_from_database(display='frozen_vegetables'), key=lambda i: i.get('name'))
        r['frozen_vegetables'] = frozen_vegetables

    return json.dumps(r)


@bottle.route('/frozen', method='GET')
def frozen():
    products = convert_barcodes()

    return bottle.template('templates/frozen.tpl', company_name=CONFIG_FILE['company']['name'].upper(),
            products=products)


@bottle.route('/delete', method='GET')
def delete_from_local():
    gama = bottle.request.query.get('gama')
    barcode = bottle.request.query.get('barcode')

    database.delete_product_from_display(gama, barcode)

    bottle.redirect('/fruits_vegetables' if gama in ('fruits', 'vegetables') else '/frozen')


@bottle.route('/add', method='GET')
def add_to_local():
    gama = bottle.request.query.get('gama')
    barcode = bottle.request.query.get('barcode')

    database.add_product_to_display(gama, barcode)

    bottle.redirect('/fruits_vegetables' if gama in ('fruits', 'vegetables') else '/frozen')


@bottle.route(r'/static/<type>/<filepath>', method='GET')
def css(type, filepath):
    return bottle.static_file(filepath, root=os.path.join(ROOT_PATH, 'static', type))


@bottle.route('/favicon.ico', method='GET')
def favicon():
    return bottle.static_file('favicon.ico', root=os.path.join(ROOT_PATH, 'static', 'resources'))


if __name__ == '__main__':
    p = Process(target=check_local_storage)
    p.start()
    bottle.debug(CONFIG_FILE['http_server']['debug'])
    bottle.run(
        host=CONFIG_FILE['http_server']['host'],
        port=CONFIG_FILE['http_server']['port'],
        reloader=CONFIG_FILE['http_server']['debug'], 
        server='paste'
    )
