[[BaseCaseMultiply]]
- fixed inputs (two polynomials)
- fixed outputs (one polynomial)

```VHDL
ENTITY multiply_ntts IS
	PORT(
		f: IN poly_t;
		g: IN poly_t;
		h: OUT poly_t
	);
END ENTITY;
```