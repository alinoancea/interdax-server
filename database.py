#/usr/bin/env python3

import sqlite3
import dbf
import yaml
import os
import datetime


ROOT_PATH = os.path.dirname(__file__)
CONFIG_FILE = yaml.full_load(open(os.path.join(ROOT_PATH, 'config.yaml')).read())
TRANSLATE_GAMA = {
    'fruits': 'FRUCTE',
    'vegetables': 'LEGUME'
}



class DbfDatabase(object):

    def __init__(self, file):
        self.connection = dbf.Table(file)

    def __enter__(self):
        self.connection.open()
        return self

    def __exit__(self, *args):
        self.connection.close()

    def query(self, q):
        return self.connection.query(q)
    


def sqlite_connection():
    return sqlite3.connect('./storage/interdax.db')

def insert_local_products_into_database():
    local_database = DbfDatabase(CONFIG_FILE['stoc_file'])
    with local_database as db:
        # r['produs'] => denumire produs
        # r['um'] => unitate de masura
        # r['barcode'] => cod de bare produs
        # r['datai'] => data intrare produs in gestiune
        # r['pretu'] => pret fara TVA si fara adaos
        # r['pretuv'] => pret vanzare fara TVA
        # r['cantitp'] => cantitate produs
        # r['tva'] => TVA produs
        records = db.query('select * %s')
        unique_products = {}
        for r in records:
            name = r['produs'].strip()
            price = round(float(r['pretuv']) + (float(r['pretuv'] * float(r['tva'])/100)), 2)
            um = r['um'].strip()
            barcode = r['barcode']
            entry_date = r['datai'] or datetime.date.min
            quantity = round(r['cantitp'], 2)
            gama = r['gama'].strip()

            if barcode not in unique_products:
                unique_products[barcode] = {
                    'name': name,
                    'price': price,
                    'um': um,
                    'date': entry_date,
                    'quantity': quantity,
                    'gama': gama
                }
                continue
            elif quantity:
                unique_products[barcode]['price'] = price
                unique_products[barcode]['date'] = entry_date
            elif not unique_products[barcode]['quantity'] and unique_products[barcode]['date'] < entry_date:
                unique_products[barcode]['price'] = price
                unique_products[barcode]['date'] = entry_date

            unique_products[barcode]['quantity'] += quantity

    
    with sqlite_connection() as con:
        c = con.cursor()
        for k, v in unique_products.items():
            c.execute('''INSERT INTO products values (?, ?, ?, ?, ?, ?)
                    ON CONFLICT (barcode) DO UPDATE SET name=?, um=?, price=?, quantity=?, gama=?''',
                    (k, v['name'], v['um'], v['price'], v['quantity'], v['gama'], v['name'], v['um'], v['price'], v['quantity'], v['gama']))
        con.commit()


def get_all_products(display=''):
    d = []
    condition = 'WHERE gama = "%s"' % (TRANSLATE_GAMA[display],) if display else ''

    with sqlite_connection() as con:
        c = con.cursor()
        c.execute('SELECT * FROM products %s' % (condition,))
        for i in c.fetchall():
            d.append({'barcode': i[0], 'name': i[1], 'um': i[2], 'price': i[3], 'quantity': i[4]})

        return d


def get_products_by_gama(gama):
    d = []

    with sqlite_connection() as con:
        c = con.cursor()
        c.execute('SELECT * FROM products WHERE gama = ? and quantity != 0', (gama,))
        for i in c.fetchall():
            d.append({'barcode': i[0], 'name': i[1], 'um': i[2], 'price': i[3], 'quantity': i[4]})

        return d


def get_product_by_name(name):
    d = []

    with sqlite_connection() as con:
        c = con.cursor()
        c.execute('SELECT * FROM products WHERE name LIKE "%?%"', (name,))
        for i in c.fetchall():
            d.append({'barcode': i[0], 'name': i[1], 'um': i[2], 'price': i[3], 'quantity': i[4]})

        return d


def get_product_by_barcode(barcode):
    with sqlite_connection() as con:
        c = con.cursor()
        c.execute('SELECT * FROM products WHERE barcode = ?', (barcode,))
        i = c.fetchone()
        return {'barcode': i[0], 'name': i[1], 'um': i[2], 'price': i[3], 'quantity': i[4]}


def get_product_from_display(product_barcode, display):
    with sqlite_connection() as con:
        c = con.cursor()
        c.execute('SELECT * FROM %s WHERE barcode = ?' % (display,), (product_barcode,))
        return c.fetchone()


def add_product_to_display(display, product_barcode):
    with sqlite_connection() as con:
        c = con.cursor()
        p = get_product_by_barcode(product_barcode)
        if not p:
            return
            
        if get_product_from_display(product_barcode, display):
            return

        c.execute('''INSERT INTO %s VALUES (?)''' % (display,),(p['barcode'],))
        con.commit()


def delete_product_from_display(display, product_barcode):
    with sqlite_connection() as con:
        c = con.cursor()
        c.execute('''DELETE FROM %s WHERE barcode = ?''' %(display,), (product_barcode,))
        con.commit()


def get_product_from_database(display):
    l = []
    with sqlite_connection() as con:
        c = con.cursor()
        c.execute('SELECT p.barcode, p.name, p.um, p.price, p.quantity FROM products p INNER JOIN "%s" d ON (p.barcode = d.barcode)' % (display,))
        for i in c.fetchall():
            l.append({'barcode': i[0], 'name': i[1], 'um': i[2], 'price': i[3], 'quantity': i[4]})
        return l


def create_tables():
    with sqlite_connection() as con:
        c = con.cursor()
        c.execute('''DROP TABLE IF EXISTS products''')
        c.execute('''CREATE TABLE products(barcode INTEGER NOT NULL PRIMARY KEY, name TEXT, um TEXT, price REAL,
                quantity INTEGER, gama TEXT)''')
        for d in CONFIG_FILE['company']['display']:
            c.execute('''DROP TABLE IF EXISTS %s''' % (d,))
            c.execute('''CREATE TABLE %s(barcode INTEGER NOT NULL PRIMARY KEY, FOREIGN KEY(barcode) REFERENCES products(barcode))''' % (d,))
        con.commit()


if __name__ == '__main__':
    create_tables()
    insert_local_products_into_database()
