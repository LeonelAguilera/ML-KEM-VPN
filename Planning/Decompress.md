ENTITY decompress IS 
    GENERIC (
        d       : IN NATURAL RANGE 0 TO 11
    );
    PORT (
        y       : IN  poly_t;
        decomp  : OUT poly_t
    );
END ENTITY decompress;