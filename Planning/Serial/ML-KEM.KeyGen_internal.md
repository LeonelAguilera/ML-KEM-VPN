[[K-PKE.KeyGen]]: Serial
[[H]]: Serial

```VHDL
ENTITY ml_kem_keygen_internal IS
	PORT (
		clk: INPUT STD_LOGIC;
		start: INPUT STD_LOGIC;
		k: INPUT INTEGER RANGE 2 TO 4;
		d: INPUT byte_array_t(31 DOWNTO 0);
		z: INPUT byte_array_t(31 DOWNTO 0);
		ek: OUTPUT byte_array_t(31 DOWNTO 0);
		dk: OUTPUT byte_array_t(31 DOWNTO 0);
		done: OUTPUT STD_LOGIC;
	);
END ENTITY;
```


