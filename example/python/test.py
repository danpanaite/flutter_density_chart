import matplotlib
import numpy as np
import matplotlib.cm as cm
import matplotlib.pyplot as plt
from scipy import stats


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

def get_gaussian_data(n):
    m1 = np.random.normal(scale=0.75, size=n)
    m2 = np.random.normal(size=n)

    return m1+m2, m1-m2


m1, m2 = get_gaussian_data(4000)
xmin = m1.min()
xmax = m1.max()
ymin = m2.min()
ymax = m2.max()

X, Y = np.mgrid[xmin:xmax:100j, ymin:ymax:100j]
positions = np.vstack([X.ravel(), Y.ravel()])
values = np.vstack([m1, m2])
kernel = stats.gaussian_kde(values)
Z = np.reshape(kernel(positions).T, X.shape)


fig, ax = plt.subplots()
# ax.imshow(np.rot90(Z), extent=[xmin, xmax, ymin, ymax])
# ax.set_xlim([xmin, xmax])
# ax.set_ylim([ymin, ymax])
x = ax.contour(X, Y, Z)
plt.show()