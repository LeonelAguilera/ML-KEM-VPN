[[G]]: Same as parent
[[H]]: Same as parent
[[K-PKE.Encrypt]]: Same as parent


```VHDL
ENTITY ml_kem_encaps_internal IS
	PORT (
		k: INPUT INTEGER RANGE 2 TO 4;
		ek: INPUT byte_array_t(31 DOWNTO 0);
		m:  INPUT byte_array_t(31 DOWNTO 0);
		shared_key: OUTPUT byte_array_t(31 DOWNTO 0);
		ciphertext: OUTPUT byte_array_t(31 DOWNTO 0);
	);
END ENTITY;
```
