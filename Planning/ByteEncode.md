ENTITY byte_encode IS 
    GENERIC (
        d : NATURAL RANGE 0 TO 11
    );

    PORT (
        f : IN  poly_t;
        b : OUT byte_array_t(0 TO 32*d)
    );
END ENTITY byte_encode;

- fixed input length (one polynomial)
- output length depends on parameter d with 32 * d -> d can be from 1 to 11
