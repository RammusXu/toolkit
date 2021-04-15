from gevent import monkey
monkey.patch_all()

import threading, time
from pprint import pprint
from datetime import datetime
from pymongo import MongoClient
from random import randrange


INTERVAL = 1.0

HOST = 'mongodb://localhost:27017/'
COLLECTION_NAME = 'test2'

client = MongoClient(
  HOST,
  readPreference='secondaryPreferred'
)

db = client.datagen_it_test

def read():
  threading.Timer(INTERVAL, read).start()
  try:
    doc = db[COLLECTION_NAME].aggregate(
      [
        { '$match': {'dt': "2012-10-10" }},
        { '$sample': { 'size': 3 } }
      ]
    )
    print("read ok", datetime.now(), list(doc)[0]['nb'])

  except Exception as e:
    print(e)

def read_index():
  threading.Timer(INTERVAL, read_index).start()
  try:
    doc = db[COLLECTION_NAME].aggregate(
      [
         { '$match': {'c32': 15, 'c64': 2000 }},
        { '$sample': { 'size': 3 } }
      ]
    )
    print("read_index ok", datetime.now(), list(doc)[0]['nb'])

  except Exception as e:
    print(e)

def write():
  threading.Timer(INTERVAL, write).start()
  try:
    doc = db[COLLECTION_NAME].update_one(
      {
        # "nb": 0,
        "c32": randrange(11, 20),
        "c64": randrange(1000, 20000)
      },
      {
        '$set': {
          "date": datetime.now()
        }
      }
    )

    print("write ok", datetime.now(), doc.modified_count)

  except Exception as e:
    print(e)

read()
read_index()
write()
