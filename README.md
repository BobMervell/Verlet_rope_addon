# Godot Rope Addon

A 3D rope simulation addon for Godot, using Verlet integration for smooth, physics-based movement. This addon is highly customizable, allowing you to tweak stiffness, gravity, wind effects, and more for realistic rope behavior. 

![alt text](https://github.com/BobMervell/Verlet_rope_addon/blob/main/images/Rope_gif.mp4)

# ✨ Features:

✔️ Customizable Rope Stiffness – Adjust how elastic or rigid the rope behaves.

✔️ Gravity Control – Set the direction and intensity of gravitational force on the rope.

✔️ Air Resistance (Damping) – Simulates air resistance for a more natural motion.

✔️ Variable Rope Length – Define the theoretical length while physics affects the actual stretch.

✔️ Adjustable Rope Density – Control the number of simulation points (affects performance).

✔️ Fixed Start & End Points – Set anchor positions for the rope.

✔️ Simulation Precision Control – Fine-tune link iterations for better accuracy.

✔️ Performance Adjustments – Optimize call frequency and simulation steps for smooth gameplay.

✔️ Wind Support – Possibility to pair with a wind processing node to apply dynamic wind forces to affect rope movement.

# 📦 Installation:

1. **Download the Addon:** Clone or download the repository from GitHub.
2. **Move the Folder:** Place the verlet_rope_addon folder inside your res://addons/ directory.
3. **Enable the Plugin:**

	Open Godot Editor.
   
	Go to Project > Project Settings > Plugins.
   
	Enable Verlet Rope Addon.

**Note:** You only need to place the verlet_rope folder in "res://addons/" in your godot app.

# 🛠️ Usage Guide:
## Adding a Rope to Your Scene
Create a New Rope

- Add a Rope3D node to your scene ![alt text](https://github.com/LucasROUZE/Verlet_rope_addon/blob/main/addons/verlet_rope/rope_icon.png) 

- Modify properties directly in the Inspector to tweak behavior.

## ☁️ Implementing wind support:

To use wind, set a wind processor node that implements this function:

	  func get_wind_strength(position: Vector3) -> Vector3:
		  return wind_strength_at_position
		  
To add wind support for the rope you need to set the **wind processor** property with your wind node.

## In script instantation:

If you want to instantiate a rope node directly in script you can use Rope3d.new() with the different parameters you whish (including the wind processor).

## 📝 License:

This project is licensed under theCC BY-NC 4.0 , you can use and modify it except for commercial uses, credit is needed.

## 🌟 Support:

❓ Need help? feel free to ask i will gladly help.
