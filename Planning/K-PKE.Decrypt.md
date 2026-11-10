[[Decompress]]
[[ByteDecode]]
[[NTT-1]]
[[NTT]]
[[ByteEncode]]
[[Compress]]

```VHDL
entity kpke_decrypt is
    port (
        clk   : in std_logic;
        start : in std_logic;
		k : in integer Range 2 To 4;
       
        dk : in byte_array_t(31 Downto 0);
        ciphertext : in byte_array_t(31 downto 0);
        
		m : out byte_array_t(31 Downto 0);
		 
        done : out std_logic
    );
end entity kpke_decrypt;
```