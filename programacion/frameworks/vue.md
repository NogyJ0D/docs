# Vue

- [Vue](#vue)

## Componentes

### Crear componentes personalizados

- Ejemplo: componente Card con subcomponentes y estilo

  - CustomCard.vue:

    ```html
    <script setup lang="ts">
      const sizeClasses = {
        sm: ['px-3', 'py-1.5', 'w-sm'],
        md: ['px-4', 'py-2', 'w-md'],
        lg: ['px-6', 'py-3', 'w-lg'],
        xl: ['px-8', 'py-4', 'w-xl'],
      };

      interface Props {
        size?: keyof typeof sizeClasses;
      }

      const props = withDefaults(defineProps<Props>(), {
        size: 'lg',
      });

      const cardClasses = computed(() => {
        const classes = [sizeClasses[props.size]];

        return classes;
      });
    </script>

    <template>
      <div :class="cardClasses">
        <slot />
      </div>
    </template>
    ```
