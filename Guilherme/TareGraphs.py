import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

data = pd.read_csv("/Users/guilhermecarvalhojardim/Downloads/Curvedata/run641.csv")  # Replace with your actual file path


TP = data['TP']
Code = data['Code']
alpha = data['Alpha_Deg']
X_N = data['X_N']  # Raw Axial Force
Y_N = data['Y_N']  # Raw Normal Force
Q_V = data['Q_V']  # Dynamic Pressure (voltage form)

woz = data['Code'] == 1
X_N_woz = data.loc[woz, 'X_N'].iloc[0]
Y_N_woz = data.loc[woz, 'Y_N'].iloc[0]
Q_V_woz = data.loc[woz, 'Q_V'].iloc[0]

F_A = X_N - X_N_woz
F_N = Y_N - Y_N_woz

alpha_offset = 0.7
alpha_corrected = alpha + alpha_offset

coeffs_F_A = np.polyfit(alpha_corrected, -F_A, 1)  
coeffs_F_N = np.polyfit(alpha_corrected, F_N, 1)

print("Tare Axial Force Fit Coefficients:")
print("  Slope (m_A):", coeffs_F_A[0])
print("  Intercept (b_A):", coeffs_F_A[1])

print("Tare Normal Force Fit Coefficients:")
print("  Slope (m_N):", coeffs_F_N[0])
print("  Intercept (b_N):", coeffs_F_N[1])

F_A_fit = np.polyval(coeffs_F_A, alpha_corrected)
F_N_fit = np.polyval(coeffs_F_N, alpha_corrected)

plt.figure(figsize=(10,5))
plt.subplot(1,2,1)
plt.scatter(alpha_corrected, -F_A, label='Data', color='blue')
plt.plot(alpha_corrected, F_A_fit, label='Linear Fit', color='red')
plt.title('Axial Force Tare vs. Corrected Alpha')
plt.xlabel('\u03B1')
plt.ylabel('Axial Force Tare (N)')
plt.grid(True)
plt.legend()

plt.subplot(1,2,2)
plt.scatter(alpha_corrected, F_N, label='Data', color='green')
plt.plot(alpha_corrected, F_N_fit, label='Linear Fit', color='red')
plt.title('Normal Force Tare vs. Corrected Alpha')
plt.xlabel('\u03B1')
plt.ylabel('Normal Force Tare (N)')
plt.grid(True)
plt.legend()

plt.tight_layout()
plt.show()