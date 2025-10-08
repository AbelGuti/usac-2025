import os
from flask import Flask

# Inicializar la aplicación Flask
app = Flask(__name__)

# Obtener el color de la variable de entorno. 
# Si no se especifica, el color por defecto será 'white'.
color = os.getenv('APP_COLOR', 'white').lower()

# Lista de colores permitidos para validar la entrada
allowed_colors = ['yellow', 'red', 'green', 'blue', 'orange']

# Si el color proporcionado no está en la lista, se usa el color por defecto.
if color not in allowed_colors:
    color = 'white'

@app.route('/')
def home():
    """
    Renderiza la página principal con el color de fondo especificado.
    """
    return f"""
    <!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Demo USAC</title>
        <style>
            body {{
                background-color: {color};
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
                margin: 0;
                font-family: sans-serif;
                color: {'black' if color in ['yellow', 'white'] else 'white'};
            }}
            h1 {{
                font-size: 5rem;
                text-align: center;
            }}
        </style>
    </head>
    <body>
        <h1>Demo USAC</h1>
    </body>
    </html>
    """

if __name__ == '__main__':
    # Ejecuta la aplicación en el host 0.0.0.0 para que sea accesible
    # desde fuera del contenedor Docker.
    app.run(host='0.0.0.0', port=5000)

