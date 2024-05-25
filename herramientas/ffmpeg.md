# ffmpeg

- [ffmpeg](#ffmpeg)
  - [Instalación](#instalación)
    - [Instalar ffmpeg en windows](#instalar-ffmpeg-en-windows)
  - [Comandos de ffmpeg](#comandos-de-ffmpeg)
    - [Convertir formato](#convertir-formato)
    - [Extraer audio](#extraer-audio)
    - [Comprimir video](#comprimir-video)
    - [Cortar video](#cortar-video)
    - [Crear gif](#crear-gif)
    - [Quitar audio](#quitar-audio)
  - [Extras](#extras)
    - [yt-dlp - Descargar videos de youtube](#yt-dlp---descargar-videos-de-youtube)
      - [Comandos de yt-dlp](#comandos-de-yt-dlp)
      - [Instalar yt-dlp en windows](#instalar-yt-dlp-en-windows)

---

## Instalación

### Instalar ffmpeg en windows

1. Descargar una [build de las ofrecidas](https://ffmpeg.org/download.html#build-windows).
2. Extraer en ***C:\***.
3. Agregar la carpeta ***\bin*** al path (variables de entorno del sistema).

---

## Comandos de ffmpeg

### Convertir formato

```sh
ffmpeg -i input.mkv output .mp4
```

### Extraer audio

```sh
ffmpeg -i input.mp4 -q:a 0 -map a output.mp3
```

- -q:a 0: calidad de audio. 0 es la mejor.
- -map a: selecciona solo la pista de audio.

### Comprimir video

```sh
ffmpeg -i video.mp4 -vcodec libx265 -crf 28 output.mp4
```

- -vcodec libx265: usa el códec de video H.265.
- -crf 28: calidad constante. Mas bajo es mejor calidad y archivo mas grande.

### Cortar video

```sh
ffmpeg -i video.mp4 --ss hh:mm:ss -to hh:mm:ss -c copy output.mp4
```

- -ss: desde.
- -to: hasta.
- -c copy: copiar sin recodificar.

### Crear gif

- Método 1: mas liviano

    ```sh
    ffmpeg -i video.mp4 -vf palettegen paleta.png # Generar paleta de colores
    ffmpeg -i video.mp4 -i paleta.png -filter_complex paletteuse -r 10 -s 320x480 output.gif
    rm paleta.png
    ```

- Método 2: mas pesado

    ```sh
    ffmpeg -i video.mp4 -vf "fps=24,scale=320:-1:flags=lanczos" output.gif
    ```

- fps=24: tasa de fotogramas.
- scale=320: ancho del gif.
- -1: mantener relación de aspecto.
- flags=lanczos: método para el escalado.

### Quitar audio

```sh
ffmpeg -i video.mp4 -an output.mp4
```

---

## Extras

### yt-dlp - Descargar videos de youtube

#### Comandos de yt-dlp

- Descargar video:

    ```sh
    yt-dlp [URL] -P [destino] -o [nombre] -f [id formato]
    ```

  - -F: listar formatos disponibles.
  - -O: opcional.
  - -x: extraer audio luego de descargar. Requiere ffmpeg y ffprobe.
  - --audio-format mp3: usado cuando está -x para convertir el audio.
  - -k: no borrar el video luego de usar -x.
  - --ffmpeg-location: path al ejecutable.

- Formato a elegir: por defecto, se descarga el mejor formato de video. Si este no tiene audio, se une con el mejor formato de audio.
  - Formato de video 100 y formato de audio 200 si 100 no tiene audio: -f "100*+200".
  - Formato de video 100 y formato de audio 200: -f "100+200".
  - Formato de video 100 y formato de audio 200 o mejor formato si 100 no está disponible: -f "100+200/b".
  - Mejor formato de video con mejor formato de audio (default): -f "bv+ba".

- Ordenar formatos:

    ```sh
    yt-dlp [URL] -F -S [campo1,campon]
    ```

  - Orden:
    - +campo: ascendente.
    - campo: descendente. Default.
  - Campos:
    - res
    - quality
    - fps
    - hasvid: tienen video
    - hasaud: tienen audio

#### Instalar yt-dlp en windows

1. Descargar [exe del repositorio](https://github.com/yt-dlp/yt-dlp?tab=readme-ov-file#release-files).
2. Guardar en C:\yt-dlp.
3. Agregar carpeta al path (variables de entorno del sistema).
