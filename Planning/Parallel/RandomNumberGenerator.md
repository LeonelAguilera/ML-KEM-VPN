```VHDL
ENTITY rng IS
	PORT (
		clk: INPUT STD_LOGIC;
		random_number: OUTPUT byte_array_t(31 DOWNTO 0);
	);
END ENTITY;
```