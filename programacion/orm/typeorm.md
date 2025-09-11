# TypeORM

- [TypeORM](#typeorm)
  - [Migraciones](#migraciones)
    - [Crear una migración:](#crear-una-migración)

---

## Migraciones

- En producción es necesiario sincronizar los modelos con la base de datos.
- Una migración es un archivo con consultas de sql para actualizar la base de datos.

### Crear una migración:

1. Instalar la CLI:

   ```sh
   npm i -g typeorm
   ```

   - Si el proyecto usa typescript:

     ```sh
     npm i ts-node --save-dev
     ```

     - Añadir al **_package.json_** según el tipo:

       ```json
       "scripts": {
         ...
         "typeorm": "typeorm-ts-node-commonjs",
         "typeorm": "typeorm-ts-node-esm"
       }
       ```

2. Configurar el datasource:

   ```js
   import { DataSource } from 'typeorm';

   export default new DataSource({
     type: 'mysql',
     host: 'localhost',
     port: 3306,
     username: 'test',
     password: 'test',
     database: 'test',
     entities: [
       /* ... */
     ],
     migrations: [
       /* ... */
     ],
     migrationsTableName: 'custom_migration_table',
   });
   ```

3. Crear migración:

    ```sh
    typeorm migration:create ./path-to-migrations-dir/NombreMigracion
    ```