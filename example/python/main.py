from flask import Flask, jsonify
import numpy as np

app = Flask(__name__)


@app.route('/')
def get_data():
    x, y = get_gaussian_data(1000)

    points = []

    for i in range(len(x)):
        points.append({
            'x': x[i],
            'y': y[i]
        })

    return jsonify(points)


def get_gaussian_data(n):
    m1 = np.random.normal(size=n)
    m2 = np.random.normal(scale=0.5, size=n)

    return m1+m2, m1-m2


app.run()
