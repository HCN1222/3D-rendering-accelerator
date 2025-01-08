# 3D-rendering-accelerator

[![hackmd-github-sync-badge](https://hackmd.io/m76AxNVjS-CTZnnKD7nPEw/badge)](https://hackmd.io/m76AxNVjS-CTZnnKD7nPEw)

Huang Cheng-Ning, Tseng Wei-Bo

![image](/images/teasor.png)

This is the final projecct for the course IC design laboratory in National Tsing-Hua University. Our design supports rendering colored triangular mesh with up to 1048576 faces and vertices in 144 fps.

## Specification

### Synthesis

- Clock period: 8.0ns  
Note that the input and the output delay is 50% of the clock period.
- Area: 1359960 um^2

### APR
- Clock period: 10.0ns
- Area: 1600084 um^2
- Utilization: 85%(1359960/1600084)
- Chip Layout  
![image](/images/chip_layout.png)
- IR drop  
![image](/images/IR_drop.png)
- Power  

| Power Component        | Pre Layout     | Post Layout (Pre-sim waveform) | Post Layout (Post-sim waveform) |
|------------------------|----------------|---------------------------------|----------------------------------|
| Net Switching Power    | 7.244       mW | 0.0115 W                       | 0.0174 W                        |
| Cell Internal Power    | 0.0372 W       | 0.0228 W                       | 0.0365 W                        |
| Total Power            | 0.0445 W       | 0.0343 W                       | 0.0539 W                        |

### Input

- **Camera**  
    - `eyeX`, `eyeY`, `eyeZ`: The position of the camera. _24-bits signed fixed point, 4Q20._
    - `centerX`, `centerY`, `centerZ`: The center of the camera screen.  _24-bits signed fixed point, 4Q20._
    - `upX`, `upY`, `upZ`: The Up direction of the camera. _24-bits signed fixed point, 4Q20._
    - `input_valid`: Indicates if the input data is valid. _1-bit._

### Output
    
Stores the result into sram ( screen buffer (1280*720) ).
For the address of the screen buffer sram, each address contains 16 banks.
The output format of the pixel is in RGB. _24-bits unsigned fixed point each, packed._ _72-bits_ in total.

- `FINISH`: Indicates the end of rendering.

### Sram

- **Vertices**   
    - `vertex`: The world space coordinate of the mesh (x, y, z) in _24-bits signed fixed point, 4Q20_, packed. _72-bits_ in total.

- **Face**  
    - `vertex1`, `vertiex2`, `vertiex3`: Records the addresses of the vertices that the face is composed of.
    
- **Color**  
    - `color`: RGB of the vertex. _24-bits unsigned fixed point each, packed._ _72-bits_ in total.

- **Depth Buffer**
    - `Depth`: The depth in NDC space, used to determined whether the pixel should be drawn or not. _signed 21-bit fixed point, 2Q19_

## Design

### Algorithm

Please refer to the behavioral model written in jupyter notebook.
[Numpy verion](Renderer.ipynb)
[Quantized verion](Testbench_generator.ipynb)

### Hardware Implementation

- Top module
![image](/images/top_module.png)

- Graphic_3D_to_2D_top
![image](/images/Graphic_3D_to_2D_top.png)

### Execute

To run the simulation, execute the following command.
```
cd ./code/sim
bash run_sim.sh
```

### Custom dataset

**Note that the input mesh should be a `.ply` file, which contains x, y, z, r, g, b.**

Use `./code/SW/mesh/scale.ipynb` to scale the mesh.  
( We only support coordinates within -7~7 (signed 4Q20) )

Use the behaior model`./code/SW/Testbench_generator.ipynb` to generate the golden datasets.
