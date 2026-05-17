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

plt.figure(figsize=(10, 6))
sns.scatterplot(x='x', y='y', data=df)
plt.title('Gráfico de dispersión de ejemplo')
plt.xlabel('Eje X')
plt.ylabel('Eje Y')
plt.show()