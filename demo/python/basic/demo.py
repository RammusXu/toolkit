
a_dic = {
    'onse': "A"
}
a_dic['two'] = 123

if 'one' in a_dic:
    print("in")

if 'two' in a_dic and a_dic['two']:
    print("2 in")

import matplotlib.pyplot as plt
import numpy as np

x = np.linspace(0, 20, 100)  # Create a list of evenly-spaced numbers over the range
plt.plot(x, np.sin(x))       # Plot the sine of each x point
plt.show()                   # Display the plot