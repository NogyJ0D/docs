# RabbitMQ

- [RabbitMQ](#rabbitmq)
  - [¿Qué es?](#qué-es)

---

## ¿Qué es?

- RabbitMQ es un despachador de mensajes.
- Partes:
  - Producer: programa que envía mensajes.
  - Queue: almacena mensajes. Vive en memoria (ram y disco).
  - Consumer: programa que recibe mensajes.
- Pasos:
  - Producer:
    1. Se crea un canal.
    2. Se declara la queue.
    3. Se publica el mensaje en la cola.
  - Consumer:
    1. Se crea un canal.
    2. Se declara la queue.
    3. Queda en escucha esperando los mensajes.
- Work queue: tiene mensajes que representan tareas que no son para ejecutar en el momento.
- Para NodeJS se usa el cliente "amqplib" de npm.
