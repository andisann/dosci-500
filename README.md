![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

## DOSCI 500
DOSCI 500 is a fully digital oscillator based on the biquad topology. As every oscillator it gets no inputs and it outputs a 500 Hz sine wave sampled at 8 kHz fully relying on digital logic.
The design works with a 50 MHz clock. The Reset is active low and can be asserted asynchronously but is deasserted syncrhonously to reduce risk of metastability.

## Design Block Diagram
DOSCI 500 is composed by the following parts:
  - Reset Bridge: The reset bridge makes so that the active low reset is asserted asyncronously but it is de-asserted synchronously with the clock edge so not to cause any timing issues
  - DOSCI: This is the core block of the design. It implements the circuit to generate the samples which are updated at 8 kHz rate and sends them to an UART controller with an AXI4-Lite interface
  - UART Controller: The UART takes the packages via AXI4 and sends them serially with 115200 bps through a pin

<img width="705" height="342" alt="immagine" src="https://github.com/user-attachments/assets/9d3791c6-8a5b-4b63-bf33-85afe7be543a" />

## Reset Bridge
The reset bridge is a simple structure made with two Flip-Flops in series:
<img width="370" height="259" alt="imagen" src="https://github.com/user-attachments/assets/af694361-d541-43b2-9ee7-8157841a1ddd" />

## DOSCI 500 Oscillator
It is responsible to generate the sinusoidal signal of 500 Hz with a 8 kHz sampling frequency. It generates an output of 8-bit that is then sent to subsequent blocks with AXI4-Lite Interface
<img width="613" height="174" alt="imagen" src="https://github.com/user-attachments/assets/6d24fbfc-595a-414e-9564-25ae8a0479cc" />
<img width="405" height="285" alt="imagen" src="https://github.com/user-attachments/assets/7841e312-dd44-4a90-b38e-f4012082f97f" />

## TX115
This is just a parallel-to-serial converter that then generates the serial signal to be sent via UART to the PC for data read. Note that the 8-bit signed signal is also available at the output for parallel read.
<img width="564" height="193" alt="imagen" src="https://github.com/user-attachments/assets/325fcd57-0684-4d5f-a70c-475f624469a1" />
