ENTITY byte_decode IS 
    GENERIC (
        d : NATURAL RANGE 0 TO 11
    );

    PORT (
        b : IN byte_array_t(0 TO 32*d);
        f : OUT  poly_t
    );
END ENTITY byte_decode;

- variable input length based on d (32 * d)
- fixed output length (one polynomial)