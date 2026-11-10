[[ByteDecode]]
[[SampleNTT]]
[[SamplePolyCBD]]
[[PRF]]
[[NTT]]
[[NTT-1]]
[[Decompress]]
[[ByteDecode]]
[[ByteEncode]]
```VHDL
entity kpke_encrypt is
    port (
        clk   : in std_logic;
        start : in std_logic;
        k : in integer Range 2 To 4;
       
        ek : in byte_array_t(31 Downto 0);
        m : in byte_array_t(31 Downto 0);
        r : in byte_array_t(31 Downto 0);
        
        ciphertext : out byte_array_t(31 downto 0);
         
        done : out std_logic
    );
end entity kpke_encrypt;
```
