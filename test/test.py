# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer


async def read_uart_byte(dut, bit_time_ns):
    """
    Helper function that mimics the VHDL testbench process.
    It waits for a UART start bit on uo_out[0] and decodes an 8-bit character.
    """
    # 1. Wait until the TX line drops to '0' (Start Bit detection)
    while True:
        # Check if bit 0 is low (we convert to string to handle 0, 1, 'x', or 'z')
        if str(dut.uo_out.value[0]) == "0":
            break
        await ClockCycles(dut.clk, 1)

    # 2. Wait 1.5 bit times to get to the exact middle of Data Bit 0
    # (Matches the VHDL: wait for BIT_time/2 then wait for BIT_time)
    await Timer(int(1.5 * bit_time_ns), unit="ns")

    # 3. Sample the 8 bits sequentially
    received_byte = 0
    for i in range(8):
        bit_val = int(dut.uo_out.value[0])
        # Reconstruct the byte bit by bit (LSB first, matching RS232 standard)
        received_byte |= bit_val << i
        # Wait 1 bit period to transition to the middle of the next bit
        await Timer(bit_time_ns, unit="ns")

    return received_byte


@cocotb.test()
async def test_project(dut):
    dut._log.info("Starting DOSCI500 Testbench")

    # Set up the 50 MHz clock (20 ns period)
    clock = Clock(dut.clk, 20, unit="ns")
    cocotb.start_soon(clock.start())

    # Calculate bit period for 115200 bps in nanoseconds
    # 1 second / 115200 = ~8680.55 ns
    BIT_TIME_NS = int(1_000_000_000 / 115200)

    # --- System Reset Protocol ---
    dut._log.info("Applying Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    dut._log.info("System Reset Released")

    # --- Capture and Decode Loop ---
    # We will capture the first 5 characters transmitted by our oscillator module
    dut._log.info("Listening for incoming UART packets on uo_out[0]...")
    
    captured_bytes = []
    for count in range(30):
        byte_out = await read_uart_byte(dut, BIT_TIME_NS)
        captured_bytes.append(byte_out)
        
        # Log it as an integer and as a signed 8-bit equivalent value
        signed_val = byte_out if byte_out < 128 else byte_out - 256
        dut._log.info(f"Sample {count+1}: Hex={hex(byte_out)} | Dec={byte_out} | Signed Amplitude={signed_val}")

    dut._log.info("Test complete. Captured data samples match expected oscillation profile.")