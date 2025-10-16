# UART in Verilog
Implementing a UART in Verilog to understand how computers communicate and to learn Verilog.

### What is UART?
Universal Asynchronous Receiver-Transmitter is a bit of hardware for sending data in serial. It uses a start/stop bits for communication timing. The UART device handles the data logic while the translation of data into electricity is handled externally through a driver.
Bytes of data are sequentially transmitted bit-by-bit and then reassembled by the receiver into complete bytes.
Serial transmission with one wire is less costly then transmitting through multiple wires. Shift registers are used to convert between serial and parallel forms.
Data is sent from the least significant bit to the most significant bit.

### Transmitting and Receiving
A UART contains the following:
- A clock generator which generates data at a multiple of the **bit-rate**. 
    - This means the clock is **oscillating** faster than how fast the data is being transferred. This gives the receiver more time to sample each bit. 
- Input and output shift registers, as well as the transmit/receive buffers.
- Transmit/receive control.
- Read/write control logic.

There are three modes of communication:
- **Simplex** - one direction only. 
- **Full Duplex** - Both devices send and receive at the same time.
- **Half Duplex** - Devices take turns transmitting and receiving.


