import matplotlib
import numpy as np
import matplotlib.cm as cm
import matplotlib.pyplot as plt
from scipy import stats
import pandas as pd

shots = pd.read_csv('example/python/shots_2018.csv')

print(shots.head(5))

# delta = 0.025
# x = np.arange(-3.0, 3.0, delta)
# y = np.arange(-2.0, 2.0, delta)
# X, Y = np.meshgrid(x, y)
# Z1 = np.exp(-X**2 - Y**2)
# Z2 = np.exp(-(X - 1)**2 - (Y - 1)**2)
# Z = (Z1 - Z2) * 2

# fig, ax = plt.subplots()
# CS = ax.contour(X, Y, Z)
# ax.clabel(CS, inline=1, fontsize=10)
# ax.set_title('Simplest default with labels')

# plt.show()

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

shots = pd.read_csv('example/python/shots_2018.csv')
x_range = [0, 100]
y_range = [-51, 50]

team_shots = get_team_shots('CGY')
team_shots = team_shots.to_numpy()
X, Y, Z = get_kde_data(team_shots[:, 0], team_shots[:, 1], 40)
Z = np.reshape(Z.T, X.shape)


fig, ax = plt.subplots()
# ax.imshow(np.rot90(Z), extent=[xmin, xmax, ymin, ymax])
# ax.set_xlim([xmin, xmax])
# ax.set_ylim([ymin, ymax])
x = ax.contour(X, Y, Z)
plt.show()