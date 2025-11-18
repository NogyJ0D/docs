# Finanzas

- [Finanzas](#finanzas)
  - [Trading](#trading)
    - [Soportes y Resistencias](#soportes-y-resistencias)
  - [Instrumentos](#instrumentos)
    - [CEDEAR](#cedear)
      - [Ventajas de invertir en CEDEAR](#ventajas-de-invertir-en-cedear)
      - [Dividendos](#dividendos)
      - [Split](#split)
  - [Dólar](#dólar)
    - [Dólar MEP](#dólar-mep)
    - [Dólar Contado con Liquidación](#dólar-contado-con-liquidación)

---

## Trading

### Soportes y Resistencias

- Son puntos en los gráficos donde el precio sigue una tendencia, se detiene y rebota hacia el lado contrario.
  - Los soportes son los puntos donde el precio baja y rebota para subir.
  - Las resistencias son los puntos donde el precio sube y rebota para bajar.
- Tipos de soporte y resistencia:
  - **Fijos o normales**:
    - **Extremos**: máxmimos y mínimos.
    - **Internos**: están dentro de los extremos. Si detectamos varias de estas a las que se llega con paridad de vela, y el precio actual sin llegar a los máximos, es posible que en el futuro se vuelva a producir si la vela muestra la misma tendencia.
  - **Dinámicos**:
    - Líneas diagonales
- **Paridad de vela**:
  - Son velas que abren y cierran a la par, tienen el mismo tamaño. Se niegan entre sí. La más confiables son las que menos cola tienen (más volumen).
    - Una vela _alcista_ que cierra y comienza una vela bajista al lado del mismo tamaño, genera una _resistencia_.
    - Una vela _bajista_ que cierra y comienza una vela alcista al lado del mismo tamaño, genera un _soporte_.

---

## Instrumentos

### CEDEAR

- **CEDEAR**: _Certificado de Depósito Argentino_.
- Activos o títulos que cotizan en mercado argentina y representan acciones del extranjero.
- Son fragmentos en pesos de acciones que cotizan en dolares.
- Tanta cantidad de CEDEAR equivale a una acción, esto se llama **ratio** y varía según la empresa.
  - Son modificables con el tiempo.
  - EJ: si _Microsoft_ tiene un ratio 30:1, 30 certificados equivalen a una acción.
  - [Listado de ratios](https://www.rankia.com.ar/blog/cedear/6752496-listado-ratio-conversion-cedear-argentina)
- El precio depende principalmente de:
  - La variación dle precio de la acción en el mercado de origen.
  - La variación del tipo de cambio.
- El cálculo del precio del fragmento es más o menos así:

  ```math
  (vAC \times dolOF) \div R = vCDA \\
  vAC = Valor\,de\,la\,Acción \\
  dolOF = Dolar\,oficial \\
  R = Ratio\,de\,la\,acción \\
  vCDA = Valor\,CEDEAR
  ```

#### Ventajas de invertir en CEDEAR

- Ya que representa una acción que cotiza en el mercado exterior, no argentino, _nos alejamos del riesgo a la volatilidad local_ exponiendonós al del mercado donde opera el activo, menos volátil y más desarrollado.
- Proteje los ahorros contra posibles devaluaciones al cotizar en dólares. Si sube el tipo de cambio del dólar, _sube el precio del CEDEAR en pesos_.
- Se pueden cobrar dividendos periódicamente.

#### Dividendos

- Son una parte de las ganancias de una empresa que se distribuye entre sus accionistas.
- Comprar un CEDEAR que representa una acción que paga dividendos te da derecho a recibir ese pago.
- **Pasos del proceso de cobro**:
  1. _Anuncio del dividendo_: la empresa informa cuánto va a distribuir por acción.
  2. _Conversión local_: el custodio del CEDEAR recibe el pago del dividendo en dólares.
  3. _Acreditación_: el broker local convierte el monto a pesos o lo deja en dólares.
- **Impuestos y retenciones**:
  - _Retenciones internacionales_: el país de origen de la acción retiene un 30% de los dividendos.
  - _Impuesto a las ganancias en Argentina_: los dividendos pueden estar alcanzados por impuestos locales.
- **¿Cómo elegir los mejores CEDEAR para recibir dividendos?**
  1. _Rentabilidad del dividendo (Dividend Yield)_: cuánto paga una empresa en relación con el precio de su acción.
  2. _Historial de pagos_: las empresas que pagan regularmente son más confiables.
  3. _Sector y perspectivas_: las empresas tecnológicas suelen reinvertir utilidades en vez de repartirlas, mientras que sectores como el energético tienen a ofrecer dividendos más generosos.

#### Split

- El split de la acción de disminuir el valor de cada acción y aumentar su número, respetando la proporción monetaria de los inversores.
- Si se divide la acción, aumenta la cantidad de CEDEARs.

---

## Dólar

### Dólar MEP

- Es el tipo de cambio que se genera al comprar un activo (bono, [CEDEAR](#cedear)) en una moneda para luego venderlo en otra moneda.
  - EJ: comprar el instrumento en pesos y venderlo en dólares.

### Dólar Contado con Liquidación

- Es el tipo de cambio que se genera al comprar un activo (bono, [CEDEAR](#cedear)) en una moneda para luego venderlo en otra moneda, con la particularidad de que la liquidación en la moneda extranjera se realiza en el exterior.
  - EJ: comprar el instrumento en pesos y venderlo en dólares.
