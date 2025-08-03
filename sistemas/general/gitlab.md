# Gitlab

- [Gitlab](#gitlab)

---

## Instalación

### Instalar GitLab-CE como paquete en Debian 12

- Pensado para cuando GitLab está en una VM y el proxy reverso está en otra. Caso contrario, revisar la configuración del archivo.

1. Agregar repositorios:

   ```sh
   apt update
   apt install curl sudo
   curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
   ```

2. Configurar **_/etc/gitlab/gitlab.rb_**:

   ```ruby
   external_url 'https://<Dominio>'
   nginx['redirect_http_to_https'] = false
   nginx['ssl_certificate'] = nil
   nginx['ssl_certificate_key'] = nil
   nginx['listen_addresses'] = ['0.0.0.0']
   nginx['listen_port'] = 8081
   nginx['listen_https'] = false
   nginx['proxy_set_headers'] = {
     "X-Forwarded-Proto" => "https",
     "X-Forwarded-Ssl" => "on"
   }
   letsencrypt['enable'] = false
   ```

3. Reiniciar:

   - El primer reconfigure va a tardar. Despues de este, se genera el archivo con la contraseña inicial para el usuario root y se borra a las 24 horas, cambiarla.

   ```sh
   gitlab-ctl reconfigure
   gitlab-ctl restart
   cat /etc/gitlab/initial_root_password
   ```

4. Configurar el proxy reverso externo y entrar.

5. Primeros pasos:
   1. ⚠️ Cambiar contraseña del root: click en el avatar, Password, cambiar y volver a loguearse.
   2. Deshabilitar registro: Admin (botón del fondo en el panel), Settings, General, Sign-up enabled: false
   3. (Opcional) Deshabilitar envío de métricas: Admin, Settings, Metrics and Profiling
      - Usage statistics
        - Enable Service Ping: false
      - Event tracking:
        - Enable event tracking: false
