from flask import Flask, jsonify
import numpy as np
from scipy import stats
import matplotlib.pyplot as plt

app = Flask(__name__)


def get_gaussian_data(n):
    m1 = np.random.normal(scale=0.75, size=n)
    m2 = np.random.normal(size=n)

    return m1+m2, m1-m2


@app.route('/')
def get_data():
    points = []

    for i in range(len(m1)):
        points.append({
            'x': m1[i],
            'y': m2[i]
        })

    return jsonify(points)


@app.route('/kde')
def get_kde_data():
    xmin = m1.min()
    xmax = m1.max()
    ymin = m2.min()
    ymax = m2.max()

    X, Y = np.mgrid[xmin:xmax:100j, ymin:ymax:100j]
    positions = np.vstack([X.ravel(), Y.ravel()])
    values = np.vstack([m1, m2])
    kernel = stats.gaussian_kde(values)
    Z = np.reshape(kernel(positions).T, X.shape)

    points = []

    for i in range(len(X[0])):
        for j in range(len(Y[0])):
            points.append({
                'x': X[i, 0],
                'y': Y[0, j],
                'z': Z[i, j]
            })

    return jsonify(points)


@app.route('/kde/contour')
def get_contour_data():
    X, Y, Z = get_kde()

    fig, ax = plt.subplots()
    contour_paths = ax.contour(X, Y, Z).allsegs
    contour_paths_json = []

    for contour_path in contour_paths:
        if len(contour_path) == 0:
            continue

        contour_path_json = []

        for point in contour_path[0]:
            contour_path_json.append({
                'x': point[0],
                'y': point[1]
            })

        contour_paths_json.append(contour_path_json)

    return jsonify(contour_paths_json)


def get_kde():
    xmin = m1.min()
    xmax = m1.max()
    ymin = m2.min()
    ymax = m2.max()

    X, Y = np.mgrid[xmin:xmax:100j, ymin:ymax:100j]
    positions = np.vstack([X.ravel(), Y.ravel()])
    values = np.vstack([m1, m2])
    kernel = stats.gaussian_kde(values)
    Z = np.reshape(kernel(positions).T, X.shape)

    return X, Y, Z


m1, m2 = get_gaussian_data(4000)
app.run()
