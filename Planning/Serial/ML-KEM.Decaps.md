[[ML-KEM.Decaps_internal]]: Same as parent


```VHDL
ENTITY ml_kem_decaps IS
	PORT (
		k: INPUT INTEGER RANGE 2 TO 4;
		dk: INPUT byte_array_t(31 DOWNTO 0);
		ciphertext: INPUT byte_array_t(31 DOWNTO 0);
		shared_key: OUTPUT byte_array_t(31 DOWNTO 0);
	);
END ENTITY;
```
