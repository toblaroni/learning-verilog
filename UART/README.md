# UART in Verilog
Implementing a UART in Verilog to understand how computers communicate and to learn Verilog.

### [What is UART?](https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter)
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

### Data Framing
UART frame has five elements:
- Idle - Logic High (1). This comes from legacy telegraphy systems where idle high showed the transmitters weren't broken.
- Start Bit - Logic Low (0).
- Data Bits - Next 5 - 9 bits.
- Parity Bit - Optional. If used it's a way for the receiving UART to tell if any data has changed during the transmission.
- Stop - Logic High. Signals that the character is complete.

### Receiver
Receiver checks the state of incoming bits each clock cycle, looking for the start bit. If the apparent start bit lasts at least 1 half of the bit-time it's valid. If not it is ignored. After waiting for a period of time, the incoming bits are sampled again and the values are stored in a shift register. After the required number of bits (5-8 normally), the contents of the shift register are made available in parallel to the receiving system. Basically, once all of the data has been received and stored, the receiver releases all the bits at the same time (parallel) to the receiving device. After that, the UART will set a flag to indicate the data is available.

Standard UARTs are able to store the most recent character whilst also receive the next one. This gives the receiving device a whole character transmission time to fetch a received character.

### Transmitter
Transmission is simpler because the timing doesn't need to be determined. As soon as the sending system puts a character in the shift register, the UART sends the start bit. Then each bit is shifted to the line, then the parity bit is generated and sent if there is one and then finally the stop bits. 
UARTs use different shift registers for sending and receiving to allow full-duplex communication. Since transmission times may be slower than CPU speeds, UARTs maintain a "busy" flag to show the system there's a character in the shift register.

