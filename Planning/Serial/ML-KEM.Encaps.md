[[ML-KEM.Encaps_internal]]: Serial
[[RandomNumberGenerator]]: Parallel


```VHDL
ENTITY ml_kem_encaps IS
	PORT (
		clk: INPUT STD_LOGIC;
		start: INPUT STD_LOGIC;
		k: INPUT INTEGER RANGE 2 TO 4;
		ek: INPUT byte_array_t(31 DOWNTO 0);
		shared_key: OUTPUT byte_array_t(31 DOWNTO 0);
		ciphertext: OUTPUT byte_array_t(31 DOWNTO 0);
		done: OUTPUT STD_LOGIC;
	);
END ENTITY;
```
