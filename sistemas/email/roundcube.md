# RoundCube

- [RoundCube](#roundcube)

## Plugins

### Password

#### Configuración de contraseña

- El plugin no permite asignar un máximo de caracteres a la contraseña. Para tal fin, hay que modificar el código php de la página.
- Agregar máximo de caracteres a la contraseña:

  1. Ir a la carpeta del plugin, en mi caso `/var/lib/roundcube/public_html/plugins/password`.
  2. Modificar `config.inc.php` y agregar la variable:

     ```php
     // Require the new password to be a certain length.
     // set to blank to allow passwords of any length
     $config['password_minimum_length'] = 8;
     $config['password_maximum_length'] = 16;
     ```

  3. Modificar `password.php` para agregar la verificación:

  ```php
  a
  ```
