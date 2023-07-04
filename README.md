# c2python-translator
Traductor de Lenguaje C a Python utilizando FLEX &amp; BISON

## Manual de Uso del Traductor

### Dependencias
Para ejecutar el traductor, necesitamos instalar algunas dependencias. Para derivados de Debian, desde la consola ejecutar los siguientes comandos:
- flex
```bash
$ sudo apt install flex
```

- bison
```bash
$ sudo apt install bison
```

- gcc
```bash
$ sudo apt-get install build-essential
```

### Código fuente
Descargue el código fuente con git, ejecutando el siguiente comando:

```bash
$ git clone https://github.com/griceldavaldez/c2python-translator
```

### Ejecución
Para compilar el código desde la terminal ubicado en la carpeta c2python-translator, ejecutar el siguiente comando:

```bash
$ make all
```

Y luego, para ejecutar el traductor c2python-translator:
```bash
$ ./c2python code.c code.py
```

- code.c puede ser cualquier archivo de código C
- code.py será el código Python3 generado a partir del archivo code.c