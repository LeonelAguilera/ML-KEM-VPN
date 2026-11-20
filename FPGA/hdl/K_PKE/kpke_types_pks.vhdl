LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.mlkem_types_pkg.ALL;

PACKAGE kpke_types_pks IS


    -- Buffer sizes in bytes, sized for the largest parameter set (k = 4).
    -- Actual lengths for a given k:
    --   dk_PKE : 384*k            ->  768 / 1152 / 1536
    --   ek_PKE : 384*k + 32       ->  800 / 1184 / 1568
    --   c      : 32*(du*k + dv)   ->  768 / 1088 / 1568
    -- Unused upper bytes are ignored (inputs) or driven to zero (outputs).
 
    CONSTANT KPKE_SEED_BYTES   : POSITIVE := 32;    -- d, m, r, rho, sigma
    CONSTANT KPKE_DK_MAX_BYTES : POSITIVE := 1536;
    CONSTANT KPKE_EK_MAX_BYTES : POSITIVE := 1568;
    CONSTANT KPKE_C_MAX_BYTES  : POSITIVE := 1568;


    -- Op-codes issued by kpke_decrypt_ctrl to the decrypt datapath.
    -- Algorithm 15 (K-PKE.Decrypt):
    --   u'    = Decompress_du(ByteDecode_du(c1))
    --   v'    = Decompress_dv(ByteDecode_dv(c2))
    --   s_hat = ByteDecode_12(dk_PKE)
    --   w     = v' - NTT^-1(s_hat^T o NTT(u'))
    --   m     = ByteEncode_1(Compress_1(w))

    CONSTANT DEC_OP_DECODE_SK  : NATURAL := 0;  -- s_hat[idx] = ByteDecode_12(dk[384*idx ...])
    CONSTANT DEC_OP_DECODE_U   : NATURAL := 1;  -- u[idx] = Decompress_du(ByteDecode_du(c1[32*du*idx ...]))
    CONSTANT DEC_OP_DECODE_V   : NATURAL := 2;  -- v = Decompress_dv(ByteDecode_dv(c2))
    CONSTANT DEC_OP_CLEAR_ACC  : NATURAL := 3;  -- acc = 0
    CONSTANT DEC_OP_NTT_U      : NATURAL := 4;  -- u[idx] = NTT(u[idx])
    CONSTANT DEC_OP_MUL_ACC    : NATURAL := 5;  -- acc = acc + MultiplyNTTs(s_hat[idx], u[idx])
    CONSTANT DEC_OP_INTT_ACC   : NATURAL := 6;  -- acc = NTT^-1(acc)
    CONSTANT DEC_OP_SUBTRACT_V : NATURAL := 7;  -- w = v - acc
    CONSTANT DEC_OP_PACK_MSG   : NATURAL := 8;  -- m = ByteEncode_1(Compress_1(w))

    -- Types

    TYPE poly_vec_t IS ARRAY (0 TO 3) OF poly_t;   -- vector of up to k = 4 polynomials

    CONSTANT POLY_ZERO : poly_t := (OTHERS => (OTHERS => '0'));
    CONSTANT BYTE_ZERO : byte_t := (OTHERS => '0');


    -- Functions

    -- One-byte encoding of a small number, for the nonce N (PRF) and the
    -- indices i, j appended to rho (SampleNTT) and k appended to d (G).
    -- LSB ordering: result(i) is the bit of weight 2^i.
    FUNCTION to_byte (n : NATURAL) RETURN byte_t;

END PACKAGE kpke_types_pks;

PACKAGE BODY kpke_types_pks IS

    FUNCTION to_byte (n : NATURAL) RETURN byte_t IS
        VARIABLE u : UNSIGNED(7 DOWNTO 0);
        VARIABLE b : byte_t;
    BEGIN
        u := TO_UNSIGNED(n, 8);
        FOR i IN 0 TO 7 LOOP
            b(i) := u(i);
        END LOOP;
        RETURN b;
    END FUNCTION to_byte;

END PACKAGE BODY kpke_types_pks;