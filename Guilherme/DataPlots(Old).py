#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov  7 22:47:15 2024

@author: guilhermecarvalhojardim
"""

import matplotlib.pyplot as plt
import math
import pandas as pd

# Load data
data = pd.read_csv("/Users/guilhermecarvalhojardim/Downloads/Curvedata/data.csv")

alpha = data['Alpha_Deg']
F_A = data['Axial_N']
F_N = data['Normal_N']
q = data['Q_Pa']
gamma = data['Delta']

# Constants
b = 0.6  # Span, m
c = 0.2  # Chord, m
S = b * c  # Planform Area, m^2
rho = 1.225  # Fluid Mass Density, kg/m^2
mu = 1.81e-5 # Dynamic Viscocity, kg/(ms)

Re_values = []
a_values = []
LD_values = []
C_L_values = []
C_D_values = []

for i, Q in enumerate(q):
    u = (2 * Q / rho) ** 0.5
    Re = (rho * u * c) / mu
    Re_values.append(Re)
    print(f"Data Point {i + 1}, Reynolds Number = {Re:.2e}")



for i in range(len(alpha)):
    # Convert to radians for trigonometric calculations
    alpha_rad = math.radians(alpha[i])
    gamma_rad = math.radians(gamma[i])
    
    L = F_N[i] * math.cos(alpha_rad - gamma_rad) - F_A[i] * math.sin(alpha_rad - gamma_rad)
    D = F_A[i] * math.cos(alpha_rad - gamma_rad) + F_N[i] * math.sin(alpha_rad - gamma_rad)
    
    LD = L / D if D != 0 else None  # Avoid division by zero
    C_L = L / (q[i] * S)
    C_D = D / (q[i] * S)
    a = 2 * math.pi * alpha_rad
    
    a_values.append(a)
    LD_values.append(LD)
    C_L_values.append(C_L)
    C_D_values.append(C_D)

fig, ax_array = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle("Dryden Wind Tunnel Data Visualization", fontsize=16)




# Lift Coefficient vs. Angle of Attack
ax_array[0, 0].plot(alpha, C_L_values, color='blue', label='$C_L$')
ax_array[0, 0].scatter(alpha, C_L_values, color='blue')
ax_array[0, 0].plot(alpha, a_values, color='green', linestyle='--', label='Thin Airfoil')
ax_array[0, 0].set_title("Lift Coefficient vs. Angle of Attack")
ax_array[0, 0].set_xlabel("Angle of Attack (Degrees)")
ax_array[0, 0].set_ylabel("Lift Coefficient $C_L$")
ax_array[0, 0].legend()
ax_array[0, 0].grid(True)
ax_array[0, 0].axhline(0, color='black', linestyle='-', linewidth=1.5)  # y=0 line

# Drag Coefficient vs. Angle of Attack (no y=0 line)
ax_array[0, 1].plot(alpha, C_D_values, color='red', label='$C_D$')
ax_array[0, 1].scatter(alpha, C_D_values, color='red')
ax_array[0, 1].set_title("Drag Coefficient vs. Angle of Attack")
ax_array[0, 1].set_xlabel("Angle of Attack (Degrees)")
ax_array[0, 1].set_ylabel("Drag Coefficient $C_D$")
ax_array[0, 1].legend()
ax_array[0, 1].grid(True)

# Lift Coefficient vs. Drag Coefficient
ax_array[1, 0].plot(C_D_values, C_L_values, color='purple', label='$C_L$ vs. $C_D$')
ax_array[1, 0].scatter(C_D_values, C_L_values, color='purple')
ax_array[1, 0].set_title("Lift Coefficient vs. Drag Coefficient")
ax_array[1, 0].set_xlabel("Drag Coefficient $C_D$")
ax_array[1, 0].set_ylabel("Lift Coefficient $C_L$")
ax_array[1, 0].legend()
ax_array[1, 0].grid(True)
ax_array[1, 0].axhline(0, color='black', linestyle='-', linewidth=1.5)  # y=0 line

# Lift-to-Drag Ratio vs. Angle of Attack
ax_array[1, 1].plot(alpha, LD_values, color='orange', label='$L/D$')
ax_array[1, 1].scatter(alpha, LD_values, color='orange')
ax_array[1, 1].set_title("Lift-to-Drag Ratio vs. Angle of Attack")
ax_array[1, 1].set_xlabel("Angle of Attack (Degrees)")
ax_array[1, 1].set_ylabel("Lift-to-Drag Ratio $L/D$")
ax_array[1, 1].legend()
ax_array[1, 1].grid(True)
ax_array[1, 1].axhline(0, color='black', linestyle='-', linewidth=1.5)  # y=0 line

plt.tight_layout(rect=[0, 0, 1, 0.96])  # Adjust layout to make space for the main title
plt.show()
