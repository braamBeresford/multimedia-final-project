# HDL Implementation of JPEG Encoding
### Group 4 : Braam Beresford (@braamBeresford), Brandon Rawson (@rawsonbr), Longjie Guan (TBD), Shane Sabins (@Inscipio), Tristan Luther (@tristanluther28)
### ECE 477 : Multimedia Systems 
### Web Documentation: [tristanluther.com/ece477/](https://tristanluther.com/ece477/)
**This project is a currently under development**
___
## Table of Contents
  - [1. Project Overview](#1-project-overview)
    - [1.1 Intro](#11-intro)
    - [1.2 Motivation](#12-motivation)
  - [2. Contributer Task Delegation](#2-contributer-task-delegation)
  - [3. References](#3-references)
___
## 1. Project Overview

### 1.1 Intro

This project demonstrates the JPEG encoding process in a HDL which has been verified and synthezied then benchmarked against a C language software implmentation for comparison in throughput, area, and speed.

### 1.2 Motivation

Researchers in 2017 found that people have taken over 1.2 trillion photos due to the accessibility provided by mobile phones. To prevent the memory requirements of these images from being unreasonable, compression algorithms are implemented in software to save on memory usage. The next step is to leverage additional hardware to perform the task of encoding and decoding image data to free the CPU from completing tasks on large volumes of data. There are early pioneers in creating hardware implementations in graphics cards, such as Nvidia, however the topic needs more attention and demonstrations to become widespread.

## 2. Contributer Task Delegation

| Braam Beresford        | Brandon Rawson | Longjie Guan  | Shane Sabins  | Tristan Luther           |
| ---------------------- | -------------- | ------------- | ------------- | ------------------------ |
| HDL DCT implementation | Hello, World!  | Hello, World! | Hello, World! | C Software Implmentation |
| Documentation          | Documentation  | Documentation | Documentation | Documentation            |

## 3. References
- [Huffman Encoder and Decoder Using Verilog](https://www.ijettcs.org/Volume7Issue2/IJETTCS-2018-04-16-48.pdf)
- [Leveraging the Hardware JPEG Decoder and NVIDIA nvJPEG Library on NVIDIA A100 GPUs](https://developer.nvidia.com/blog/leveraging-hardware-jpeg-decoder-and-nvjpeg-on-a100/)
- [People will take 1.2 trillion digital photos this year — thanks to smartphones](https://www.businessinsider.com/12-trillion-photos-to-be-taken-in-2017-thanks-to-smartphones-chart-2017-8)
- [Implementation of Run Length Encoding Using Verilog HDL](https://www.ijsr.net/archive/v9i3/SR20306192039.pdf)
