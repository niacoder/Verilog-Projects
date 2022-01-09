Design a simple accumulator-based processor with 16-bit word length - first 3-bits are the opcode, bit #12 is the addressing mode (AM), last 12 bits are the address.
If AM = 0, addressing mode is direct. If AM = 1, addressing mode is indirect.

Machine has the following registers:
  - 16 bit Instruction Register
  - 16 bit Memory Data Register
  - 16 bit Accumulator
  - 12 bit Program Counter
  - 12 bit Memory Address Register

Processor implements the following instructions:
  - NOT: Invert the accumulator
  - ADC: Add with carry
  - JPA: Jump if accumulator is greater than zero
  - INCA: Increment accumulator
  - STA: Store and clear accumulator
  - LDA: Load accumulator

**Note: data_file.txt is a text file containing a set of test instructions in HEX format which is read into the testbench in order to produce simulation results


