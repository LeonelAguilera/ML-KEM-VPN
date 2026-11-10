[[ML-KEM.KeyGen_internal]]: Serial

```VHDL
ENTITY ml_kem_keygen IS
	PORT (
		k: INPUT INTEGER RANGE 2 TO 4;
		ek: OUTPUT byte_array_t(31 DOWNTO 0);
		dk: OUTPUT byte_array_t(31 DOWNTO 0)
	);
END ENTITY;
```
