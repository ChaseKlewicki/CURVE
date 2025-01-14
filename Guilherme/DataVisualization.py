#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import math

tare_coeffs_F_A = [-0.00035323966346739136, 0.0009710927126727681]  
tare_coeffs_F_N = [-0.0013965099892108547, 0.001537248552170773]  
alpha_offset = 0.7  

data = pd.read_csv("/Users/guilhermecarvalhojardim/Downloads/Curvedata/run653.csv")

TP = data['TP']
Code = data['Code']
Alpha = data['Alpha_Deg']
X_N = data['X_N']   # Raw Axial Force
Y_N = data['Y_N']   # Raw Normal Force
Q_V = data['Q_V']   # Dynamic Pressure in volts

woz_mask = (Code == 1)
X_N_woz = data.loc[woz_mask, 'X_N'].iloc[0]
Y_N_woz = data.loc[woz_mask, 'Y_N'].iloc[0]
Q_V_woz = data.loc[woz_mask, 'Q_V'].iloc[0]

F_A_meas = X_N - X_N_woz
F_N_meas = Y_N - Y_N_woz

alpha_corrected = Alpha + alpha_offset

Q_PA = (Q_V - Q_V_woz) * 62.9

F_A_tare = np.polyval(tare_coeffs_F_A, alpha_corrected)
F_N_tare = np.polyval(tare_coeffs_F_N, alpha_corrected)

F_A = F_A_meas - F_A_tare
F_N = F_N_meas - F_N_tare

#Constants
b = 0.6  # Span (m)
c = 0.2  # Chord (m)
S = b * c
rho = 1.225  # Density (kg/m^3)
mu = 1.81e-5 # Viscosity (kg/(m·s))

C_L_values = []
C_D_values = []
LD_values = []
Re_values = []
a_values = []
alpha_values = []

for i in range(len(alpha_corrected)):
    alpha_rad = np.radians(alpha_corrected[i])
    q = Q_PA[i]

    if q > 0:
        u = np.sqrt(2 * q / rho)
        Re = (rho * u * c) / mu
    else:
        u = 0
        Re = 0

    L = F_N[i]*math.cos(alpha_rad) + F_A[i]*math.sin(alpha_rad)
    D = -F_A[i]*math.cos(alpha_rad) + F_N[i]*math.sin(alpha_rad)

    if q > 0:
        C_L = L / (q * S)
        C_D = D / (q * S)
    else:
        C_L = 0
        C_D = 0

    LD = L / D 
    a = 2 * math.pi * alpha_rad

    C_L_values.append(C_L)
    C_D_values.append(C_D)
    LD_values.append(LD)
    Re_values.append(Re)
    a_values.append(a)
    alpha_values.append(alpha_corrected[i])

fig, ax_array = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle("New Wind-On Data Visualization with Gamma", fontsize=16)


ax_array[0, 0].plot(alpha_values, C_L_values, color='blue', label='$C_L$')
ax_array[0, 0].scatter(alpha_values, C_L_values, color='blue')
ax_array[0, 0].plot(alpha_values, a_values, color='green', linestyle='--', label='Thin Airfoil')
ax_array[0, 0].set_title("Lift Coefficient vs. Angle of Attack")
ax_array[0, 0].set_xlabel("\u03B1")
ax_array[0, 0].set_ylabel("Lift Coefficient $C_L$")
ax_array[0, 0].legend()
ax_array[0, 0].grid(True)
ax_array[0, 0].axhline(0, color='black', linestyle='-', linewidth=1.5)

ax_array[0, 1].plot(alpha_values, C_D_values, color='red', label='$C_D$')
ax_array[0, 1].scatter(alpha_values, C_D_values, color='red')
ax_array[0, 1].set_title("Drag Coefficient vs. Angle of Attack")
ax_array[0, 1].set_xlabel("\u03B1")
ax_array[0, 1].set_ylabel("Drag Coefficient $C_D$")
ax_array[0, 1].legend()
ax_array[0, 1].grid(True)

ax_array[1, 0].plot(C_D_values, C_L_values, color='purple', label='$C_L$ vs. $C_D$')
ax_array[1, 0].scatter(C_D_values, C_L_values, color='purple')
ax_array[1, 0].set_title("Lift Coefficient vs. Drag Coefficient")
ax_array[1, 0].set_xlabel("Drag Coefficient $C_D$")
ax_array[1, 0].set_ylabel("Lift Coefficient $C_L$")
ax_array[1, 0].legend()
ax_array[1, 0].grid(True)
ax_array[1, 0].axhline(0, color='black', linestyle='-', linewidth=1.5)

ax_array[1, 1].plot(alpha_values, LD_values, color='orange', label='$L/D$')
ax_array[1, 1].scatter(alpha_values, LD_values, color='orange')
ax_array[1, 1].set_title("Lift-to-Drag Ratio vs. Angle of Attack")
ax_array[1, 1].set_xlabel("\u03B1")
ax_array[1, 1].set_ylabel("Lift-to-Drag Ratio $L/D$")
ax_array[1, 1].legend()
ax_array[1, 1].grid(True)
ax_array[1, 1].axhline(0, color='black', linestyle='-', linewidth=1.5)

plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.show()