![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

## DOSCI 500
DOSCI 500 is a fully digital oscillator based on the biquad topology. As every oscillator it gets no inputs and it outputs a 500 Hz sine wave sampled at 8 kHz fully relying on digital logic.
The design works with a 50 MHz clock.

## Design Block Diagram
DOSCI 500 is composed by the following parts:
  - Reset Bridge: The reset bridge makes so that the active low reset is asserted asyncronously but it is de-asserted synchronously with the clock edge so not to cause any timing issues
  - DOSCI: This is the core block of the design. It implements the circuit to generate the samples which are updated at 8 kHz rate and sends them to an UART controller with an AXI4-Lite interface
  - UART Controller: The UART takes the packages via AXI4 and sends them serially with 115200 bps through a pin

<img width="705" height="342" alt="immagine" src="https://github.com/user-attachments/assets/9d3791c6-8a5b-4b63-bf33-85afe7be543a" />


