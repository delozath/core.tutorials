# 🐍 Entorno Virtual General para Python

Guía para configurar un entorno virtual de Python orientado a ciencia de datos, machine learning, deep learning, visualización y estadística, sin depender de GPU.

Este entorno es independiente de los entornos específicos para TensorFlow o PyTorch mostrados en otros tutoriales. La idea es tener un espacio general para desarrollo y experimentación con Python. Los proyectos específicos requerirán una configuración particular.

Para este entorno nos enfocaremos en el desarrollo con `uv` + `hydra`.

---

## ✅ Prerequisitos

- Python 3.12 o superior

---

## ⚙️ Instalar `uv`

Puedes instalar `uv` con alguna de estas opciones:

```bash
sudo snap install astral-uv --classic
```

o

```bash
curl -Ls https://astral.sh/uv/install.sh | sh
```

Es necesario reiniciar la terminal o ejecutar `source ~/.bashrc` para que los cambios surtan efecto.

---

## 🧱 Crear el entorno virtual e instalar dependencias

Se creará el entorno virtual llamado `full` en `~/.venvs/full` utilizando `uv`. Luego se instalarán las bibliotecas listadas en el archivo `requirements.txt`.

```bash
uv python install 3.12
uv venv ~/.venvs/full --python 3.12
source ~/.venvs/full/bin/activate
uv pip install -r requirements.txt
```

### Registro en Jupyter

```bash
python -m ipykernel install --user --name full --display-name "Python (full)"
source ~/.bashrc #~/.zshrc:
```

### Alias para activar y desactivar el entorno virtual

Editar:

```bash
nano ~/.bashrc #~/.zshrc:
```

Agregar al final del archivo:

```bash
alias full_venv='source ~/.venvs/full/bin/activate'
alias full_venv-off='deactivate'
```

Reiniciar la terminal o ejecutar `source ~/.bashrc` para que los cambios surtan efecto.

---

## 💻 Configurar el entorno en VSCode

Abrir VSCode e instalar las extensiones recomendadas:

- Python
- Jupyter
- Pylance
- Ruff

Opcionales:

- GitLens
- Even Better TOML
- YAML
- Docker

---

## 🧪 Ejemplo de uso

Crear un nuevo archivo `test_setup.py` con el siguiente contenido:

```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Crear un DataFrame de ejemplo
data = {
    'x': np.random.rand(100),
    'y': np.random.rand(100)
}
df = pd.DataFrame(data)

# Crear un gráfico de dispersión
plt.figure(figsize=(10, 6))
sns.scatterplot(x='x', y='y', data=df)
plt.title('Gráfico de dispersión de ejemplo')
plt.xlabel('Eje X')
plt.ylabel('Eje Y')
plt.show()
```

Activar el entorno virtual y ejecutar el archivo para verificar que todo funciona correctamente:

```bash
full_venv
python test_setup.py
```
