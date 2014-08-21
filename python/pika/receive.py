#!/usr/bin/env python
# -*- coding: utf-8 -*-
import pika

connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
channel = connection.channel()
channel.queue_declare(queue = 'hello') # 作られていないときのために一応。既に作られているときは何も起こらない

print '[*] Waiting for messages. To exit press CTRL+C'

def callback(ch, method, properties, body):
    print "[x] Received %r" % (body,)
channel.basic_consume(callback, queue = 'hello') # , no_ack = True)

channel.start_consuming()
