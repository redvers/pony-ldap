use "format"
use "pony_test"

actor \nodoc\ Main is TestList
  new create(env: Env) =>
    PonyTest(env, this)

  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_BERSizeTests)


class \nodoc\ iso _BERSizeTests is UnitTest
  fun name(): String => "BERSize"
  fun apply(h: TestHelper)? =>
    /* Check variable length sizes */
    h.assert_array_eq[U8](BERSize.encode(10), [0x84 ; 0x00 ; 0x00; 0x00; 0x0a ])
    h.assert_eq[U32]          (BERSize.decode([0x83 ; 0x00 ; 0x00; 0x0a ])?, 10)
    h.assert_eq[U32]          (BERSize.decode([0x82 ; 0x00 ; 0x0a ])?, 10)
    h.assert_eq[U32]          (BERSize.decode([0x81 ; 0x0a ])?, 10)
    h.assert_eq[U32]          (BERSize.decode([0x81 ; 0x0a ; 0x47; 0x92 ])?, 10)
    h.assert_ne[U32]          (BERSize.decode([0x81 ; 0x00 ; 0x00; 0x0a ])?, 10)
    h.assert_eq[U32]          (BERSize.decode([0x0a ; 0xff ; 0x03])?, 10)
    h.assert_eq[U32]          (BERSize.decode([0x0a])?, 10)
    h.assert_eq[U32]          (BERSize.decode([0x00])?, 0)

    /* Check for lengths that exceed sensible values (U32) */
    h.assert_error({(): None ? => BERSize.decode([0x80 ; 0x00 ; 0x00; 0x0a ])?})
    h.assert_error({(): None ? => BERSize.decode([0x86 ; 0x00 ; 0x00; 0x0a ; 0x0a ; 0x0a ; 0x0a])?})

    /* Checking that weirdness isn't occuring around twos-compliment */
    h.assert_array_eq[U8](BERSize.encode(2147483648), [0x84 ; 0x80 ; 0x00; 0x00; 0x00 ])
    h.assert_eq[U32](                  BERSize.decode([0x84 ; 0x80 ; 0x00; 0x00; 0x00 ])?, 2147483648)

    h.assert_array_eq[U8](BERSize.encode(4294967295), [0x84 ; 0xFF ; 0xFF; 0xFF; 0xFF ])
    h.assert_eq[U32](                  BERSize.decode([0x84 ; 0xFF ; 0xFF; 0xFF; 0xFF ])?, 4294967295)










  fun display(h: TestHelper, s: Array[U8] val) =>
    for f in s.values() do
      h.env.out.write(Format.int[U8](f where fmt = FormatHexBare, prec = 2))
      h.env.out.write(" ")
    end
    h.env.out.print("")
