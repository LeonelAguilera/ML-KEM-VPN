ENTITY compress IS 
    GENERIC (
        d       : IN NATURAL RANGE 0 TO 11
    );
    PORT (
        x       : IN  poly_t;
        comp    : OUT poly_t
    );
END ENTITY compress;