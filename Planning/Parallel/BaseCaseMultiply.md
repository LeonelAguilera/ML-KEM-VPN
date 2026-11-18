```VHDL
ENTITY base_case_multiply IS
	GENERIC (
		i: INTEGER := 0 -- Note that i is taken instead of gamma. Gamma is computed
		                --internally
	)
	PORT(
		a0, a1, b0, b1: IN coeff_t;
		c0, c1: OUT coeff_t
	);
END ENTITY;
```
