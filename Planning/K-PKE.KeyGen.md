[[G]]
[[SampleNTT]]
[[SamplePolyCBD]]
[[PRF]]
[[NTT]]
[[ByteEncode]]
```VHDL
entity kpke_keygen is
    port (
        clk   : in std_logic;
        start : in std_logic;
        
        k : in integer Range 2 To 4;
        d : in byte_array_t(31 Downto 0);

        ek : out byte_array_t(31 Downto 0);
        dk : out byte_array_t(31 Downto 0);
        done : out std_logic
    );
end entity kpke_keygen;
```
