# Terraform

---

## Contenido

- [Terraform](#terraform)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar Terraform en Ubuntu](#instalar-terraform-en-ubuntu)
  - [Extras](#extras)

---

## Documentación

---

## Instalación

### Instalar Terraform en Ubuntu

1. Instalar dependencias:

    ```sh
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
    ```

2. Instalar la llave GPG:

    ```sh
    wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
    ```

3. Agregar el repositorio:

    ```sh
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list
    ```

   - Si en Ubuntu Mantic (23.10) no funciona, bajar la release a lunar
   - [Lista de repositorios](https://www.hashicorp.com/official-packaging-guide?product_intent=terraform)

4. Actualizar e instalar:

    ```sh
    sudo apt update && sudo apt install terraform
    ```

5. Comprobar versión:

    ```sh
    terraform -v
    ```

6. Instalar autocompletado:

    ```sh
    terraform -install-autocomplete && source ~/.bashrc
    ```

---

## Extras
