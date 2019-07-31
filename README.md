# Ejemplo SDK Centry-Magento2 #

Este proyecto actualiza stock y precios desde Magento hacia Centry a través de dos *Cron Jobs* 
con tiempos de ejecución configurables. También envía ordenes desde Centry a Magento gracias a un
*webhook* previamente registrado en Centry.
Todos estos movimientos quedan registrados en una base de datos local del proyecto.

### Requerimientos ###
- [Ruby 2.3.7](https://www.ruby-lang.org/).
- [Rails 5.2.2](https://rubyonrails.org/).
- [SQLite3](https://www.sqlite.org/index.html).
- [Redis](https://redis.io/).
- [Ngrok](https://ngrok.com/).
- Servidor con [Magento 2](https://magento.com/tech-resources/download).
- Cuenta en Magento 2.
- Cuenta en [Centry](https://www.centry.cl). 

### Vista General ###

Este proyecto consta principalmente de:

* **Modelos**
    * **Producto**: Contiene información para relacionar productos entre Centry y la integración.
    * **Orden**: Contiene información para relacionar ordenes entre Centry y la integración.
    * **Webhook**: Contiene información de los webhooks registrados.
    
* **Controlador**  
    * `notification_listener_controller.rb` encargado de recibir notificaciones desde el webhook registrado.
    
* **Workers**\
Realizan las tareas de envío de información lo que permite que cada tarea sea independiente de otra:
    * `centry_worker.rb` y `integration_worker.rb`: Generan una instancia de la API de Centry y de la integración a usar 
        (en este ejemplo, Magento) respectivamente.
    
    * `integration_stock_worker.rb` y `integration_price_worker.rb`: Son los workers encargados de traer los cambios de 
        stock y precio respectivamente **desde la integración hacia la base de datos local**.
    
    * `centry_stock_save_worker.rb` y `centry_prices_save_worker.rb`: Son los workers encargados de mandar los cambios de 
        stock y precio respectivamente **desde la base de datos local hacia Centry**.
    
    * `notification_listener_worker.rb`: Es el worker encargado de atender las notificaciones recibidas por el *webhook*,
     como por ejemplo, mandar una orden a la integración cuando llega una notificación de orden desde Centry.

* **Inicializadores**
    
    * `sidekiq.rb`: Los workers encargados de mandar información (`integration_stock_worker.rb`, `integration_price_worker.rb`, 
    `centry_stock_save_worker.rb`, `centry_prices_save_worker.rb`) son iniciados por intervalos de tiempos. Para lograr esto
    se define cada una de estos workers como *cron job*.
    
    * `webhook.rb`: Es el encargado de registrar un *webhook* de manera automática en caso de que el proyect no tenga 
    un *webhook* registrado previamente.
     Por otra parte, el worker encargado de manejar las notificaciones recibidas (`notification_listener_worker.rb`),
      se inicializa cada vez que el controlador 
     (`notification_listener_controller.rb`) recibe una notificación desde el *webhook* registrado.

### Configuración ###

1. Instalar gemas del proyecto ```bundle install```.

2. Iniciar [Ngrok](https://ngrok.com).

3. Configurar variables de ambiente:
    Ir a `../CentryBaseExample/config/environments/development.rb` y definir las variables 
    de configuración:
    * **Centry**:
        * `ENV["CENTRY_CLIENT_ID"]`: Id  de perfil en Centry.
        * `ENV["CENTRY_SECRET"]`: Token secreto de tu perfil en Centry.
        * `ENV["BASE_URL"]`: Link *Forwarding* entregado por Ngrok.
        
    * **Magento**:
        * `ENV["HOST"]`: `{hostUrl}/magento` *(ej: http://127.0.1.1/magento).*
        * `ENV["USERNAME"]`: Nombre de usuario.
        * `ENV["PASSWORD"]`: Contraseña.
        * `ENV["UPDATE_NULL_STOCK"]`: String *true* o *false* para actualizar o no el stock de una variante 
        en caso de que se reciba un stock nulo desde Magento.
        * `ENV["UPDATE_WITH_MAX_PRICE"]`: String *true* o *false* que actualiza un producto en Centry (por ende todas 
        variantes) con el precio máximo o mínimo del grupo de productos con el mismo `id_product_centry` presentes en 
        la base de datos local al momento de actualizar.
        * `ENV["STOCK_UPDATE_INTERVAL"]`: String con formato *[Cron Unix](https://crontab.guru/)* para definir el intervalo de ejecución del 
        *cron job* que envía los cambios de stock.
        * `ENV["PRICE_UPDATE_INTERVAL"]`: String con formato *[Cron Unix](https://crontab.guru/)* para definir el intervalo de ejecución del 
        *cron job* que envía los cambios de precios.
     
### Iniciar proyecto ###

1. Iniciar servidor de Magento.

2. Iniciar Redis:\
``` ../{redisFolder}/src$ ./redis-server```

3. Iniciar Sidekiq:\
*En este proyecto ambos cron jobs se ejecutan en la cola por defecto de Sidekiq.*\
``` ../CentryBaseExample$ bundle exec sidekiq```

4. Iniciar proyecto:\
``` ../CentryBaseExample$ rails s```

### Uso del proyecto ###
**Actualización de productos**:
Para que se haga efectiva la actualización de productos desde Magento a Centry debes verificar que el SKU del producto
en Magento debe coincidir con el SKU de la variante correspondiente en Centry (relación mediante SKU). Una vez que 
se inicie el *cron job* esta actualización se hará automáticamente.

**Actualización de ordenes**:
El envío de órdenes desde Centry a Magento ocurrirá automáticamente cada vez que se reciba una notificación el *webhook* registrado en 
Centry. Por ahora solo se envían nuevas órdenes generadas desde Centry, o que no estén registradas previamente en la 
base de datos local.

### Extensibilidad ###
El fin de este proyecto es generar una base que se pueda expandir según las necesidades de cada integración, por lo que 
para hacer esto lo que se puede hacer es complementar lo que hace cada worker ya definido, crear nuevos workers con
 nuevas tareas, extender los atributos de los modelos, etc.\
**Nada de esto es obligatorio y queda a criterio de cada integración que haga uso de este proyecto como extenderá 
sus funcionalidades.** 
 
### Referencias ###
- https://www.ruby-lang.org
- https://rubyonrails.org
- https://magento.com/tech-resources/download
- https://devdocs.magento.com/#/individual-contributors
- https://centrycl.github.io/centry-rest-api-docs
- https://www.sqlite.org/index.html
- https://crontab.guru
- https://redis.io
- https://ngrok.com