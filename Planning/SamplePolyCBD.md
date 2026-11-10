ENTITY sample_poly_cbd IS 
    GENERIC (
        eta : NATURAL RANGE 2 TO 3
    );
    
    PORT (
        b : IN  byte_array_t(0 to 64*eta);
        f : OUT poly_t
    );
END ENTITY sample_poly_cbd;


- variable length input (64 * eta, where eta = 2,3)
- fixed output (one polynomial)