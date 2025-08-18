# Nuxt

- [Nuxt](#nuxt)
  - [Configuración](#configuración)
  - [Vistas](#vistas)
  - [Rutas](#rutas)

---

- Framework para Vue.
- Como Next para React.

## Configuración

- Nuxt permite agregar configuración variable desde dos archivos:

  - nuxt.config.ts:

    - Archivo por defecto de configuraciones de Nuxt (ya viene).
    - Mas práctico para configuración variable/por cliente.
    - Las variables son sobreescritas por un .env en el directorio raíz.
    - Uso:

      ```ts
      // nuxt.config.ts
      export default defineNuxtConfig({
        ...
        runtimeConfig: {
          // Privados (solo accesible en servidor)
          apiSecret: 'secreto',
          databaseUrl: process.env.DATABASE_URL,

          // Públicos (accesibles en cliente y servidor)
          public: {
            nombre: process.env.NOMBRE || 'Default',
            version: process.env.VERSION || '1.0.0'
          }
        }
      })
      ```

      ```html
      <template>
        <p>Versión: {{ runtimeConfig.public.version }}</p>
      </template>

      <script setup lang="ts">
        const runtimeConfig = useRuntimeConfig();
      </script>
      ```

  - app.config.ts:

    - Hay que crearlo.
    - Es para configuraciones básicas y generales de la aplicación y no cambian por despliegue.
    - Uso:

      ```ts
      // app.config.ts
      export default defineAppConfig({
        ui: {
          primary: 'blue',
          gray: 'slate',
        },

        features: {
          darkMode: true,
          notifications: true,
          analytics: true,
        },
      });
      ```

      ```html
      <template>
        <button>{{ appConfig.darkMode ? 'Cambiar modo' : '' }}</button>
      </template>

      <script setup lang="ts">
        const appConfig = useAppConfig();
      </script>
      ```

## Vistas

- `app/app.vue` es el principal archivo, el entrypoint.
- Los componentes se crean en `app/components`.

  - Por defecto un componente `components/base/foo/Button.vue` se importará como `<BaseFooButton />`. Esto se puede deshabilitar en `nuxt.config.ts`:

    ````ts
    export default defineNuxtConfig({
      components: [
        {
          path: '~/components',
          pathPrefix: false // Deshabilita la importación con ruta
        }
      ]
    })
    ```
    ````

## Rutas

- Las rutas se generan automáticamente en base a los archivos en `app/pages`.
- La estructura `app/pages/usuarios/index.vue` se traduce a `http://localhost:3000/usuarios`.
- La estructura `app/pages/usuarios/crear.vue` se traduce a `http://localhost:3000/usuarios/crear`.
- Para habilitar las rutas, hay que agregar un elemento en `app.vue`:

  ```html
  <template>
    <NuxtPage />
  </template>
  ```

  - Así, se pasará a renderizar primero el contenido en `app/pages/index.vue`.

- Los layouts se definen en `app/layouts`.

  - Para habilitarlos, hay que rodear `<NuxtPage />` con `<NuxtLayout>`.
  - Si no se especifica el layout, se usa por defecto `app/layouts/default.vue`.
  - Crear un layout en `app/layouts/custom.vue`:

    ```html
    <template>
      <header>
        <p>Navegación</p>
      </header>

      <slot />
      <!-- Ahí se renderiza la página -->
    </template>
    ```

  - Para decirle a la vista qué layout debe usar:

    ```html
    <template>
      <p>Soy la vista</p>
    </template>

    <script setup lang="ts">
      definePageMeta({
        layout: 'custom',
      });
    </script>
    ```
