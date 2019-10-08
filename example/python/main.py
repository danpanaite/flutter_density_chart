from flask import Flask, jsonify, request
import numpy as np
from scipy import stats

import matplotlib.pyplot as plt
import pandas as pd

shots = pd.read_csv('example/python/shots_2018.csv')
x_range = [0, 100]
y_range = [-51, 50]

app = Flask(__name__)

@app.route('/shots')
def get_shots():
    team_code = request.args.get('team')
    team_shots = get_team_shots(team_code)

    return team_shots.to_json(orient='records')


@app.route('/shots/kde')
def get_shots_kde():
    team_code = request.args.get('team')
    divisions = int(request.args.get('divisions') or 10)
    team_shots = get_team_shots(team_code)

    team_shots = team_shots.to_numpy()
    X, Y, Z = get_kde_data(team_shots[:, 0], team_shots[:, 1], divisions)
    positions = np.vstack([X.ravel(), Y.ravel()])
    points = []

    for i in range(len(positions[0, :])):
        points.append({
            'x': float(positions[0, i]),
            'y': float(positions[1, i]),
            'z': Z[i]
        })

    return jsonify(points)


@app.route('/shots/kde/contour')
def get_contour_data():
    team_code = request.args.get('team')
    divisions = int(request.args.get('divisions') or 10)
    team_shots = get_team_shots(team_code)
    team_shots = team_shots.to_numpy()
    X, Y, Z = get_kde_data(team_shots[:, 0], team_shots[:, 1], divisions)
    Z = np.reshape(Z.T, X.shape)

    fig, ax = plt.subplots()
    contour_levels = ax.contour(X, Y, Z).allsegs
    contour_paths_json = []

    for contour_level in contour_levels:
        if len(contour_level) == 0:
            continue

        for contour_path in contour_level:
            contour_path_json = []

            for point in contour_path:
                contour_path_json.append({
                    'x': point[0],
                    'y': point[1]
                })

            contour_paths_json.append(contour_path_json)

    return jsonify(contour_paths_json)


def get_team_shots(team_code):
    if team_code is not None:
        team_shots = shots[(shots.awayTeamCode == team_code) & (shots.isHomeTeam == 0) | (
            shots.homeTeamCode == team_code) & (shots.isHomeTeam == 1)][['arenaAdjustedXCord', 'arenaAdjustedYCord']]
    else:
        team_shots = shots[['arenaAdjustedXCord', 'arenaAdjustedYCord']]

    team_shots.columns = ['x', 'y']
    team_shots[team_shots['x'] < 0] = team_shots[team_shots['x'] < 0] * -1

    return team_shots


def get_kde_data(m1, m2, divisions):
    X, Y = np.mgrid[x_range[0]: x_range[1]: complex(0, divisions),
                    y_range[0]: y_range[1]: complex(0, divisions)]

    positions = np.vstack([X.ravel(), Y.ravel()])
    values = np.vstack([m1, m2])
    kernel = stats.gaussian_kde(values)
    Z = kernel(positions)

    return [X, Y, Z]


app.run()
